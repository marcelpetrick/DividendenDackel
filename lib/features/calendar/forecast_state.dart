import 'dart:async';

import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/domain/repositories/repositories.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Range and holdings required as forecast-engine input.
final class ForecastEventsQuery {
  /// Creates a query with a defensive copy of [instrumentIds].
  ForecastEventsQuery({required this.range, required Set<String> instrumentIds})
    : instrumentIds = Set<String>.unmodifiable(instrumentIds);

  /// Historical plus future input range.
  final DateRange range;

  /// Instruments currently held.
  final Set<String> instrumentIds;

  @override
  bool operator ==(Object other) =>
      other is ForecastEventsQuery &&
      other.range == range &&
      other.instrumentIds.length == instrumentIds.length &&
      other.instrumentIds.containsAll(instrumentIds);

  @override
  int get hashCode {
    final List<String> ids = instrumentIds.toList()..sort();
    return Object.hash(range, Object.hashAll(ids));
  }
}

/// Dividend inputs found by either ex-date or payment date.
///
/// Forecast logic needs seasonality from either date, while cash-income views
/// need payment dates. Merging both repository queries prevents an event with
/// one unknown date from disappearing from the calculation.
final forecastSourceEventsProvider =
    StreamProvider.family<List<DividendEvent>, ForecastEventsQuery>((
      Ref ref,
      ForecastEventsQuery query,
    ) {
      final DividendRepository repository = ref.watch(
        dividendRepositoryProvider,
      );
      return _mergeEvents(
        repository.watchInRange(
          query.range,
          DividendDateMode.exDate,
          instrumentIds: query.instrumentIds,
        ),
        repository.watchInRange(
          query.range,
          DividendDateMode.paymentDate,
          instrumentIds: query.instrumentIds,
        ),
      );
    });

Stream<List<DividendEvent>> _mergeEvents(
  Stream<List<DividendEvent>> exDates,
  Stream<List<DividendEvent>> paymentDates,
) {
  late StreamController<List<DividendEvent>> controller;
  StreamSubscription<List<DividendEvent>>? exSubscription;
  StreamSubscription<List<DividendEvent>>? paymentSubscription;
  List<DividendEvent> ex = const <DividendEvent>[];
  List<DividendEvent> payments = const <DividendEvent>[];

  void emit() {
    final List<DividendEvent> merged =
        <DividendEvent>{...ex, ...payments}.toList()
          ..sort((DividendEvent left, DividendEvent right) {
            final DateTime? leftDate = left.paymentDate ?? left.exDate;
            final DateTime? rightDate = right.paymentDate ?? right.exDate;
            if (leftDate == null) return rightDate == null ? 0 : 1;
            if (rightDate == null) return -1;
            return leftDate.compareTo(rightDate);
          });
    controller.add(List<DividendEvent>.unmodifiable(merged));
  }

  controller = StreamController<List<DividendEvent>>(
    onListen: () {
      exSubscription = exDates.listen((List<DividendEvent> value) {
        ex = value;
        emit();
      }, onError: controller.addError);
      paymentSubscription = paymentDates.listen((List<DividendEvent> value) {
        payments = value;
        emit();
      }, onError: controller.addError);
    },
    onCancel: () async {
      await exSubscription?.cancel();
      await paymentSubscription?.cancel();
      if (!controller.isClosed) {
        await controller.close();
      }
    },
  );
  return controller.stream;
}
