import 'package:dividendendackel/app/localization/localized_material.dart';
import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/app/theme/app_theme.dart';
import 'package:dividendendackel/app/widgets/gross_net_amount.dart';
import 'package:dividendendackel/app/widgets/value_labels.dart';
import 'package:dividendendackel/domain/analytics/analytics.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/features/news/news_link_launcher.dart';
import 'package:dividendendackel/features/tax/tax_estimates.dart';
import 'package:dividendendackel/features/today/today_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The central product experience (Vision.md §7).
///
/// Answers what matters today and what happens next. It must stay useful when
/// live quotes are unavailable, so every figure here degrades to "not known
/// yet" rather than to zero.
class TodayScreen extends ConsumerWidget {
  /// Creates the Today screen.
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateTime now = ref.watch(clockProvider).now();
    final AsyncValue<List<DividendEvent>> next3Ex = ref.watch(
      upcomingDividendsProvider(3),
    );
    final AsyncValue<List<DividendEvent>> next365 = ref.watch(
      upcomingDividendPaymentsProvider(365),
    );
    final AsyncValue<List<DividendEvent>> next3Payments = upcomingWindow(
      source: next365,
      now: now,
      days: 3,
      dateOf: (DividendEvent event) => event.paymentDate,
    );
    final AsyncValue<List<DividendEvent>> next7 = upcomingWindow(
      source: next365,
      now: now,
      days: 7,
      dateOf: (DividendEvent event) => event.paymentDate,
    );
    final AsyncValue<List<DividendEvent>> next30 = upcomingWindow(
      source: next365,
      now: now,
      days: 30,
      dateOf: (DividendEvent event) => event.paymentDate,
    );
    final AsyncValue<List<EarningsEvent>> next30Earnings = ref.watch(
      upcomingEarningsProvider(30),
    );
    final AsyncValue<List<CorporateEvent>> next30Corporate = ref.watch(
      upcomingCorporateEventsProvider(30),
    );
    final AsyncValue<List<EarningsEvent>> next3Earnings = upcomingWindow(
      source: next30Earnings,
      now: now,
      days: 3,
      dateOf: (EarningsEvent event) => event.scheduledFor,
    );
    final AsyncValue<List<CorporateEvent>> next3Corporate = upcomingWindow(
      source: next30Corporate,
      now: now,
      days: 3,
      dateOf: (CorporateEvent event) => event.scheduledFor,
    );
    final AsyncValue<List<NewsItem>> news = ref.watch(
      recentPortfolioNewsProvider,
    );
    final AsyncValue<Map<String, Instrument>> instrumentValue = ref.watch(
      instrumentsByIdProvider,
    );
    final Map<String, Instrument> instruments =
        instrumentValue.value ?? const <String, Instrument>{};
    final AsyncValue<List<Holding>> holdings = ref.watch(holdingsProvider);
    final AsyncValue<List<WatchlistEntry>> watchlist = ref.watch(
      watchlistProvider,
    );
    final AsyncValue<Map<String, Quote>> quoteValue = ref.watch(quotesProvider);
    final Map<String, Quote> quotes =
        quoteValue.value ?? const <String, Quote>{};
    final Map<String, Holding> holdingsByInstrument = <String, Holding>{
      for (final Holding holding in holdings.value ?? const <Holding>[])
        holding.instrumentId: holding,
    };
    final PortfolioOverview? overview = holdings.value == null
        ? null
        : const PortfolioOverviewCalculator().calculate(
            holdings: holdings.requireValue,
            instruments: instruments,
            quotes: quotes,
            dividends: next365.value ?? const <DividendEvent>[],
            asOf: now,
          );
    final Map<String, double> holdingWeights = <String, double>{
      for (final PortfolioPositionSummary position
          in overview?.positions ?? const <PortfolioPositionSummary>[])
        if (position.allocation case final Percentage allocation)
          position.holding.instrumentId: allocation.rate.toDouble(),
    };

