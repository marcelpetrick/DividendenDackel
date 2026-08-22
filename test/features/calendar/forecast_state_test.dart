import 'dart:async';

import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/core/errors/result.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/domain/repositories/repositories.dart';
import 'package:dividendendackel/features/calendar/forecast_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime now = DateTime.utc(2026, 8, 23);
  final Provenance provenance = Provenance(source: 'test', fetchedAt: now);
  DividendEvent event({DateTime? exDate, DateTime? paymentDate}) =>
      DividendEvent(
        instrumentId: 'a',
        amountPerShare: Money.parse('1', Currency.eur),
        status: DividendStatus.confirmed,
        exDate: exDate,
        paymentDate: paymentDate,
        provenance: provenance,
      );

  test('merges ex-date and payment-date inputs without duplicates', () async {
    final DividendEvent both = event(
      exDate: DateTime.utc(2026, 8, 1),
      paymentDate: DateTime.utc(2026, 8, 10),
    );
    final DividendEvent paymentOnly = event(paymentDate: DateTime.utc(2026, 9));
    final ProviderContainer container = ProviderContainer(
      overrides: [
        dividendRepositoryProvider.overrideWithValue(
          _FakeDividendRepository(
            exDates: <DividendEvent>[both],
            paymentDates: <DividendEvent>[both, paymentOnly],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final provider = forecastSourceEventsProvider(
      ForecastEventsQuery(
        range: DateRange(DateTime.utc(2026), DateTime.utc(2027)),
        instrumentIds: <String>{'a'},
      ),
    );
    final Completer<List<DividendEvent>> complete =
        Completer<List<DividendEvent>>();
    final ProviderSubscription<AsyncValue<List<DividendEvent>>> subscription =
        container.listen(provider, (previous, next) {
          if (next.value case final List<DividendEvent> value
              when value.length == 2) {
            complete.complete(value);
          }
        });
    addTearDown(subscription.close);
    final List<DividendEvent> result = await complete.future;

    expect(result, <DividendEvent>[both, paymentOnly]);
  });

  test('query identity is order-independent and defensively copied', () {
    final Set<String> ids = <String>{'a', 'b'};
    final ForecastEventsQuery left = ForecastEventsQuery(
      range: DateRange(DateTime(2026), DateTime(2027)),
      instrumentIds: ids,
    );
    final ForecastEventsQuery right = ForecastEventsQuery(
      range: DateRange(DateTime(2026), DateTime(2027)),
      instrumentIds: <String>{'b', 'a'},
    );

    ids.add('later');
    expect(left, right);
    expect(left.hashCode, right.hashCode);
    expect(left.instrumentIds, <String>{'a', 'b'});
  });
}

final class _FakeDividendRepository implements DividendRepository {
  const _FakeDividendRepository({
    required this.exDates,
    required this.paymentDates,
  });
  final List<DividendEvent> exDates;
  final List<DividendEvent> paymentDates;

  @override
  Stream<List<DividendEvent>> watchInRange(
    DateRange range,
    DividendDateMode mode, {
    Set<String>? instrumentIds,
  }) => Stream<List<DividendEvent>>.value(
    mode == DividendDateMode.exDate ? exDates : paymentDates,
  );

  @override
  Stream<List<DividendEvent>> watchForInstrument(String instrumentId) =>
      const Stream<List<DividendEvent>>.empty();

  @override
  Future<Result<void>> saveAll(
    List<DividendEvent> events, {
    required String Function(DividendEvent event) idOf,
  }) async => const Result<void>.success(null);
}
