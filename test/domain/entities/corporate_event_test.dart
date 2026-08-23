import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime now = DateTime.utc(2026, 8, 23);
  final Provenance provenance = Provenance(source: 'test', fetchedAt: now);

  CorporateEvent event(CorporateEventStatus status) => CorporateEvent(
    id: 'event-1',
    instrumentId: 'instrument-1',
    scheduledFor: now.add(const Duration(days: 1)),
    type: CorporateEventType.investorDay,
    status: status,
    title: 'Capital markets day',
    provenance: provenance,
  );

  test('only active lifecycle states are upcoming', () {
    expect(event(CorporateEventStatus.estimated).isUpcoming, isTrue);
    expect(event(CorporateEventStatus.confirmed).isUpcoming, isTrue);
    expect(event(CorporateEventStatus.completed).isUpcoming, isFalse);
    expect(event(CorporateEventStatus.cancelled).isUpcoming, isFalse);
  });

  test('stable identity deduplicates provider updates', () {
    expect(
      event(CorporateEventStatus.estimated),
      event(CorporateEventStatus.confirmed),
    );
  });
}