    return ListView(
      padding: const EdgeInsets.all(AppTheme.space * 2),
      children: <Widget>[
        if (holdings.hasError ||
            watchlist.hasError ||
            instrumentValue.hasError ||
            quoteValue.hasError) ...<Widget>[
          const _PartialDataNotice(
            'Some saved portfolio details could not be read. Available '
            'events and values remain visible; missing values are unavailable.',
          ),
          const SizedBox(height: AppTheme.space),
        ],
        _SummaryCard(
          holdingCount: holdings.value?.length,
          relevantCount:
              next3Ex.hasValue &&
                  next3Payments.hasValue &&
                  next3Earnings.hasValue &&
                  next3Corporate.hasValue
              ? next3Ex.requireValue.length +
                    next3Payments.requireValue.length +
                    next3Earnings.requireValue.length +
                    next3Corporate.requireValue.length
              : null,
          overview: overview,
          quoteDataAvailable: quoteValue.hasValue,
          holdingsFailed: holdings.hasError,
          eventsFailed:
              next3Ex.hasError ||
              next3Payments.hasError ||
              next3Earnings.hasError ||
              next3Corporate.hasError,
        ),
        const SizedBox(height: AppTheme.space * 2),
        _TodayMattersCard(
          exEvents: next3Ex,
          paymentEvents: next3Payments,
          earningsEvents: next3Earnings,
          corporateEvents: next3Corporate,
          news: news,
          instruments: instruments,
          holdings: holdingsByInstrument,
          watchlistIds: <String>{
            for (final WatchlistEntry entry
                in watchlist.value ?? const <WatchlistEntry>[])
              entry.instrumentId,
          },
          holdingWeights: holdingWeights,
          launcher: ref.watch(newsLinkLauncherProvider),
          now: now,
        ),
        const SizedBox(height: AppTheme.space * 2),
        _NextThreeDaysCard(
          exEvents: next3Ex,
          paymentEvents: next3Payments,
          earningsEvents: next3Earnings,
          corporateEvents: next3Corporate,
        ),
        const SizedBox(height: AppTheme.space * 2),
        _UpcomingCompanyEventsCard(
          earningsEvents: next30Earnings,
          corporateEvents: next30Corporate,
          instruments: instruments,
          now: now,
        ),
        const SizedBox(height: AppTheme.space * 2),
        _ExpectedDividendsCard(
          next7: next7,
          next30: next30,
          next365: next365,
          holdings: holdings.value ?? const <Holding>[],
        ),
        const SizedBox(height: AppTheme.space * 2),
        _ChangesCard(changes: ref.watch(todayChangesProvider)),
      ],
    );
  }
}

class _PartialDataNotice extends StatelessWidget {
  const _PartialDataNotice(this.message);

