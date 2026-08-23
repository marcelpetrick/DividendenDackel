import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/app/theme/app_theme.dart';
import 'package:dividendendackel/app/widgets/value_labels.dart';
import 'package:dividendendackel/domain/analytics/analytics.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/features/news/news_link_launcher.dart';
import 'package:dividendendackel/features/research/research_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Evidence-led research detail for one locally known instrument.
class ResearchDetailScreen extends ConsumerWidget {
  const ResearchDetailScreen({required this.instrumentId, super.key});

  final String instrumentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Instrument?> instrument = ref.watch(
      researchInstrumentProvider(instrumentId),
    );
    return Scaffold(
      appBar: AppBar(title: Text(instrument.value?.name ?? 'Research')),
      body: instrument.when(
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (Object error, StackTrace stack) => const _FullPageMessage(
          icon: Icons.error_outline,
          title: 'Could not load this instrument',
          message: 'Cached research data is currently unavailable.',
        ),
        data: (Instrument? value) => value == null
            ? const _FullPageMessage(
                icon: Icons.search_off_outlined,
                title: 'Instrument not found',
                message: 'It may have been removed from the local database.',
              )
            : _ResearchDetailBody(instrument: value),
      ),
    );
  }
}

class _ResearchDetailBody extends ConsumerWidget {
  const _ResearchDetailBody({required this.instrument});

  final Instrument instrument;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String id = instrument.internalId;
    final DateTime now = ref.watch(clockProvider).now();
    final AsyncValue<Quote?> quote = ref.watch(researchQuoteProvider(id));
    final AsyncValue<List<DividendEvent>> dividends = ref.watch(
      researchDividendHistoryProvider(id),
    );
    final AsyncValue<List<EarningsEvent>> earnings = ref.watch(
      researchEarningsProvider(id),
    );
    final AsyncValue<List<CorporateEvent>> corporateEvents = ref.watch(
      researchCorporateEventsProvider(id),
    );
    final AsyncValue<List<NewsItem>> news = ref.watch(researchNewsProvider(id));
    final AsyncValue<List<Filing>> filings = ref.watch(
      researchFilingsProvider(id),
    );
    final AsyncValue<ResearchSnapshot?> snapshot = ref.watch(
      currentResearchSnapshotProvider(id),
    );
    final AsyncValue<List<ResearchSnapshot>> history = ref.watch(
      researchHistoryProvider(id),
    );
    final NewsLinkLauncher launcher = ref.watch(newsLinkLauncherProvider);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.space * 2),
          children: <Widget>[
            _IdentityCard(instrument: instrument),
            const SizedBox(height: AppTheme.space * 2),
            _PriceCard(quote: quote, now: now),
            const SizedBox(height: AppTheme.space * 2),
            _ScoreCard(snapshot: snapshot),
            const SizedBox(height: AppTheme.space * 2),
            _FundamentalsAvailabilityCard(snapshot: snapshot.value),
            const SizedBox(height: AppTheme.space * 2),
            _UpcomingEventsCard(
              earnings: earnings,
              corporateEvents: corporateEvents,
            ),
            const SizedBox(height: AppTheme.space * 2),
            _DividendHistoryCard(
              instrument: instrument,
              dividends: dividends,
              now: now,
            ),
            const SizedBox(height: AppTheme.space * 2),
            _SourceLinksCard(news: news, filings: filings, launcher: launcher),
            const SizedBox(height: AppTheme.space * 2),
            _CasesCard(snapshot: snapshot.value),
            const SizedBox(height: AppTheme.space * 2),
            _ChangeAssessmentCard(snapshot: snapshot.value),
            const SizedBox(height: AppTheme.space * 2),
            _ScoreHistoryCard(history: history),
          ],
        ),
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.instrument});

  final Instrument instrument;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppTheme.space * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            instrument.name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppTheme.space / 2),
          Text(instrument.displaySymbol),
          Wrap(
            spacing: AppTheme.space,
            runSpacing: AppTheme.space / 2,
            children: <Widget>[
              if (instrument.sector case final String value)
                Chip(label: Text(value)),
              if (instrument.country case final String value)
                Chip(label: Text(value)),
              Chip(label: Text(instrument.currency.code)),
              if (instrument.isin case final String value)
                Chip(label: Text(value)),
            ],
          ),
        ],
      ),
    ),
  );
}

