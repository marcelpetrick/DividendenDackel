import 'package:decimal/decimal.dart';
import 'package:dividendendackel/data/database/app_database.dart';
import 'package:dividendendackel/data/repositories/drift_instrument_repository.dart';
import 'package:dividendendackel/data/repositories/drift_portfolio_repository.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/domain/use_cases/portfolio_import.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';

void main() {
  late AppDatabase db;
  late DriftInstrumentRepository instruments;
  late DriftPortfolioRepository portfolios;
  late PortfolioImportService service;

  final DateTime now = DateTime.utc(2026, 8, 23, 12);
  const Instrument allianz = Instrument(
    internalId: 'isin:DE0008404005',
    symbol: 'ALV',
    name: 'Allianz SE',
    currency: Currency.eur,
    mic: 'XETR',
    isin: 'DE0008404005',
  );

  setUp(() async {
    db = AppDatabase.withExecutor(NativeDatabase.memory());
    instruments = DriftInstrumentRepository(db);
    portfolios = DriftPortfolioRepository(db);
    service = PortfolioImportService(
      portfolios: portfolios,
      instruments: instruments,
      clock: FakeClock(now),
    );
    await instruments.save(allianz);
  });

  tearDown(() async => db.close());

  test('previews, applies, deduplicates and undoes a native CSV', () async {
    const String csv = '''
Date,Type,ISIN,Quantity,Unit Price,Amount,Currency,Fees,Taxes,External ID,Notes
2026-01-02,Purchase,DE0008404005,2,100,200,EUR,1.50,0.50,trade-1,"first, lot"
2026-05-10,Dividend,DE0008404005,,,27.60,EUR,,,cash-1,distribution
''';

    final PortfolioImportPreview preview = (await service.preview(
      portfolioId: InvestmentPortfolio.defaultId,
      contents: csv,
    )).valueOrNull!;

    expect(preview.format, PortfolioImportFormat.dividendendackel);
    expect(preview.activities, hasLength(4));
    expect(preview.duplicateCount, 0);
    expect(preview.issues, isEmpty);
    expect(preview.activities.first.notes, 'first, lot');
    expect((await service.apply(preview)).valueOrNull, 4);
    expect(
      (await portfolios.watchHoldings().first).single.quantity,
      Decimal.parse('2'),
    );

    final PortfolioImportPreview repeated = (await service.preview(
      portfolioId: InvestmentPortfolio.defaultId,
      contents: csv,
    )).valueOrNull!;
    expect(repeated.activities, isEmpty);
    expect(repeated.duplicateCount, 4);

    final PortfolioImportBatch batch =
        (await portfolios
                .watchImportBatches(InvestmentPortfolio.defaultId)
                .first)
            .single;
    expect(batch.activityCount, 4);
    expect(batch.isUndone, isFalse);
    expect(
      (await portfolios.undoImportBatch(
        InvestmentPortfolio.defaultId,
        batch.id,
        occurredAt: now.add(const Duration(days: 1)),
      )).valueOrNull,
      4,
    );
    expect(await portfolios.watchHoldings().first, isEmpty);
    expect(
      (await portfolios.watchImportBatches(InvestmentPortfolio.defaultId).first)
          .single
          .isUndone,
      isTrue,
    );
    expect(
      (await portfolios.undoImportBatch(
        InvestmentPortfolio.defaultId,
        batch.id,
        occurredAt: now.add(const Duration(days: 2)),
      )).valueOrNull,
      0,
    );
  });

  test('detects Portfolio Performance and localized decimal values', () async {
    const String csv = '''
Date;Type;Value;Transaction Currency;Gross Amount;Currency Gross Amount;Fees;Taxes;Shares;ISIN;Ticker Symbol;Security Name;Note
02.01.2026;Buy;1.251,50;EUR;1.250,00;EUR;1,00;0,50;10;DE0008404005;ALV;Allianz SE;PP import
''';

    final PortfolioImportPreview preview = (await service.preview(
      portfolioId: InvestmentPortfolio.defaultId,
      contents: csv,
    )).valueOrNull!;

    expect(preview.format, PortfolioImportFormat.portfolioPerformance);
    expect(preview.issues, isEmpty);
    expect(preview.activities, hasLength(3));
    final PortfolioActivity purchase = preview.activities.first;
    expect(purchase.type, PortfolioActivityType.purchase);
    expect(purchase.quantity, Decimal.parse('10'));
    expect(purchase.unitPrice, Money.parse('125', Currency.eur));
  });

  test(
    'keeps Portfolio Performance gross and fee currencies distinct',
    () async {
      const String csv = '''
Date;Type;Value;Transaction Currency;Gross Amount;Currency Gross Amount;Fees;Shares;ISIN
02.01.2026;Buy;91,00;EUR;100,00;USD;1,00;10;DE0008404005
''';

      final PortfolioImportPreview preview = (await service.preview(
        portfolioId: InvestmentPortfolio.defaultId,
        contents: csv,
      )).valueOrNull!;

      expect(preview.issues, isEmpty);
      expect(preview.activities, hasLength(2));
      expect(
        preview.activities.first.unitPrice,
        Money.parse('10', Currency.usd),
      );
      expect(
        preview.activities.first.cashAmount,
        Money.parse('100', Currency.usd),
      );
      expect(
        preview.activities.last.cashAmount,
        Money.parse('1', Currency.eur),
      );
    },
  );

  test('rejects bad rows but retains valid rows in the preview', () async {
    const String csv = '''
Date,Type,Symbol,Quantity,Unit Price,Amount,Currency
2026-01-02,Purchase,UNKNOWN,2,100,200,EUR
2026-01-03,Deposit,,,,500,EUR
not-a-date,Dividend,ALV,,,20,EUR
''';

    final PortfolioImportPreview preview = (await service.preview(
      portfolioId: InvestmentPortfolio.defaultId,
      contents: csv,
    )).valueOrNull!;

    expect(preview.activities, hasLength(1));
    expect(preview.activities.single.type, PortfolioActivityType.deposit);
    expect(preview.issues, hasLength(2));
    expect(
      preview.issues.map((PortfolioImportIssue issue) => issue.line),
      <int>[2, 4],
    );
    expect(preview.canApply, isTrue);
  });

  test('collapses duplicate rows inside one source file', () async {
    const String csv = '''
Date,Type,ISIN,Quantity,Unit Price,External ID
2026-01-02,Purchase,DE0008404005,2,100,repeated
2026-01-02,Purchase,DE0008404005,2,100,repeated
''';

    final PortfolioImportPreview preview = (await service.preview(
      portfolioId: InvestmentPortfolio.defaultId,
      contents: csv,
    )).valueOrNull!;

    expect(preview.activities, hasLength(1));
    expect(preview.duplicateCount, 1);
    expect((await service.apply(preview)).valueOrNull, 1);
  });
}