  final String message;

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    borderRadius: BorderRadius.circular(AppTheme.cardRadius),
    child: Padding(
      padding: const EdgeInsets.all(AppTheme.space),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.warning_amber_outlined, size: 20),
          const SizedBox(width: AppTheme.space),
          Expanded(child: Text(message)),
        ],
      ),
    ),
  );
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.holdingCount,
    required this.relevantCount,
    required this.overview,
    required this.quoteDataAvailable,
    required this.holdingsFailed,
    required this.eventsFailed,
  });

  final int? holdingCount;
  final int? relevantCount;
  final PortfolioOverview? overview;
  final bool quoteDataAvailable;
  final bool holdingsFailed;
  final bool eventsFailed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Portfolio today', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppTheme.space),
            Text(
              holdingCount == null
                  ? holdingsFailed
                        ? 'Holdings unavailable'
                        : 'Loading your holdings…'
                  : '$holdingCount holdings',
              style: theme.textTheme.bodyLarge,
            ),
            Text(
              relevantCount == null
                  ? eventsFailed
                        ? 'Next-three-days summary unavailable'
                        : 'Loading the next 3 days…'
                  : '$relevantCount relevant event(s) in the next 3 days',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppTheme.space),
            if (overview == null)
              const Text('Loading cached portfolio values…')
            else if (!quoteDataAvailable ||
                overview!.byCurrency.values.every(
                  (PortfolioCurrencySummary summary) =>
                      summary.pricedPositionCount == 0,
                ))
              const Text(
                'No cached quotes. Holdings and the dividend schedule below '
                'still work offline.',
              )
            else
              for (final PortfolioCurrencySummary summary
                  in overview!.byCurrency.values)
                if (summary.pricedPositionCount > 0)
                  Wrap(
                    spacing: AppTheme.space,
                    children: <Widget>[
                      MoneyText(
                        summary.totalValue,
                        style: theme.textTheme.titleLarge,
                      ),
                      Text(
                        summary.dayChange == null
                            ? 'day change unavailable'
                            : '${summary.dayChange!.format(withSymbol: true)} today',
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

class _TodayMattersCard extends StatelessWidget {
  const _TodayMattersCard({
    required this.exEvents,
    required this.paymentEvents,
    required this.earningsEvents,
    required this.corporateEvents,
    required this.news,
    required this.instruments,
    required this.holdings,
    required this.watchlistIds,
    required this.holdingWeights,
    required this.launcher,
    required this.now,
  });
  final AsyncValue<List<DividendEvent>> exEvents;
  final AsyncValue<List<DividendEvent>> paymentEvents;
  final AsyncValue<List<EarningsEvent>> earningsEvents;
  final AsyncValue<List<CorporateEvent>> corporateEvents;
  final AsyncValue<List<NewsItem>> news;
  final Map<String, Instrument> instruments;
  final Map<String, Holding> holdings;
  final Set<String> watchlistIds;
  final Map<String, double> holdingWeights;
  final NewsLinkLauncher launcher;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final List<_Matter> matters = <_Matter>[
      for (final DividendEvent event
          in exEvents.value ?? const <DividendEvent>[])
        if (event.exDate case final DateTime date)
          _Matter.dividend(event: event, date: date, kind: 'Ex-dividend'),
      for (final DividendEvent event
          in paymentEvents.value ?? const <DividendEvent>[])
        if (event.paymentDate case final DateTime date)
          _Matter.dividend(event: event, date: date, kind: 'Payment'),
      for (final EarningsEvent event
          in earningsEvents.value ?? const <EarningsEvent>[])
        _Matter.earnings(event),
      for (final CorporateEvent event
          in corporateEvents.value ?? const <CorporateEvent>[])
        _Matter.corporate(event),
      for (final NewsItem item in news.value ?? const <NewsItem>[])
        _Matter.news(item),
    ];
    final Map<String, _Matter> byId = <String, _Matter>{
      for (final _Matter matter in matters) matter.id: matter,
    };
    final List<RankedRelevance> ranked = const RelevanceRanker().rank(
      signals: matters.map((_Matter matter) => matter.signal),
      holdingIds: holdings.keys.toSet(),
      watchlistIds: watchlistIds,
      holdingWeights: holdingWeights,
      now: now,
    );
    final bool loading =
        exEvents.isLoading ||
        paymentEvents.isLoading ||
        earningsEvents.isLoading ||
        corporateEvents.isLoading ||
        news.isLoading;
    final bool failed =
        exEvents.hasError ||
        paymentEvents.hasError ||
        earningsEvents.hasError ||
        corporateEvents.hasError ||
        news.hasError;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Today matters',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.space),
            if (failed)
              const Text(
                'Some sources could not be refreshed. Cached items remain '
                'visible below.',
              ),
            if (ranked.isNotEmpty)
              for (final RankedRelevance relevance in ranked.take(5))
                _MatterTile(
                  matter: byId[relevance.signal.id]!,
                  relevance: relevance,
                  instrumentNames: <String>[
                    for (final String id in relevance.signal.instrumentIds)
                      instruments[id]?.name ?? id,
                  ],
                  holding: relevance.signal.instrumentIds
                      .map((String id) => holdings[id])
                      .whereType<Holding>()
                      .firstOrNull,
                  onOpen: byId[relevance.signal.id]!.news == null
                      ? null
                      : () => _open(context, byId[relevance.signal.id]!.news!),
                  now: now,
                )
            else if (loading)
              LinearProgressIndicator(
                semanticsLabel: context.tr('Loading events'),
              )
            else if (!failed)
              const Text(
                'No relevant portfolio events or headlines are cached.',
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context, NewsItem item) async {
    bool opened = false;
    try {
      opened = await launcher.open(item.url);
    } on Object {
      opened = false;
    }
    if (!context.mounted || opened) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Could not open the original publisher page.'),
      ),
    );
  }
}

final class _Matter {
  const _Matter._({
    required this.id,
    required this.instrumentIds,
    required this.date,
    required this.kind,
    required this.icon,
    required this.status,
    required this.relevanceKind,
    required this.relevanceTiming,
    required this.confirmed,
    this.detail,
    this.dividend,
    this.news,
  });

  factory _Matter.dividend({
    required DividendEvent event,
    required DateTime date,
    required String kind,
  }) => _Matter._(
    id:
        'dividend:$kind:${event.instrumentId}:'
        '${event.exDate?.toIso8601String()}:'
        '${event.paymentDate?.toIso8601String()}:'
        '${event.amountPerShare.currency.code}:${event.amountPerShare.amount}',
    instrumentIds: <String>[event.instrumentId],
    date: date,
    kind: kind,
    icon: kind == 'Payment'
        ? Icons.payments_outlined
        : Icons.event_available_outlined,
    status: DividendStatusChip.labelFor(event.status),
    relevanceKind: kind == 'Payment'
        ? RelevanceKind.dividendPayment
        : RelevanceKind.exDividend,
    relevanceTiming: RelevanceTiming.scheduled,
    confirmed: event.status.isConfirmedByCompany,
    dividend: event,
  );

  factory _Matter.earnings(EarningsEvent event) => _Matter._(
    id: 'earnings:${event.instrumentId}:${event.scheduledFor.toIso8601String()}',
    instrumentIds: <String>[event.instrumentId],
    date: event.scheduledFor,
    kind: 'Earnings',
    icon: Icons.assessment_outlined,
    status: _earningsStatus(event.status),
    relevanceKind: RelevanceKind.earnings,
    relevanceTiming: RelevanceTiming.scheduled,
    confirmed: event.status != EarningsStatus.estimated,
    detail: _earningsTiming(event.timing),
  );

  factory _Matter.corporate(CorporateEvent event) => _Matter._(
    id: 'corporate:${event.id}',
    instrumentIds: <String>[event.instrumentId],
    date: event.scheduledFor,
    kind: event.title,
    icon: Icons.corporate_fare_outlined,
    status: _corporateStatus(event.status),
    relevanceKind: _corporateRelevanceKind(event),
    relevanceTiming: RelevanceTiming.scheduled,
    confirmed: event.status == CorporateEventStatus.confirmed,
    detail: _corporateType(event.type),
  );

  factory _Matter.news(NewsItem item) => _Matter._(
    id: 'news:${item.id}',
    instrumentIds: item.relatedInstrumentIds,
    date: item.publishedAt,
    kind: item.headline,
    icon: Icons.article_outlined,
    status: _newsCategory(item.category),
    relevanceKind: _newsRelevanceKind(item.category),
    relevanceTiming: RelevanceTiming.published,
    confirmed: false,
    detail: item.sourceName,
    news: item,
  );

  final String id;
  final List<String> instrumentIds;
  final DateTime date;
  final String kind;
  final IconData icon;
  final String status;
  final RelevanceKind relevanceKind;
  final RelevanceTiming relevanceTiming;
  final bool confirmed;
  final String? detail;
  final DividendEvent? dividend;
  final NewsItem? news;

  RelevanceSignal get signal => RelevanceSignal(
    id: id,
    instrumentIds: instrumentIds,
    at: date,
    kind: relevanceKind,
    timing: relevanceTiming,
    confirmed: confirmed,
  );
}

class _MatterTile extends StatelessWidget {
  const _MatterTile({
    required this.matter,
    required this.relevance,
    required this.instrumentNames,
    required this.holding,
    required this.onOpen,
    required this.now,
  });
  final _Matter matter;
  final RankedRelevance? relevance;
  final List<String> instrumentNames;
  final Holding? holding;
  final VoidCallback? onOpen;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final DividendEvent? dividend = matter.dividend;
    final Money? gross = holding == null || dividend == null
        ? null
        : dividend.grossPaymentFor(holding!.quantity);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(matter.icon),
      title: matter.news != null
          ? Text(matter.news!.headline, translate: false)
          : instrumentNames.isEmpty
          ? const Text('Unknown instrument')
          : Text(instrumentNames.join(', '), translate: false),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (matter.news == null) ...<Widget>[
            Text('${matter.kind} ${_relativeDay(matter.date, now)}'),
            if (matter.detail case final String detail) Text(detail),
          ] else ...<Widget>[
            Text('${matter.detail} · ${_published(context, matter.date)}'),
            if (instrumentNames.isNotEmpty)
              Text(instrumentNames.join(', '), translate: false),
          ],
          Text(matter.status),
          if (gross != null) GrossNetAmount(event: dividend!, gross: gross),
          if (relevance case final RankedRelevance ranked)
            Text(
              'Why: ${ranked.factors.map((RelevanceFactor factor) => factor.explanation).join(' · ')}',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          if (onOpen != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onOpen,
                icon: const Icon(Icons.open_in_new, size: 16),
                label: Text(
                  matter.news!.provenance.source == Provenance.sampleSource
                      ? 'View sample source'
                      : 'Open original',
                ),
              ),
            ),
        ],
      ),
      trailing: relevance == null
          ? null
          : Semantics(
              label: context.tr(
                'Relevance score ${relevance!.score} out of 100',
              ),
              child: Chip(label: Text('${relevance!.score}/100')),
            ),
    );
  }

  static String _relativeDay(DateTime value, DateTime now) {
    final DateTime day = DateTime(value.year, value.month, value.day);
    final DateTime today = DateTime(now.year, now.month, now.day);
    final int difference = day.difference(today).inDays;
    return switch (difference) {
      0 => 'today',
      1 => 'tomorrow',
      _ => 'in $difference days',
    };
  }

  static String _published(BuildContext context, DateTime value) {
    final DateTime local = value.toLocal();
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    return '${localizations.formatMediumDate(local)} · '
        '${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(local))}';
  }
}