class _PriceCard extends StatelessWidget {
  const _PriceCard({required this.quote, required this.now});

  final AsyncValue<Quote?> quote;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final Widget child;
    if (quote.hasError) {
      child = const _InlineMessage('The cached price could not be read.');
    } else if (quote.isLoading && quote.value == null) {
      child = const LinearProgressIndicator(semanticsLabel: 'Loading price');
    } else if (quote.value == null) {
      child = const _InlineMessage(
        'No cached quote is available. Research remains usable without it.',
      );
    } else {
      child = _PriceContent(quote: quote.requireValue!, now: now);
    }
    return _SectionCard(title: 'Price overview', child: child);
  }
}

class _PriceContent extends StatelessWidget {
  const _PriceContent({required this.quote, required this.now});

  final Quote quote;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final Percentage? change = quote.changePercent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        MoneyText(
          quote.price,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        if (change != null)
          Text('${change.format(withSign: true)} since previous close')
        else
          const Text('Previous-close change unavailable'),
        Text('Observed ${_dateTime(context, quote.asOf)}'),
        FreshnessLabel(quote.provenance, now: now),
      ],
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.snapshot});

  final AsyncValue<ResearchSnapshot?> snapshot;

  @override
  Widget build(BuildContext context) {
    final Widget child;
    if (snapshot.hasError) {
      child = const _InlineMessage(
        'The assessment could not be computed from cached evidence.',
      );
    } else if (snapshot.isLoading) {
      child = const LinearProgressIndicator(
        semanticsLabel: 'Computing research score',
      );
    } else if (snapshot.value == null) {
      child = const _InlineMessage(
        'Not enough cached evidence to compute an assessment.',
      );
    } else {
      child = _ScoreContent(snapshot: snapshot.requireValue!);
    }
    return _SectionCard(title: 'Research score', child: child);
  }
}

class _ScoreContent extends StatelessWidget {
  const _ScoreContent({required this.snapshot});

  final ResearchSnapshot snapshot;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Semantics(
        label: 'Research score ${snapshot.overall.score} out of 100',
        child: Text(
          '${snapshot.overall.score} / 100',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      Text(snapshot.overall.summary),
      const SizedBox(height: AppTheme.space / 2),
      const Text('Research context only — not a recommendation.'),
      const SizedBox(height: AppTheme.space),
      for (final ResearchDimension dimension in ResearchDimension.values)
        _DimensionTile(dimension: dimension, assessment: snapshot[dimension]),
    ],
  );
}

class _DimensionTile extends StatelessWidget {
  const _DimensionTile({required this.dimension, required this.assessment});

  final ResearchDimension dimension;
  final ScoredAssessment? assessment;

  @override
  Widget build(BuildContext context) {
    final ScoredAssessment? value = assessment;
    if (value == null) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.remove_circle_outline),
        title: Text(_dimensionLabel(dimension)),
        subtitle: const Text('Not enough cached evidence'),
      );
    }
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: AppTheme.space),
      title: Text(_dimensionLabel(dimension)),
      subtitle: Text(value.summary),
      trailing: Chip(label: Text('${value.score}/100')),
      children: <Widget>[
        for (final ScoreFactor factor in value.factors)
          ListTile(
            dense: true,
            contentPadding: const EdgeInsets.only(left: AppTheme.space),
            leading: Icon(_factorIcon(factor.impact), size: 18),
            title: Text(factor.label),
            subtitle: factor.detail == null ? null : Text(factor.detail!),
          ),
      ],
    );
  }
}

