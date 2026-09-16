import 'package:decimal/decimal.dart';
import 'package:dividendendackel/app/localization/app_localizations.dart';
import 'package:dividendendackel/app/widgets/gross_net_amount.dart';
import 'package:dividendendackel/domain/analytics/analytics.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/features/settings/tax_settings.dart';
import 'package:dividendendackel/features/tax/tax_estimates.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpAmount(
    WidgetTester tester, {
    Currency currency = Currency.usd,
    bool availableFx = true,
    Locale locale = const Locale('en'),
  }) async {
    final Provenance provenance = Provenance(
      source: 'fixture-fx',
      fetchedAt: DateTime.utc(2026, 2, 19),
    );
    final DividendEvent event = DividendEvent(
      instrumentId: 'us',
      amountPerShare: Money.parse('12', currency),
      status: DividendStatus.confirmed,
      paymentDate: DateTime.utc(2026, 2, 20),
      provenance: provenance,
    );
    final Holding holding = Holding(
      instrumentId: 'us',
      quantity: Decimal.fromInt(10),
      provenance: provenance,
    );
    final PortfolioTaxEstimates estimates = PortfolioTaxEstimator.calculate(
      year: 2026,
      events: <DividendEvent>[event],
      holdings: <Holding>[holding],
      instruments: <String, Instrument>{
        'us': Instrument(
          internalId: 'us',
          symbol: 'US',
          name: 'US share',
          currency: currency,
          country: 'US',
        ),
      },
      settings: TaxSettings(
        profile: DividendTaxProfile(),
        table: WithholdingRateTable(
          version: 1,
          asOf: DateTime.utc(2024),
          source: 'fixture',
          sourceUrl: 'https://example.invalid',
          rates: <String, WithholdingRule>{
            'US': WithholdingRule(
              country: 'US',
              statutoryRate: Percentage.parsePercent('30'),
              treatyRateWithForms: Percentage.parsePercent('15'),
              creditableCap: Percentage.parsePercent('15'),
            ),
          },
        ),
      ),
      fxRates: <FxRate>[
        if (availableFx)
          FxRate(
            base: Currency.eur,
            quote: currency,
            rate: Decimal.parse('1.2'),
            observedAt: DateTime.utc(2026, 2, 19),
            provenance: provenance,
          ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          portfolioTaxEstimatesProvider.overrideWith(
            (Ref ref, int year) async => estimates,
          ),
        ],
        child: MaterialApp(
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: GrossNetAmount(
              event: event,
              gross: event.grossPaymentFor(holding.quantity),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final String language in <String>['en', 'de', 'hr']) {
    testWidgets('labels native USD gross and converted EUR net in $language', (
      WidgetTester tester,
    ) async {
      final Locale locale = Locale(language);
      await pumpAmount(tester, locale: locale);
      final AppLocalizations copy = AppLocalizations(locale);
      expect(
        find.text(
          copy.format('Gross {amount}', <String, Object?>{
            'amount': r'$120.00 USD',
          }),
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          copy.format('Net (estimated) {amount}', <String, Object?>{
            'amount': '€85.00 EUR',
          }),
        ),
        findsOneWidget,
      );
      expect(find.textContaining('fixture-fx'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('keeps native units when EUR net cannot be computed', (
    WidgetTester tester,
  ) async {
    await pumpAmount(tester, availableFx: false);
    expect(find.text(r'Gross $120.00 USD'), findsOneWidget);
    expect(
      find.textContaining('Net needs a dated EUR exchange rate'),
      findsOneWidget,
    );
    expect(find.textContaining('€'), findsNothing);
  });

  testWidgets('does not duplicate codes for currencies without a symbol', (
    WidgetTester tester,
  ) async {
    await pumpAmount(tester, currency: const Currency(code: 'CAD'));
    expect(find.text('Gross 120.00 CAD'), findsOneWidget);
    expect(find.textContaining('CAD CAD'), findsNothing);
    expect(find.text('Net (estimated) €85.00 EUR'), findsOneWidget);
  });
}
