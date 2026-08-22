import 'package:dividendendackel/domain/entities/provenance.dart';

/// A regulatory filing, e.g. a SEC 10-K, 10-Q or 8-K (Vision.md §46).
final class Filing implements HasProvenance {
  /// Creates a filing.
  const Filing({
    required this.id,
    required this.instrumentId,
    required this.formType,
    required this.filedAt,
    required this.url,
    required this.provenance,
    this.title,
    this.periodOfReport,
  });

  /// Stable identifier, e.g. the SEC accession number.
  final String id;

  /// The filing company's instrument, by app-internal id.
  final String instrumentId;

  /// Form type as published, e.g. `10-K`.
  final String formType;

  /// When it was filed.
  final DateTime filedAt;

  /// Link to the filing at its source.
  final Uri url;

  /// Human-readable description, when the provider supplies one.
  final String? title;

  /// The period the filing reports on, when known.
  final DateTime? periodOfReport;

  @override
  final Provenance provenance;

  /// Whether this is one of the periodic or current reports that usually
  /// matter to a holder.
  bool get isMaterialForm => const <String>{
    '10-K',
    '10-Q',
    '8-K',
    '20-F',
    '6-K',
  }.contains(formType.toUpperCase());

  @override
  String toString() => 'Filing($formType, $instrumentId, $filedAt)';

  @override
  bool operator ==(Object other) => other is Filing && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