class _FundamentalsAvailabilityCard extends StatelessWidget {
  const _FundamentalsAvailabilityCard({required this.snapshot});

  final ResearchSnapshot? snapshot;

  @override
  Widget build(BuildContext context) {
    final ScoredAssessment? quality = snapshot?[ResearchDimension.quality];
    final bool profitabilityAvailable = _hasFactor(quality, const <String>[
      'Net margin',
      'Free-cash-flow margin',
      'ROE',
      'ROIC',
    ]);
    final bool balanceSheetAvailable = _hasFactor(quality, const <String>[
      'Debt/equity',
    ]);
    return _SectionCard(
      title: 'Fundamentals',
      child: Column(
        children: <Widget>[
          _availabilityRow(
            'Valuation',
            snapshot?[ResearchDimension.valuation] != null,
            snapshot?[ResearchDimension.valuation]?.summary,
            'P/E, forward P/E, P/S, EV/EBITDA and historical range',
          ),
          _availabilityRow(
            'Growth',
            snapshot?[ResearchDimension.growth] != null,
            snapshot?[ResearchDimension.growth]?.summary,
            'Revenue, EPS and free-cash-flow growth',
          ),
          _availabilityRow(
            'Profitability',
            profitabilityAvailable,
            quality?.summary,
            'Margins, ROE and ROIC',
          ),
          _availabilityRow(
            'Balance sheet',
            balanceSheetAvailable,
            quality?.summary,
            'Debt/equity evidence',
          ),
        ],
      ),
    );
  }

  Widget _availabilityRow(
    String title,
    bool available,
    String? summary,
    String evidence,
  ) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(
      available ? Icons.check_circle_outline : Icons.hourglass_empty,
    ),
    title: Text(title),
    subtitle: Text(
      available
          ? summary ?? '$evidence available.'
          : '$evidence — unavailable from configured sources.',
    ),
  );

  bool _hasFactor(ScoredAssessment? assessment, List<String> prefixes) =>
      assessment?.factors.any(
        (ScoreFactor factor) =>
            prefixes.any((String prefix) => factor.label.startsWith(prefix)),
      ) ??
      false;
}

class _UpcomingEventsCard extends StatelessWidget {
  const _UpcomingEventsCard({
    required this.earnings,
    required this.corporateEvents,
  });

  final AsyncValue<List<EarningsEvent>> earnings;
  final AsyncValue<List<CorporateEvent>> corporateEvents;

