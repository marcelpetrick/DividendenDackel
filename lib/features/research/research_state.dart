import 'package:decimal/decimal.dart';
import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/core/errors/failure.dart';
import 'package:dividendendackel/domain/analytics/analytics.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/domain/repositories/repositories.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The selected instrument, resolved from the local cache.
final researchInstrumentProvider = StreamProvider.family<Instrument?, String>(
  (Ref ref, String instrumentId) =>
      ref.watch(instrumentRepositoryProvider).watchInstrument(instrumentId),
);

/// Complete cached dividend history for one instrument.
final researchDividendHistoryProvider =
    StreamProvider.family<List<DividendEvent>, String>(
      (Ref ref, String instrumentId) => ref
          .watch(dividendRepositoryProvider)
          .watchForInstrument(instrumentId),
    );

/// Latest cached quote for one instrument.
final researchQuoteProvider = StreamProvider.family<Quote?, String>(
  (Ref ref, String instrumentId) =>
      ref.watch(marketDataRepositoryProvider).watchQuote(instrumentId),
);

/// Upcoming earnings over the next year for one instrument.
final researchEarningsProvider =
    StreamProvider.family<List<EarningsEvent>, String>((
      Ref ref,
      String instrumentId,
    ) {
      final DateTime start = _utcDay(ref.watch(clockProvider).now());
      return ref
          .watch(marketDataRepositoryProvider)
          .watchEarningsInRange(
            DateRange.days(start, 365),
            instrumentIds: <String>{instrumentId},
          );
    });

/// Upcoming non-earnings events over the next year.
final researchCorporateEventsProvider =
    StreamProvider.family<List<CorporateEvent>, String>((
      Ref ref,
      String instrumentId,
    ) {
      final DateTime start = _utcDay(ref.watch(clockProvider).now());
      return ref
          .watch(marketDataRepositoryProvider)
          .watchCorporateEventsInRange(
            DateRange.days(start, 365),
            instrumentIds: <String>{instrumentId},
          );
    });

/// Recent attributable headline metadata.
final researchNewsProvider = StreamProvider.family<List<NewsItem>, String>(
  (Ref ref, String instrumentId) => ref
      .watch(marketDataRepositoryProvider)
      .watchRecentNews(instrumentIds: <String>{instrumentId}, limit: 50),
);

/// Recent source-linked filings.
final researchFilingsProvider = StreamProvider.family<List<Filing>, String>(
  (Ref ref, String instrumentId) => ref
      .watch(marketDataRepositoryProvider)
      .watchRecentFilings(instrumentIds: <String>{instrumentId}, limit: 50),
);

/// Persisted research-score history, newest first.
final researchHistoryProvider =
    StreamProvider.family<List<ResearchSnapshot>, String>(
      (Ref ref, String instrumentId) =>
          ref.watch(researchRepositoryProvider).watchHistory(instrumentId),
    );

/// Current assessment computed from the local evidence and retained on change.
final currentResearchSnapshotProvider =
    FutureProvider.family<ResearchSnapshot?, String>((
      Ref ref,
      String instrumentId,
    ) async {
      final Instrument? instrument = await ref.watch(
        researchInstrumentProvider(instrumentId).future,
      );
      if (instrument == null) return null;
      final (
        Quote?,
        List<DividendEvent>,
        List<EarningsEvent>,
        List<NewsItem>,
        List<Filing>,
      )
      evidence = await (
        ref.watch(researchQuoteProvider(instrumentId).future),
        ref.watch(researchDividendHistoryProvider(instrumentId).future),
        ref.watch(researchEarningsProvider(instrumentId).future),
        ref.watch(researchNewsProvider(instrumentId).future),
        ref.watch(researchFilingsProvider(instrumentId).future),
      ).wait;
      final ResearchSnapshot? snapshot = buildResearchSnapshot(
        instrument: instrument,
        quote: evidence.$1,
        dividends: evidence.$2,
        earnings: evidence.$3,
        news: evidence.$4,
        filings: evidence.$5,
        asOf: ref.watch(clockProvider).now(),
      );
      if (snapshot == null) return null;
      final Failure? failure =
          (await ref.watch(researchRepositoryProvider).saveIfChanged(snapshot))
              .failureOrNull;
      if (failure != null) {
        ref
            .watch(loggerProvider)
            .scoped(component: 'research')
            .warning(
              'could not retain research snapshot',
              operation: 'save-snapshot',
              error: failure,
              fields: <String, Object?>{'instrumentId': instrumentId},
            );
      }
      return snapshot;
    });

