import 'package:dividendendackel/domain/entities/provenance.dart';

/// What a news item is about (Vision.md §18).
enum NewsCategory {
  /// Results and reporting.
  earnings,

  /// Dividend announcements, increases and cuts.
  dividends,

  /// Outlook changes.
  guidance,

  /// Mergers and acquisitions.
  mergersAndAcquisitions,

  /// Board and executive changes.
  management,

  /// Regulatory and legal developments.
  regulation,

  /// Products and operations.
  product,

  /// Analyst actions.
  analyst,

  /// Regulatory filings.
  filing,

  /// Broad market and economy.
  macro,

  /// Anything else.
  general,
}

/// A headline related to one or more instruments.
///
/// The app links to the original source rather than republishing article text
/// (Vision.md §18), so the entity holds metadata and at most a provider-supplied
/// summary — never a full article body.
final class NewsItem implements HasProvenance {
  /// Creates a news item.
  const NewsItem({
    required this.id,
    required this.headline,
    required this.sourceName,
    required this.publishedAt,
    required this.url,
    required this.provenance,
    this.category = NewsCategory.general,
    this.summary,
    this.relatedInstrumentIds = const <String>[],
    this.relevance,
  });

  /// Stable identifier, used to deduplicate across providers.
  final String id;

  /// The headline as published.
  final String headline;

  /// Publication name, e.g. `Reuters`.
  final String sourceName;

  /// When it was published.
  final DateTime publishedAt;

  /// Link to the original article.
  final Uri url;

  /// What the item is about.
  final NewsCategory category;

  /// Short provider-supplied summary, when one exists.
  final String? summary;

  /// Instruments this item concerns, by app-internal id.
  final List<String> relatedInstrumentIds;

  /// Relevance to the user's portfolio, from 0 to 1.
  ///
  /// Assigned by the ranking use case rather than by a provider (Vision.md
  /// §17), and `null` until ranking has run.
  final double? relevance;

  @override
  final Provenance provenance;

  /// Whether this item concerns [instrumentId].
  bool concerns(String instrumentId) =>
      relatedInstrumentIds.contains(instrumentId);

  /// Returns a copy carrying a computed [relevance].
  NewsItem withRelevance(double relevance) => NewsItem(
    id: id,
    headline: headline,
    sourceName: sourceName,
    publishedAt: publishedAt,
    url: url,
    provenance: provenance,
    category: category,
    summary: summary,
    relatedInstrumentIds: relatedInstrumentIds,
    relevance: relevance,
  );

  @override
  String toString() => 'NewsItem($id, ${category.name}, $sourceName)';

  @override
  bool operator ==(Object other) => other is NewsItem && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