  @override
  Widget build(BuildContext context) {
    final List<EarningsEvent> earningItems =
        earnings.value ?? const <EarningsEvent>[];
    final List<CorporateEvent> companyItems =
        corporateEvents.value ?? const <CorporateEvent>[];
    return _SectionCard(
      title: 'Upcoming events and earnings',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (earnings.hasError || corporateEvents.hasError)
            const _InlineMessage(
              'Some cached event data could not be read. Available items remain visible.',
            ),
          if ((earnings.isLoading || corporateEvents.isLoading) &&
              earningItems.isEmpty &&
              companyItems.isEmpty)
            const LinearProgressIndicator(semanticsLabel: 'Loading events')
          else if (earningItems.isEmpty && companyItems.isEmpty)
            const _InlineMessage('No upcoming events are cached.')
          else ...<Widget>[
            for (final EarningsEvent event in earningItems.take(5))
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.assessment_outlined),
                title: Text('Earnings · ${_date(context, event.scheduledFor)}'),
                subtitle: Text(
                  '${_earningsStatus(event.status)} · '
                  '${_earningsTiming(event.timing)}',
                ),
              ),
            for (final CorporateEvent event in companyItems.take(5))
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.corporate_fare_outlined),
                title: Text(event.title),
                subtitle: Text(
                  '${_date(context, event.scheduledFor)} · '
                  '${_corporateStatus(event.status)}',
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _DividendHistoryCard extends StatelessWidget {
  const _DividendHistoryCard({
    required this.instrument,
    required this.dividends,
    required this.now,
  });

  final Instrument instrument;
  final AsyncValue<List<DividendEvent>> dividends;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final List<DividendEvent> events =
        dividends.value ?? const <DividendEvent>[];
    final DividendGrowthAnalysis growth = const DividendGrowthCalculator()
        .calculate(
          instrumentId: instrument.internalId,
          currency: instrument.currency,
          events: events,
          asOf: now,
        );
    return _SectionCard(
      title: 'Dividend history',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (dividends.hasError)
            const _InlineMessage(
              'The cached dividend history could not be read.',
            )
          else if (dividends.isLoading && events.isEmpty)
            const LinearProgressIndicator(
              semanticsLabel: 'Loading dividend history',
            )
          else if (events.isEmpty)
            const _InlineMessage('No dividend history is cached.')
          else ...<Widget>[
            Text(
              '${growth.annualTotals.length} completed reported year(s) · '
              '${growth.yearsWithoutCut} year(s) without a cut',
            ),
            for (final int period in DividendGrowthCalculator.standardPeriods)
              if (growth.cagrs[period] case final DividendCagr cagr)
                Text(cagr.format()),
            const SizedBox(height: AppTheme.space / 2),
            for (final DividendEvent event in events.take(8))
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.payments_outlined),
                title: MoneyText(event.amountPerShare),
                subtitle: Text(
                  _dividendDate(context, event) ??
                      'Event date unavailable; provider reported a period only.',
                ),
                trailing: DividendStatusChip(event.status),
              ),
          ],
        ],
      ),
    );
  }
}

class _SourceLinksCard extends StatelessWidget {
  const _SourceLinksCard({
    required this.news,
    required this.filings,
    required this.launcher,
  });

  final AsyncValue<List<NewsItem>> news;
  final AsyncValue<List<Filing>> filings;
  final NewsLinkLauncher launcher;

  @override
  Widget build(BuildContext context) {
    final List<NewsItem> headlines = news.value ?? const <NewsItem>[];
    final List<Filing> reports = filings.value ?? const <Filing>[];
    return _SectionCard(
      title: 'News and filings',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Headlines and source links only. Articles and filings remain with their publishers.',
          ),
          if (news.hasError || filings.hasError)
            const _InlineMessage(
              'Some source metadata could not be read. Cached links remain visible.',
            ),
          if ((news.isLoading || filings.isLoading) &&
              headlines.isEmpty &&
              reports.isEmpty)
            const LinearProgressIndicator(
              semanticsLabel: 'Loading news and filings',
            )
          else if (headlines.isEmpty && reports.isEmpty)
            const _InlineMessage('No recent news or filings are cached.')
          else ...<Widget>[
            for (final NewsItem item in headlines.take(5))
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.article_outlined),
                title: Text(item.headline),
                subtitle: Text(
                  '${item.sourceName} · ${_date(context, item.publishedAt)}',
                ),
                trailing: IconButton(
                  tooltip: 'Open original',
                  onPressed: () => _open(context, item.url),
                  icon: const Icon(Icons.open_in_new),
                ),
              ),
            for (final Filing filing in reports.take(5))
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.description_outlined),
                title: Text(filing.title ?? filing.formType),
                subtitle: Text(
                  '${filing.formType} · ${_date(context, filing.filedAt)}',
                ),
                trailing: IconButton(
                  tooltip: 'Open filing source',
                  onPressed: () => _open(context, filing.url),
                  icon: const Icon(Icons.open_in_new),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _open(BuildContext context, Uri uri) async {
    bool opened = false;
    try {
      opened = await launcher.open(uri);
    } on Object {
      opened = false;
    }
    if (!context.mounted || opened) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open the original source.')),
    );
  }
}