/// Pure adapter from cached records to the six-dimension scoring contract.
ResearchSnapshot? buildResearchSnapshot({
  required Instrument instrument,
  required Quote? quote,
  required List<DividendEvent> dividends,
  required List<EarningsEvent> earnings,
  required List<NewsItem> news,
  required List<Filing> filings,
  required DateTime asOf,
}) {
  final ScoredAssessment? dividend = const DividendQualityCalculator()
      .calculate(
        instrumentId: instrument.internalId,
        currency: instrument.currency,
        events: dividends,
        asOf: asOf,
        fundamentals: DividendQualityFundamentals(
          forwardYield: _forwardYield(
            quote: quote,
            dividends: dividends,
            asOf: asOf,
          ),
        ),
      );
  final DateTime today = _utcDay(asOf);
  final EarningsEvent? nextEarnings = earnings
      .where(
        (EarningsEvent event) => !event.scheduledFor.toUtc().isBefore(today),
      )
      .fold<EarningsEvent?>(null, (
        EarningsEvent? nearest,
        EarningsEvent event,
      ) {
        if (nearest == null ||
            event.scheduledFor.toUtc().isBefore(nearest.scheduledFor.toUtc())) {
          return event;
        }
        return nearest;
      });
  final DateTime thirtyDaysAgo = asOf.toUtc().subtract(
    const Duration(days: 30),
  );
  final DateTime sevenDaysAgo = asOf.toUtc().subtract(const Duration(days: 7));
  final int recentNews = news
      .where(
        (NewsItem item) => !item.publishedAt.toUtc().isBefore(sevenDaysAgo),
      )
      .length;
  final Percentage? dayChange = quote?.changePercent;
  final EventRiskResearchMetrics eventRisk = EventRiskResearchMetrics(
    daysUntilEarnings: nextEarnings == null
        ? null
        : _utcDay(nextEarnings.scheduledFor).difference(today).inDays,
    recentGuidanceChange:
        news.any(
          (NewsItem item) =>
              item.category == NewsCategory.guidance &&
              !item.publishedAt.toUtc().isBefore(thirtyDaysAgo),
        )
        ? true
        : null,
    abnormalVolatility:
        dayChange != null &&
            dayChange.rate.abs() >= Percentage.parsePercent('5').rate
        ? true
        : null,
    recentMaterialFiling:
        filings.any(
          (Filing filing) =>
              filing.isMaterialForm &&
              !filing.filedAt.toUtc().isBefore(thirtyDaysAgo),
        )
        ? true
        : null,
    elevatedNewsActivity: recentNews >= 5 ? true : null,
  );
  final List<HasProvenance> sources = <HasProvenance>[
    ?quote,
    ...dividends,
    ...earnings,
    ...news,
    ...filings,
  ];
  if (dividend == null &&
      eventRisk.daysUntilEarnings == null &&
      eventRisk.recentGuidanceChange == null &&
      eventRisk.abnormalVolatility == null &&
      eventRisk.recentMaterialFiling == null &&
      eventRisk.elevatedNewsActivity == null) {
    return null;
  }
  return const ResearchScoreCalculator().calculate(
    instrumentId: instrument.internalId,
    asOf: asOf,
    provenance: _derivedProvenance(sources, asOf),
    input: ResearchScoreInput(dividend: dividend, eventRisk: eventRisk),
  );
}

Percentage? _forwardYield({
  required Quote? quote,
  required List<DividendEvent> dividends,
  required DateTime asOf,
}) {
  if (quote == null ||
      quote.price.amount <= Decimal.zero ||
      dividends.any(
        (DividendEvent event) =>
            event.amountPerShare.currency != quote.price.currency,
      )) {
    return null;
  }
  final DateTime start = asOf.toUtc();
  final DateTime end = start.add(const Duration(days: 365));
  Decimal total = Decimal.zero;
  for (final DividendEvent event in dividends) {
    final DateTime? date = event.paymentDate ?? event.exDate;
    if (date != null &&
        !date.toUtc().isBefore(start) &&
        date.toUtc().isBefore(end)) {
      total += event.amountPerShare.amount;
    }
  }
  if (total <= Decimal.zero) return null;
  return Percentage.fromRate(
    (total / quote.price.amount).toDecimal(scaleOnInfinitePrecision: 10),
  );
}

Provenance _derivedProvenance(List<HasProvenance> sources, DateTime fallback) {
  if (sources.isEmpty) {
    return Provenance(
      source: 'derived',
      fetchedAt: fallback,
      confidence: Confidence.low,
    );
  }
  DateTime fetchedAt = sources.first.provenance.fetchedAt;
  bool allSample = true;
  bool stale = false;
  for (final HasProvenance source in sources) {
    final Provenance value = source.provenance;
    if (value.fetchedAt.isAfter(fetchedAt)) fetchedAt = value.fetchedAt;
    allSample = allSample && value.source == Provenance.sampleSource;
    stale = stale || value.isStale;
  }
  return Provenance(
    source: allSample ? Provenance.sampleSource : 'derived',
    fetchedAt: fetchedAt,
    cacheState: stale ? CacheState.stale : CacheState.fresh,
    confidence: Confidence.medium,
  );
}

DateTime _utcDay(DateTime value) {
  final DateTime utc = value.toUtc();
  return DateTime.utc(utc.year, utc.month, utc.day);
}
