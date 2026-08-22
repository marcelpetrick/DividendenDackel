import 'package:dividendendackel/data/tax/withholding_rate_loader.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'bundled table is versioned, dated and carries required country cases',
    () async {
      final table = await WithholdingRateLoader.load();

      expect(table.version, 1);
      expect(table.asOf, DateTime(2024));
      expect(table.source, contains('Bundeszentralamt'));
      expect(
        table.rates.keys,
        containsAll(<String>['DE', 'US', 'CH', 'GB', 'NL']),
      );
      expect(table['US']!.treatyRateWithForms, Percentage.parsePercent('15'));
      expect(table['CH']!.creditableCap, Percentage.parsePercent('15'));
    },
  );

  test('rejects malformed or out-of-range imported tables', () {
    expect(
      () => WithholdingRateLoader.parse(
        '{"version":1,"asOf":"2024-01-01","source":"x",'
        '"sourceUrl":"x","rates":{"USA":{"statutory":"15",'
        '"treatyWithForms":"15","creditableCap":"15"}}}',
      ),
      throwsFormatException,
    );
    expect(
      () => WithholdingRateLoader.parse(
        '{"version":1,"asOf":"2024-01-01","source":"x",'
        '"sourceUrl":"x","rates":{"US":{"statutory":"101",'
        '"treatyWithForms":"15","creditableCap":"15"}}}',
      ),
      throwsArgumentError,
    );
  });
}
