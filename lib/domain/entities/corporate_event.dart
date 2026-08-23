import 'package:dividendendackel/domain/entities/provenance.dart';

/// Kind of scheduled company event that may matter to an investor.
enum CorporateEventType {
  /// Annual or extraordinary shareholder meeting.
  shareholderMeeting,

  /// Investor, strategy or capital-markets presentation.
  investorDay,

  /// A split or reverse split becomes effective.
  shareSplit,

  /// A merger, acquisition or spin-off milestone.
  transaction,

  /// A capital increase, tender or buyback milestone.
  capitalAction,

  /// A product or operational event published by the company.
  companyUpdate,

  /// A regulatory hearing, decision or deadline.
  regulatory,

  /// Provider-described event outside the normalized categories.
  other,
}

/// How firm a corporate-event date is.
enum CorporateEventStatus { estimated, confirmed, completed, cancelled }

/// A dated company event other than an earnings or dividend event.
final class CorporateEvent implements HasProvenance {
  /// Creates a normalized corporate event.
  const CorporateEvent({
    required this.id,
    required this.instrumentId,
    required this.scheduledFor,
    required this.type,
    required this.status,
    required this.title,
    required this.provenance,
    this.url,
  });

  /// Stable provider or locally generated identifier.
  final String id;

  /// Company instrument, by app-internal id.
  final String instrumentId;

  /// Calendar date or timestamp supplied by the source.
  final DateTime scheduledFor;

  /// Normalized event category.
  final CorporateEventType type;

  /// Whether the event is estimated, confirmed, completed or cancelled.
  final CorporateEventStatus status;

  /// Source-supplied human-readable label.
  final String title;

  /// Optional original source page.
  final Uri? url;

  @override
  final Provenance provenance;

  /// Whether the event should appear in an upcoming-events view.
  bool get isUpcoming =>
      status != CorporateEventStatus.completed &&
      status != CorporateEventStatus.cancelled;

  @override
  bool operator ==(Object other) => other is CorporateEvent && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