class _NextThreeDaysCard extends StatelessWidget {
  const _NextThreeDaysCard({
    required this.exEvents,
    required this.paymentEvents,
    required this.earningsEvents,
    required this.corporateEvents,
  });
  final AsyncValue<List<DividendEvent>> exEvents;
  final AsyncValue<List<DividendEvent>> paymentEvents;
  final AsyncValue<List<EarningsEvent>> earningsEvents;
  final AsyncValue<List<CorporateEvent>> corporateEvents;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppTheme.space * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Next 3 days', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppTheme.space),
          Text(
            earningsEvents.hasError
                ? 'Earnings: unavailable'
                : earningsEvents.value == null
                ? 'Earnings: loading…'
                : '${earningsEvents.requireValue.length} earnings event(s)',
          ),
          Text(
            exEvents.hasError
                ? 'Ex-dividend dates: unavailable'
                : exEvents.value == null
                ? 'Ex-dividend dates: loading…'
                : '${exEvents.requireValue.length} ex-dividend date(s)',
          ),
          Text(
            paymentEvents.hasError
                ? 'Payments: unavailable'
                : paymentEvents.value == null
                ? 'Payments: loading…'
                : '${paymentEvents.requireValue.length} payment date(s)',
          ),
          Text(
            corporateEvents.hasError
                ? 'Company events: unavailable'
                : corporateEvents.value == null
                ? 'Company events: loading…'
                : '${corporateEvents.requireValue.length} company event(s)',
          ),
        ],
      ),
    ),
  );
}