class _CasesCard extends StatelessWidget {
  const _CasesCard({required this.snapshot});

  final ResearchSnapshot? snapshot;

  @override
  Widget build(BuildContext context) {
    final List<ScoreFactor> factors = <ScoreFactor>[
      for (final ScoredAssessment assessment
          in snapshot?.dimensions.values ?? const <ScoredAssessment>[])
        ...assessment.factors,
    ];
    final List<ScoreFactor> positives = factors
        .where((ScoreFactor factor) => factor.impact == FactorImpact.positive)
        .toList(growable: false);
    final List<ScoreFactor> risks = factors
        .where((ScoreFactor factor) => factor.impact == FactorImpact.negative)
        .toList(growable: false);
    return _SectionCard(
      title: 'Bull case and bear case',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Evidence summaries, not predictions or instructions.'),
          const SizedBox(height: AppTheme.space),
          Text('Bull case', style: Theme.of(context).textTheme.titleSmall),
          if (positives.isEmpty)
            const _InlineMessage('No supporting factor is currently scored.')
          else
            for (final ScoreFactor factor in positives.take(6))
              _EvidenceLine(icon: Icons.add_circle_outline, text: factor.label),
          const SizedBox(height: AppTheme.space),
          Text('Bear case', style: Theme.of(context).textTheme.titleSmall),
          if (risks.isEmpty)
            const _InlineMessage('No adverse factor is currently scored.')
          else
            for (final ScoreFactor factor in risks.take(6))
              _EvidenceLine(
                icon: Icons.remove_circle_outline,
                text: factor.label,
              ),
        ],
      ),
    );
  }
}

class _ChangeAssessmentCard extends StatelessWidget {
  const _ChangeAssessmentCard({required this.snapshot});

  final ResearchSnapshot? snapshot;

  @override
  Widget build(BuildContext context) {
    final Set<ResearchDimension> available =
        snapshot?.availableDimensions ?? const <ResearchDimension>{};
    return _SectionCard(
      title: 'What would change the assessment?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Conditions from the scoring model, not forecasts.'),
          const SizedBox(height: AppTheme.space),
          Text('Positive', style: Theme.of(context).textTheme.titleSmall),
          const _EvidenceLine(
            icon: Icons.add_circle_outline,
            text: 'Margins, free cash flow or returns on capital improve.',
          ),
          const _EvidenceLine(
            icon: Icons.add_circle_outline,
            text: 'Debt falls or dividend coverage and consistency strengthen.',
          ),
          const _EvidenceLine(
            icon: Icons.add_circle_outline,
            text: 'Near-term event risks pass without adverse changes.',
          ),
          const SizedBox(height: AppTheme.space),
          Text('Negative', style: Theme.of(context).textTheme.titleSmall),
          const _EvidenceLine(
            icon: Icons.remove_circle_outline,
            text: 'Earnings, cash flow or margins deteriorate.',
          ),
          const _EvidenceLine(
            icon: Icons.remove_circle_outline,
            text: 'Debt increases, coverage weakens or the dividend is cut.',
          ),
          const _EvidenceLine(
            icon: Icons.remove_circle_outline,
            text:
                'Guidance changes, abnormal volatility or material filings raise event risk.',
          ),
          if (available.length < ResearchDimension.values.length) ...<Widget>[
            const Divider(),
            Text(
              'Coverage could also change when a configured source supplies: '
              '${ResearchDimension.values.where((ResearchDimension value) => !available.contains(value)).map(_dimensionLabel).join(', ')}.',
            ),
          ],
        ],
      ),
    );
  }
}

class _ScoreHistoryCard extends StatelessWidget {
  const _ScoreHistoryCard({required this.history});

  final AsyncValue<List<ResearchSnapshot>> history;

