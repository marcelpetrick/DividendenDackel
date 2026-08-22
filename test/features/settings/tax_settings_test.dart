import 'package:dividendendackel/domain/analytics/analytics.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/features/settings/tax_settings.dart';
import 'package:dividendendackel/features/settings/tax_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final WithholdingRateTable table = _table();

  test('codec round-trips profile assumptions and edited rates', () {
    final TaxSettings original = TaxSettings(
      profile: DividendTaxProfile(
        taxResidenceCountry: 'DE',
        assessment: TaxAssessment.joint,
        churchTaxRate: ChurchTaxRate.ninePercent,
        annualAllowance: Money.parse('2100', Currency.eur),
        allowanceAlreadyUsed: Money.parse('125.50', Currency.eur),
        treatyFormsFiled: const <String, bool>{'US': false},
      ),
      table: table,
    );

    final TaxSettings decoded = TaxSettingsCodec.decode(
      TaxSettingsCodec.encode(original),
      table,
    );

    expect(decoded.profile.assessment, TaxAssessment.joint);
    expect(decoded.profile.churchTaxRate, ChurchTaxRate.ninePercent);
    expect(decoded.profile.annualAllowance, Money.parse('2100', Currency.eur));
    expect(
      decoded.profile.allowanceAlreadyUsed,
      Money.parse('125.50', Currency.eur),
    );
    expect(decoded.profile.formsFiledFor('US'), isFalse);
    expect(decoded.table['US']!.statutoryRate, Percentage.parsePercent('30'));
    expect(decoded.table.version, table.version);
    expect(decoded.table.sourceUrl, table.sourceUrl);
  });

  testWidgets('shows defaults and persists assessment changes', (
    WidgetTester tester,
  ) async {
    final _Store store = _Store();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [taxSettingsStoreProvider.overrideWithValue(store)],
        child: const MaterialApp(home: TaxSettingsScreen()),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(find.text('Dividend tax estimate'), findsOneWidget);
    expect(find.textContaining('not tax advice'), findsOneWidget);
    expect(find.text('Annual savings allowance'), findsOneWidget);
    expect(find.text('€1000.00'), findsOneWidget);

    await tester.tap(find.text('Joint'));
    await tester.pump();
    await tester.pump();

    expect(find.text('€2000.00'), findsOneWidget);
    expect(store.saved?.profile.assessment, TaxAssessment.joint);
  });
}

WithholdingRateTable _table() => WithholdingRateTable(
  version: 3,
  asOf: DateTime.utc(2024),
  source: 'Official test source',
  sourceUrl: 'https://example.invalid/source',
  rates: <String, WithholdingRule>{
    'DE': WithholdingRule(
      country: 'DE',
      statutoryRate: Percentage.zero,
      treatyRateWithForms: Percentage.zero,
      creditableCap: Percentage.zero,
    ),
    'US': WithholdingRule(
      country: 'US',
      statutoryRate: Percentage.parsePercent('30'),
      treatyRateWithForms: Percentage.parsePercent('15'),
      creditableCap: Percentage.parsePercent('15'),
    ),
  },
);

final class _Store implements TaxSettingsStore {
  TaxSettings? saved;

  @override
  Future<TaxSettings> load(WithholdingRateTable defaults) async =>
      TaxSettings(profile: DividendTaxProfile(), table: _table());

  @override
  Future<void> save(TaxSettings settings) async => saved = settings;
}