class _UpcomingCompanyEventsCard extends StatelessWidget {
  const _UpcomingCompanyEventsCard({
    required this.earningsEvents,
    required this.corporateEvents,
    required this.instruments,
    required this.now,
  });

  final AsyncValue<List<EarningsEvent>> earningsEvents;
  final AsyncValue<List<CorporateEvent>> corporateEvents;
  final Map<String, Instrument> instruments;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final List<_Matter> matters = <_Matter>[
      for (final EarningsEvent event
          in earningsEvents.value ?? const <EarningsEvent>[])
        _Matter.earnings(event),
      for (final CorporateEvent event
          in corporateEvents.value ?? const <CorporateEvent>[])
        _Matter.corporate(event),
    ]..sort((_Matter a, _Matter b) => a.date.compareTo(b.date));
    final bool failed = earningsEvents.hasError || corporateEvents.hasError;
    final bool loading = earningsEvents.isLoading || corporateEvents.isLoading;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Upcoming company events · 30 days',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.space),
            if (failed)
              const Text(
                'Some event sources are unavailable. Cached events remain '
                'visible below.',
              ),
            if (matters.isNotEmpty)
              for (final _Matter matter in matters.take(5))
                _MatterTile(
                  matter: matter,
                  relevance: null,
                  instrumentNames: <String>[
                    for (final String id in matter.instrumentIds)
                      instruments[id]?.name ?? id,
                  ],
                  holding: null,
                  onOpen: null,
                  now: now,
                )
            else if (loading)
              LinearProgressIndicator(
                semanticsLabel: context.tr('Loading company events'),
              )
            else if (!failed)
              const Text('No earnings or company events are currently known.'),
          ],
        ),
      ),
    );
  }
}

