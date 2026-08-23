import 'package:decimal/decimal.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/features/today/today_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime firstAt = DateTime.utc(2026, 8, 20);
  final Provenance provenance = Provenance(source: 'test', fetchedAt: firstAt);

  test('codec round-trips the privacy-safe refresh baseline', () {
    final TodaySnapshot original = TodaySnapshot(
      capturedAt: firstAt,
      holdings: const <String, String>{'one': '2.5'},
      dividends: const <String, String>{'one|date': 'EUR|2|announced'},
      quotes: const <String, String>{'one': 'EUR:100'},
    );
    final TodaySnapshot decoded = TodaySnapshotCodec.decode(
      TodaySnapshotCodec.encode(original),
    );
    expect(decoded.capturedAt, original.capturedAt);
    expect(decoded.holdings, original.holdings);
    expect(decoded.dividends, original.dividends);
    expect(decoded.quotes, original.quotes);
  });

  test('counts added, removed and modified records by category', () {
    final TodaySnapshot previous = TodaySnapshot(
      capturedAt: firstAt,
      holdings: const <String, String>{'one': '1', 'removed': '2'},
      dividends: const <String, String>{'event': 'EUR|1|expected'},
      quotes: const <String, String>{'one': 'EUR:90'},
    );
    final TodaySnapshot current = TodaySnapshot(
      capturedAt: firstAt.add(const Duration(days: 1)),
      holdings: const <String, String>{'one': '2', 'added': '1'},
      dividends: const <String, String>{'event': 'EUR|2|announced'},
      quotes: const <String, String>{'one': 'EUR:100'},
    );

    final TodayChanges changes = TodayChangesCalculator.compare(
      previous,
      current,
    );
    expect(changes.holdingChanges, 3);
    expect(changes.dividendChanges, 1);
    expect(changes.quoteChanges, 1);
    expect(changes.hasChanges, isTrue);
  });

  test('snapshot fingerprints quantities, outlook and quotes', () {
    final Holding holding = Holding(
      instrumentId: 'one',
      quantity: Decimal.parse('2.5'),
      provenance: provenance,
    );
    final DividendEvent dividend = DividendEvent(
      instrumentId: 'one',
      amountPerShare: Money.parse('2', Currency.eur),
      status: DividendStatus.announced,
      exDate: DateTime.utc(2026, 9, 1),
      paymentDate: DateTime.utc(2026, 9, 3),
      provenance: provenance,
    );
    final Quote quote = Quote(
      instrumentId: 'one',
      price: Money.parse('100', Currency.eur),
      asOf: firstAt,
      provenance: provenance,
    );

    final TodaySnapshot snapshot = TodayChangesCalculator.snapshot(
      capturedAt: firstAt,
      holdings: <Holding>[holding],
      dividends: <DividendEvent>[dividend],
      quotes: <String, Quote>{'one': quote},
    );
    expect(snapshot.holdings['one'], '2.5');
    expect(snapshot.dividends.values.single, 'EUR|2|announced');
    expect(snapshot.quotes['one'], 'EUR:100');
  });
}
