import 'package:decimal/decimal.dart';
import 'package:dividendendackel/core/errors/result.dart';
import 'package:dividendendackel/data/database/app_database.dart';
import 'package:dividendendackel/data/repositories/drift_instrument_repository.dart';
import 'package:dividendendackel/data/repositories/drift_portfolio_repository.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/features/portfolio/portfolio_editor.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';

void main() {
  test(
    'search-to-holding flow persists and emits through real repositories',
    () async {
      final AppDatabase db = AppDatabase.withExecutor(NativeDatabase.memory());
      addTearDown(db.close);
      final DriftInstrumentRepository instruments = DriftInstrumentRepository(
        db,
      );
      final DriftPortfolioRepository portfolio = DriftPortfolioRepository(db);
      const Instrument liveInstrument = Instrument(
        internalId: 'isin:DE0008404005',
        symbol: 'ALV',
        name: 'Allianz SE',
        currency: Currency.eur,
        mic: 'XETR',
      );
      final FakeClock clock = FakeClock(DateTime.utc(2026, 8, 23));
      final DefaultPortfolioEditor editor = DefaultPortfolioEditor(
        instruments: instruments,
        portfolio: portfolio,
        liveSearch: (_) async =>
            const Success<List<Instrument>>(<Instrument>[liveInstrument]),
        clock: clock,
      );

      final Instrument selected = (await editor.search('Allianz'))
          .valueOrNull!
          .instruments
          .single;
      final Result<void> saved = await editor.addHolding(
        portfolioId: InvestmentPortfolio.defaultId,
        instrument: selected,
        quantity: Decimal.parse('3.5'),
        averagePurchasePrice: Money.parse('210.40', Currency.eur),
      );

      expect(saved.isSuccess, isTrue);
      expect(
        (await instruments.findById(selected.internalId)).valueOrNull,
        selected,
      );
      final Holding emitted = (await portfolio.watchHoldings().first).single;
      expect(emitted.instrumentId, liveInstrument.internalId);
      expect(emitted.quantity, Decimal.parse('3.5'));
      expect(emitted.averagePurchasePrice, Money.parse('210.40', Currency.eur));
      expect(emitted.provenance.source, Provenance.userSource);
    },
  );
}