String _earningsTiming(EarningsTiming timing) => switch (timing) {
  EarningsTiming.beforeMarketOpen => 'Before market open',
  EarningsTiming.afterMarketClose => 'After market close',
  EarningsTiming.duringMarketHours => 'During market hours',
  EarningsTiming.unspecified => 'Release time not supplied',
};

String _earningsStatus(EarningsStatus status) => switch (status) {
  EarningsStatus.estimated => 'Estimated',
  EarningsStatus.confirmed => 'Confirmed',
  EarningsStatus.reported => 'Reported',
};

String _corporateType(CorporateEventType type) => switch (type) {
  CorporateEventType.shareholderMeeting => 'Shareholder meeting',
  CorporateEventType.investorDay => 'Investor event',
  CorporateEventType.shareSplit => 'Share split',
  CorporateEventType.transaction => 'Corporate transaction',
  CorporateEventType.capitalAction => 'Capital action',
  CorporateEventType.companyUpdate => 'Company update',
  CorporateEventType.regulatory => 'Regulatory event',
  CorporateEventType.other => 'Company event',
};

String _corporateStatus(CorporateEventStatus status) => switch (status) {
  CorporateEventStatus.estimated => 'Estimated',
  CorporateEventStatus.confirmed => 'Confirmed',
  CorporateEventStatus.completed => 'Completed',
  CorporateEventStatus.cancelled => 'Cancelled',
};

RelevanceKind _corporateRelevanceKind(CorporateEvent event) {
  if (event.type == CorporateEventType.capitalAction &&
      event.title.toLowerCase().contains('buyback')) {
    return RelevanceKind.shareBuyback;
  }
  return switch (event.type) {
    CorporateEventType.transaction => RelevanceKind.mergerOrAcquisition,
    CorporateEventType.capitalAction => RelevanceKind.capitalAction,
    CorporateEventType.regulatory => RelevanceKind.regulatoryEvent,
    _ => RelevanceKind.companyEvent,
  };
}