  @override
  Widget build(BuildContext context) {
    final List<ResearchSnapshot> items =
        history.value ?? const <ResearchSnapshot>[];
    return _SectionCard(
      title: 'Research-score history',
      child: Column(
        children: <Widget>[
          if (history.hasError)
            const _InlineMessage('Score history could not be read.')
          else if (history.isLoading && items.isEmpty)
            const LinearProgressIndicator(
              semanticsLabel: 'Loading score history',
            )
          else if (items.isEmpty)
            const _InlineMessage(
              'The first assessment will be retained when enough evidence is available.',
            )
          else
            for (int index = 0; index < items.take(12).length; index++)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.timeline_outlined),
                title: Text('${items[index].overall.score} / 100'),
                subtitle: Text(_dateTime(context, items[index].takenAt)),
                trailing: index + 1 >= items.length
                    ? null
                    : Text(
                        _signed(
                          items[index].overall.score -
                              items[index + 1].overall.score,
                        ),
                      ),
              ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppTheme.space * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppTheme.space),
          child,
        ],
      ),
    ),
  );
}

class _EvidenceLine extends StatelessWidget {
  const _EvidenceLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppTheme.space / 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 18),
        const SizedBox(width: AppTheme.space / 2),
        Expanded(child: Text(text)),
      ],
    ),
  );
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage(this.message);

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppTheme.space / 2),
    child: Text(message),
  );
}

class _FullPageMessage extends StatelessWidget {
  const _FullPageMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.space * 3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 48),
          const SizedBox(height: AppTheme.space),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppTheme.space / 2),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

IconData _factorIcon(FactorImpact impact) => switch (impact) {
  FactorImpact.positive => Icons.add_circle_outline,
  FactorImpact.negative => Icons.remove_circle_outline,
  FactorImpact.neutral => Icons.info_outline,
};

String _dimensionLabel(ResearchDimension dimension) => switch (dimension) {
  ResearchDimension.valuation => 'Valuation',
  ResearchDimension.quality => 'Quality',
  ResearchDimension.growth => 'Growth',
  ResearchDimension.momentum => 'Momentum',
  ResearchDimension.dividend => 'Dividend',
  ResearchDimension.eventRisk => 'Event risk',
};

String _earningsStatus(EarningsStatus status) => switch (status) {
  EarningsStatus.estimated => 'Estimated',
  EarningsStatus.confirmed => 'Confirmed',
  EarningsStatus.reported => 'Reported',
};

String _earningsTiming(EarningsTiming timing) => switch (timing) {
  EarningsTiming.beforeMarketOpen => 'Before market open',
  EarningsTiming.afterMarketClose => 'After market close',
  EarningsTiming.duringMarketHours => 'During market hours',
  EarningsTiming.unspecified => 'Time not supplied',
};

String _corporateStatus(CorporateEventStatus status) => switch (status) {
  CorporateEventStatus.estimated => 'Estimated',
  CorporateEventStatus.confirmed => 'Confirmed',
  CorporateEventStatus.completed => 'Completed',
  CorporateEventStatus.cancelled => 'Cancelled',
};

String? _dividendDate(BuildContext context, DividendEvent event) {
  if (event.paymentDate case final DateTime value) {
    return 'Payment ${_date(context, value)}';
  }
  if (event.exDate case final DateTime value) {
    return 'Ex-dividend ${_date(context, value)} · payment date unavailable';
  }
  if (event.reportedPeriodEnd case final DateTime value) {
    return 'Reported period ended ${_date(context, value)}';
  }
  return null;
}

String _date(BuildContext context, DateTime value) =>
    MaterialLocalizations.of(context).formatMediumDate(value.toLocal());

String _dateTime(BuildContext context, DateTime value) {
  final DateTime local = value.toLocal();
  final MaterialLocalizations localizations = MaterialLocalizations.of(context);
  return '${localizations.formatMediumDate(local)} · '
      '${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(local))}';
}

String _signed(int value) => value > 0 ? '+$value' : '$value';