String _newsCategory(NewsCategory category) => switch (category) {
  NewsCategory.earnings => 'Earnings',
  NewsCategory.dividends => 'Dividends',
  NewsCategory.guidance => 'Guidance',
  NewsCategory.mergersAndAcquisitions => 'Mergers & acquisitions',
  NewsCategory.management => 'Management',
  NewsCategory.regulation => 'Regulation',
  NewsCategory.product => 'Product',
  NewsCategory.analyst => 'Analyst',
  NewsCategory.filing => 'Filing',
  NewsCategory.macro => 'Macro',
  NewsCategory.general => 'General',
};

RelevanceKind _newsRelevanceKind(NewsCategory category) => switch (category) {
  NewsCategory.earnings => RelevanceKind.earnings,
  NewsCategory.dividends => RelevanceKind.dividendAnnouncement,
  NewsCategory.guidance => RelevanceKind.guidance,
  NewsCategory.mergersAndAcquisitions => RelevanceKind.mergerOrAcquisition,
  NewsCategory.management => RelevanceKind.managementChange,
  NewsCategory.regulation => RelevanceKind.regulatoryEvent,
  NewsCategory.product => RelevanceKind.product,
  NewsCategory.analyst => RelevanceKind.analyst,
  NewsCategory.filing => RelevanceKind.materialFiling,
  NewsCategory.macro => RelevanceKind.macro,
  NewsCategory.general => RelevanceKind.generalNews,
};

class _ChangesCard extends StatelessWidget {
  const _ChangesCard({required this.changes});
  final AsyncValue<TodayChanges> changes;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppTheme.space * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Changes since last refresh',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppTheme.space),
          switch (changes) {
            AsyncData<TodayChanges>(:final TodayChanges value)
                when value.isFirstSnapshot =>
              const Text(
                'Baseline saved on this device. Changes will appear after the '
                'next data refresh.',
              ),
            AsyncData<TodayChanges>(:final TodayChanges value)
                when !value.hasChanges =>
              Text(
                'No portfolio, quote or dividend-outlook changes since '
                '${_dateTime(context, value.previousAt!)}.',
              ),
            AsyncData<TodayChanges>(:final TodayChanges value) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('${value.holdingChanges} holding change(s)'),
                Text('${value.quoteChanges} quote change(s)'),
                Text('${value.dividendChanges} dividend-outlook change(s)'),
                Text(
                  'Compared with ${_dateTime(context, value.previousAt!)}.',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
            AsyncError<TodayChanges>() => const Text(
              'Could not update the local comparison. Current portfolio and '
              'dividend data remain available above.',
            ),
            _ => LinearProgressIndicator(
              semanticsLabel: context.tr('Comparing refresh changes'),
            ),
          },
        ],
      ),
    ),
  );

  static String _dateTime(BuildContext context, DateTime value) {
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    return '${localizations.formatMediumDate(value)} at '
        '${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(value))}';
  }
}

class _ExpectedDividendsCard extends ConsumerWidget {
  const _ExpectedDividendsCard({
    required this.next7,
    required this.next30,
    required this.next365,
    required this.holdings,
  });

  final AsyncValue<List<DividendEvent>> next7;
  final AsyncValue<List<DividendEvent>> next30;
  final AsyncValue<List<DividendEvent>> next365;
  final List<Holding> holdings;

  /// Sums the gross payments due to the user, grouped by currency.
  ///
  /// Grouped rather than totalled because amounts in different currencies must
  /// never be silently combined (Vision.md §45). Until an FX rate with its own
  /// provenance exists, each currency is reported on its own line.
  Map<Currency, Money> _expected(List<DividendEvent> events) {
    final Map<String, Holding> byInstrument = <String, Holding>{
      for (final Holding h in holdings) h.instrumentId: h,
    };
    final Map<Currency, Money> totals = <Currency, Money>{};

    for (final DividendEvent event in events) {
      final Holding? holding = byInstrument[event.instrumentId];
      if (holding == null) {
        continue;
      }
      final Money payment = event.grossPaymentFor(holding.quantity);
      totals[payment.currency] =
          (totals[payment.currency] ?? Money.zero(payment.currency)) + payment;
    }
    return totals;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Expected dividends', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppTheme.space),
            _row(context, ref, 'Next 7 days', next7),
            const SizedBox(height: AppTheme.space / 2),
            _row(context, ref, 'Next 30 days', next30),
            const SizedBox(height: AppTheme.space / 2),
            _row(context, ref, 'Next 365 days', next365),
            const SizedBox(height: AppTheme.space),
            Text(
              'Gross and estimated net are never combined. Forecast events '
              'are included and marked. Estimate—not tax advice.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context,
    WidgetRef ref,
    String label,
    AsyncValue<List<DividendEvent>> events,
  ) {
    final ThemeData theme = Theme.of(context);
    final Map<Currency, Money>? totals = events.value == null
        ? null
        : _expected(events.requireValue);
    final _ExpectedNet? estimatedNet = events.value == null
        ? null
        : _net(ref, events.requireValue);

    final Widget value = events.hasError
        ? Text('Unavailable', style: theme.textTheme.bodyMedium)
        : totals == null
        ? Text('…', style: theme.textTheme.bodyMedium)
        : totals.isEmpty
        ? Text(
            'none',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              for (final Money total in totals.values)
                Text(
                  'Gross ${total.format(withSymbol: true)}',
                  style: theme.textTheme.titleSmall,
                ),
              if (estimatedNet?.loading ?? false)
                const Text('Net (estimated) calculating…')
              else if (estimatedNet != null)
                Text(
                  'Net (estimated) '
                  '${estimatedNet.netEur.format(withSymbol: true)}',
                  style: theme.textTheme.titleSmall,
                ),
              if ((estimatedNet?.unsupportedCount ?? 0) > 0)
                Text(
                  '${estimatedNet!.unsupportedCount} need a payment date, '
                  'EUR FX, or country data',
                  style: theme.textTheme.labelSmall,
                ),
            ],
          );
    final bool useVerticalLayout =
        MediaQuery.textScalerOf(context).scale(16) >= 24;

    if (useVerticalLayout) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(label, style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppTheme.space / 4),
          Align(alignment: Alignment.centerRight, child: value),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
        const SizedBox(width: AppTheme.space),
        value,
      ],
    );
  }

  _ExpectedNet _net(WidgetRef ref, List<DividendEvent> events) {
    final Set<int> years = <int>{
      for (final DividendEvent event in events)
        if (event.paymentDate != null) event.paymentDate!.year,
    };
    final List<AsyncValue<PortfolioTaxEstimates>> annual =
        <AsyncValue<PortfolioTaxEstimates>>[
          for (final int year in years)
            ref.watch(portfolioTaxEstimatesProvider(year)),
        ];
    final bool loading = annual.any((value) => !value.hasValue);
    final Map<String, TaxEventEstimate> estimates = <String, TaxEventEstimate>{
      for (final AsyncValue<PortfolioTaxEstimates> value in annual)
        if (value.value case final estimate?) ...estimate.byEventKey,
    };
    Money net = Money.zero(Currency.eur);
    int unsupported = 0;
    for (final DividendEvent event in events) {
      if (!holdings.any(
        (holding) => holding.instrumentId == event.instrumentId,
      )) {
        continue;
      }
      switch (estimates[dividendTaxEventKey(event)]?.result) {
        case DividendTaxBreakdown(net: final Money payment):
          net += payment;
        case UnsupportedTaxCalculation():
          unsupported++;
        case null:
          if (!loading) unsupported++;
      }
    }
    return _ExpectedNet(
      loading: loading,
      netEur: net,
      unsupportedCount: unsupported,
    );
  }
}

final class _ExpectedNet {
  const _ExpectedNet({
    required this.loading,
    required this.netEur,
    required this.unsupportedCount,
  });
  final bool loading;
  final Money netEur;
  final int unsupportedCount;
}
