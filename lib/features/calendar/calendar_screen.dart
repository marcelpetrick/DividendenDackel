import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/app/theme/app_theme.dart';
import 'package:dividendendackel/app/widgets/async_value_view.dart';
import 'package:dividendendackel/app/widgets/gross_net_amount.dart';
import 'package:dividendendackel/app/widgets/value_labels.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/domain/use_cases/calendar_export.dart';
import 'package:dividendendackel/features/calendar/calendar_export_writer.dart';
import 'package:dividendendackel/features/calendar/calendar_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Interactive dividend calendar (Vision.md §9).
class CalendarScreen extends ConsumerStatefulWidget {
  /// Creates the calendar screen.
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _focus;
  DividendCalendarView _view = DividendCalendarView.month;
  DividendCalendarScope _scope = DividendCalendarScope.portfolio;
  DividendDateMode _dateMode = DividendDateMode.exDate;
  bool _weekends = true;
  DateTime? _expandedDay;
  Currency? _displayCurrency;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    _focus = DividendCalendarMath.day(ref.read(clockProvider).now());
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Holding>> holdingsValue = ref.watch(holdingsProvider);
    final List<Holding> holdings = holdingsValue.value ?? const <Holding>[];
    final AsyncValue<List<WatchlistEntry>> watchlistValue = ref.watch(
      watchlistProvider,
    );
    final List<WatchlistEntry> watchlist =
        watchlistValue.value ?? const <WatchlistEntry>[];
    final AsyncValue<Map<String, Instrument>> instrumentsValue = ref.watch(
      instrumentsByIdProvider,
    );
    final Map<String, Instrument> instruments =
        instrumentsValue.value ?? const <String, Instrument>{};
    final Set<String>? ids = switch (_scope) {
      DividendCalendarScope.portfolio => <String>{
        for (final Holding holding in holdings) holding.instrumentId,
      },
      DividendCalendarScope.watchlist => <String>{
        for (final WatchlistEntry entry in watchlist) entry.instrumentId,
      },
      DividendCalendarScope.all => null,
    };
    final CalendarEventsQuery query = CalendarEventsQuery(
      range: DividendCalendarMath.visibleRange(_focus, _view),
      dateMode: _dateMode,
      instrumentIds: ids,
    );
    final AsyncValue<List<DividendEvent>> events = ref.watch(
      calendarEventsProvider(query),
    );
    final List<DividendEvent>? exportEvents = events.value;
    final Map<String, Holding> holdingsById = <String, Holding>{
      for (final Holding holding in holdings) holding.instrumentId: holding,
    };

    return Column(
      children: <Widget>[
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.42,
          ),
          child: SingleChildScrollView(
            child: _Controls(
              focus: _focus,
              view: _view,
              scope: _scope,
              dateMode: _dateMode,
              weekends: _weekends,
              displayCurrency: _displayCurrency,
              onPrevious: () => _move(-1),
              onNext: () => _move(1),
              onToday: () => setState(() {
                _focus = DividendCalendarMath.day(
                  ref.read(clockProvider).now(),
                );
                _expandedDay = null;
              }),
              onViewChanged: (DividendCalendarView view) => setState(() {
                _view = view;
                _expandedDay = null;
              }),
              onScopeChanged: (DividendCalendarScope scope) =>
                  setState(() => _scope = scope),
              onDateModeChanged: (DividendDateMode mode) => setState(() {
                _dateMode = mode;
                _expandedDay = null;
              }),
              onWeekendsChanged: (bool value) =>
                  setState(() => _weekends = value),
              onCurrencyChanged: (Currency? currency) =>
                  setState(() => _displayCurrency = currency),
              onForecast: () => context.push('/calendar/forecast'),
              exporting: _exporting,
              onExport:
                  exportEvents != null && exportEvents.isNotEmpty && !_exporting
                  ? () => _exportCalendar(
                      query: query,
                      events: exportEvents,
                      instruments: instruments,
                    )
                  : null,
            ),
          ),
        ),
        if (_displayCurrency != null)
          _ConversionNotice(currency: _displayCurrency!),
        if (holdingsValue.hasError ||
            watchlistValue.hasError ||
            instrumentsValue.hasError)
          const MaterialBanner(
            leading: Icon(Icons.warning_amber_outlined),
            content: Text(
              'Some saved portfolio details are unavailable. Calendar events '
              'that could be read remain visible.',
            ),
            actions: <Widget>[SizedBox.shrink()],
          ),
        Expanded(
          child: AsyncValueView<List<DividendEvent>>(
            value: events,
            onRetry: () => ref.invalidate(calendarEventsProvider(query)),
            isEmpty: (List<DividendEvent> data) => data.isEmpty,
            emptyTitle: 'No dividend events',
            emptyMessage: _emptyMessage,
            emptyIcon: Icons.calendar_month_outlined,
            builder: (BuildContext context, List<DividendEvent> data) {
              final Map<DateTime, List<DividendEvent>> grouped =
                  DividendCalendarMath.groupByDay(data, _dateMode);
              return switch (_view) {
                DividendCalendarView.month => _MonthView(
                  focus: _focus,
                  weekends: _weekends,
                  grouped: grouped,
                  instruments: instruments,
                  holdings: holdingsById,
                  expandedDay: _expandedDay,
                  dateMode: _dateMode,
                  now: ref.read(clockProvider).now(),
                  onDaySelected: (DateTime day) =>
                      setState(() => _expandedDay = day),
                ),
                DividendCalendarView.year => _YearView(
                  focus: _focus,
                  eventsByMonth: DividendCalendarMath.groupByMonth(
                    data,
                    _dateMode,
                    _focus.year,
                  ),
                  holdings: holdingsById,
                  onMonthSelected: (int month) => setState(() {
                    _focus = DateTime(_focus.year, month);
                    _view = DividendCalendarView.month;
                    _expandedDay = null;
                  }),
                ),
                DividendCalendarView.agenda => _AgendaView(
                  grouped: grouped,
                  instruments: instruments,
                  holdings: holdingsById,
                  dateMode: _dateMode,
                  now: ref.read(clockProvider).now(),
                ),
              };
            },
          ),
        ),
      ],
    );
  }

  String get _emptyMessage => switch (_scope) {
    DividendCalendarScope.portfolio =>
      'No dated payments are known for your holdings in this period.',
    DividendCalendarScope.watchlist =>
      'No dated payments are known for your watchlist in this period.',
    DividendCalendarScope.all => 'No dated payments are known for this period.',
  };

  void _move(int direction) => setState(() {
    _focus = switch (_view) {
      DividendCalendarView.month => DateTime(
        _focus.year,
        _focus.month + direction,
      ),
      DividendCalendarView.year => DateTime(_focus.year + direction),
      DividendCalendarView.agenda => _focus.add(Duration(days: 30 * direction)),
    };
    _expandedDay = null;
  });

  Future<void> _exportCalendar({
    required CalendarEventsQuery query,
    required List<DividendEvent> events,
    required Map<String, Instrument> instruments,
  }) async {
    setState(() => _exporting = true);
    final String? portfolioId = ref.read(effectivePortfolioIdProvider);
    final CalendarExportDocument document = CalendarIcsExporter.export(
      events: events,
      instruments: instruments,
      range: query.range,
      dateMode: query.dateMode,
      scopeLabel: switch (_scope) {
        DividendCalendarScope.portfolio =>
          portfolioId == null ? 'All portfolios' : 'Current portfolio',
        DividendCalendarScope.watchlist =>
          portfolioId == null
              ? 'All portfolio watchlists'
              : 'Current watchlist',
        DividendCalendarScope.all => 'All instruments',
      },
      createdAt: ref.read(clockProvider).now(),
    );
    try {
      final bool saved = await ref
          .read(calendarExportWriterProvider)
          .save(document);
      if (saved && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${document.eventCount} dividend events exported locally.',
            ),
          ),
        );
      }
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Calendar export could not be saved.')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.focus,
    required this.view,
    required this.scope,
    required this.dateMode,
    required this.weekends,
    required this.displayCurrency,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
    required this.onViewChanged,
    required this.onScopeChanged,
    required this.onDateModeChanged,
    required this.onWeekendsChanged,
    required this.onCurrencyChanged,
    required this.onForecast,
    required this.exporting,
    required this.onExport,
  });

  final DateTime focus;
  final DividendCalendarView view;
  final DividendCalendarScope scope;
  final DividendDateMode dateMode;
  final bool weekends;
  final Currency? displayCurrency;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;
  final ValueChanged<DividendCalendarView> onViewChanged;
  final ValueChanged<DividendCalendarScope> onScopeChanged;
  final ValueChanged<DividendDateMode> onDateModeChanged;
  final ValueChanged<bool> onWeekendsChanged;
  final ValueChanged<Currency?> onCurrencyChanged;
  final VoidCallback onForecast;
  final bool exporting;
  final VoidCallback? onExport;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String explanation = dateMode == DividendDateMode.exDate
        ? 'Ex-date: own the share before this date to receive the dividend.'
        : 'Payment date: when the dividend is expected to reach your account.';
    return Material(
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Wrap(
              spacing: AppTheme.space,
              runSpacing: AppTheme.space,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                IconButton(
                  tooltip: 'Previous period',
                  onPressed: onPrevious,
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  _periodLabel(focus, view),
                  style: theme.textTheme.titleLarge,
                ),
                IconButton(
                  tooltip: 'Next period',
                  onPressed: onNext,
                  icon: const Icon(Icons.chevron_right),
                ),
                TextButton(onPressed: onToday, child: const Text('Today')),
                FilledButton.tonalIcon(
                  onPressed: onForecast,
                  icon: const Icon(Icons.stacked_line_chart),
                  label: const Text('Income forecast'),
                ),
                SegmentedButton<DividendCalendarView>(
                  showSelectedIcon: false,
                  segments: const <ButtonSegment<DividendCalendarView>>[
                    ButtonSegment<DividendCalendarView>(
                      value: DividendCalendarView.month,
                      label: Text('Month'),
                    ),
                    ButtonSegment<DividendCalendarView>(
                      value: DividendCalendarView.year,
                      label: Text('Year'),
                    ),
                    ButtonSegment<DividendCalendarView>(
                      value: DividendCalendarView.agenda,
                      label: Text('Agenda'),
                    ),
                  ],
                  selected: <DividendCalendarView>{view},
                  onSelectionChanged: (Set<DividendCalendarView> value) =>
                      onViewChanged(value.single),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.space),
            Wrap(
              spacing: AppTheme.space * 2,
              runSpacing: AppTheme.space,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                SegmentedButton<DividendDateMode>(
                  showSelectedIcon: false,
                  segments: const <ButtonSegment<DividendDateMode>>[
                    ButtonSegment<DividendDateMode>(
                      value: DividendDateMode.exDate,
                      label: Text('Ex-date'),
                    ),
                    ButtonSegment<DividendDateMode>(
                      value: DividendDateMode.paymentDate,
                      label: Text('Payment'),
                    ),
                  ],
                  selected: <DividendDateMode>{dateMode},
                  onSelectionChanged: (Set<DividendDateMode> value) =>
                      onDateModeChanged(value.single),
                ),
                _EnumMenu<DividendCalendarScope>(
                  label: 'Scope',
                  value: scope,
                  entries: const <DropdownMenuEntry<DividendCalendarScope>>[
                    DropdownMenuEntry<DividendCalendarScope>(
                      value: DividendCalendarScope.portfolio,
                      label: 'Portfolio',
                    ),
                    DropdownMenuEntry<DividendCalendarScope>(
                      value: DividendCalendarScope.watchlist,
                      label: 'Watchlist',
                    ),
                    DropdownMenuEntry<DividendCalendarScope>(
                      value: DividendCalendarScope.all,
                      label: 'All instruments',
                    ),
                  ],
                  onSelected: onScopeChanged,
                ),
                DropdownMenu<Currency?>(
                  key: const ValueKey<String>('display-currency'),
                  width: 155,
                  label: const Text('Display currency'),
                  initialSelection: displayCurrency,
                  dropdownMenuEntries: <DropdownMenuEntry<Currency?>>[
                    const DropdownMenuEntry<Currency?>(
                      value: null,
                      label: 'Native',
                    ),
                    for (final Currency currency in <Currency>[
                      Currency.eur,
                      Currency.usd,
                      Currency.gbp,
                      Currency.chf,
                    ])
                      DropdownMenuEntry<Currency?>(
                        value: currency,
                        label: currency.code,
                      ),
                  ],
                  onSelected: onCurrencyChanged,
                ),
                if (view == DividendCalendarView.month)
                  FilterChip(
                    label: const Text('Weekends'),
                    selected: weekends,
                    onSelected: onWeekendsChanged,
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Text(
                    explanation,
                    key: const ValueKey<String>('date-explanation'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  key: const ValueKey<String>('export-calendar'),
                  tooltip: 'Export calendar',
                  onPressed: onExport,
                  icon: exporting
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download_outlined),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _periodLabel(DateTime focus, DividendCalendarView view) =>
      view == DividendCalendarView.year
      ? '${focus.year}'
      : '${_monthNames[focus.month - 1]} ${focus.year}';
}

class _EnumMenu<T> extends StatelessWidget {
  const _EnumMenu({
    required this.label,
    required this.value,
    required this.entries,
    required this.onSelected,
  });

  final String label;
  final T value;
  final List<DropdownMenuEntry<T>> entries;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) => DropdownMenu<T>(
    width: 155,
    label: Text(label),
    initialSelection: value,
    dropdownMenuEntries: entries,
    onSelected: (T? value) {
      if (value != null) onSelected(value);
    },
  );
}

class _ConversionNotice extends StatelessWidget {
  const _ConversionNotice({required this.currency});

  final Currency currency;

  @override
  Widget build(BuildContext context) => MaterialBanner(
    key: const ValueKey<String>('fx-notice'),
    content: Text(
      '${currency.code} selected. Amounts stay in their native currency until '
      'a dated FX rate is available.',
    ),
    leading: const Icon(Icons.currency_exchange),
    actions: const <Widget>[SizedBox.shrink()],
  );
}

class _MonthView extends StatelessWidget {
  const _MonthView({
    required this.focus,
    required this.weekends,
    required this.grouped,
    required this.instruments,
    required this.holdings,
    required this.expandedDay,
    required this.dateMode,
    required this.now,
    required this.onDaySelected,
  });

  final DateTime focus;
  final bool weekends;
  final Map<DateTime, List<DividendEvent>> grouped;
  final Map<String, Instrument> instruments;
  final Map<String, Holding> holdings;
  final DateTime? expandedDay;
  final DividendDateMode dateMode;
  final DateTime now;
  final ValueChanged<DateTime> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final List<DateTime> cells = DividendCalendarMath.monthCells(
      focus,
      weekends: weekends,
    );
    final int columns = weekends ? 7 : 5;
    final List<String> weekdays = weekends
        ? const <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
        : const <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
    final DateTime? selected = expandedDay;
    final TextScaler textScaler = MediaQuery.textScalerOf(context);
    final double rowHeight = textScaler.scale(104).clamp(104, 180).toDouble();
    final List<DividendEvent> selectedEvents = selected == null
        ? const <DividendEvent>[]
        : grouped[selected] ?? const <DividendEvent>[];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: <Widget>[
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double width = constraints.maxWidth < columns * 72
                ? columns * 72
                : constraints.maxWidth;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: width,
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        for (final String weekday in weekdays)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Text(
                                weekday,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            ),
                          ),
                      ],
                    ),
                    for (int row = 0; row < cells.length; row += columns)
                      SizedBox(
                        height: rowHeight,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            for (final DateTime day
                                in cells.skip(row).take(columns))
                              Expanded(
                                child: _DayCell(
                                  day: day,
                                  inMonth: day.month == focus.month,
                                  events:
                                      grouped[day] ?? const <DividendEvent>[],
                                  selected: day == selected,
                                  instruments: instruments,
                                  onSelected: () => onDaySelected(day),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        if (selected != null) ...<Widget>[
          const SizedBox(height: AppTheme.space * 2),
          Text(
            '${_longDate(selected)} · ${selectedEvents.length} event${selectedEvents.length == 1 ? '' : 's'}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppTheme.space),
          if (selectedEvents.isEmpty)
            const Text('No dividend events on this day.')
          else
            for (final DividendEvent event in selectedEvents)
              _EventCard(
                event: event,
                instrument: instruments[event.instrumentId],
                holding: holdings[event.instrumentId],
                dateMode: dateMode,
                now: now,
              ),
        ],
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.inMonth,
    required this.events,
    required this.selected,
    required this.instruments,
    required this.onSelected,
  });

  final DateTime day;
  final bool inMonth;
  final List<DividendEvent> events;
  final bool selected;
  final Map<String, Instrument> instruments;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color border = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.outlineVariant;
    return MouseRegion(
      onEnter: (_) {
        if (events.isNotEmpty) onSelected();
      },
      child: Semantics(
        button: true,
        selected: selected,
        label: '${_longDate(day)}, ${events.length} dividend events',
        hint: events.isEmpty ? 'Select day' : 'Select to show dividend details',
        child: InkWell(
          key: ValueKey<String>('calendar-day-${day.toIso8601String()}'),
          onTap: onSelected,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: selected
                  ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
                  : null,
              border: Border.all(color: border, width: selected ? 2 : 1),
            ),
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: inMonth
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.outline,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('${day.day}', style: theme.textTheme.labelMedium),
                  const SizedBox(height: 3),
                  for (final DividendEvent event in events.take(2))
                    _CompactEvent(
                      event: event,
                      symbol:
                          instruments[event.instrumentId]?.symbol ??
                          event.instrumentId,
                    ),
                  if (events.length > 2)
                    Text(
                      'Show ${events.length - 2} more',
                      key: ValueKey<String>('more-${day.toIso8601String()}'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactEvent extends StatelessWidget {
  const _CompactEvent({required this.event, required this.symbol});

  final DividendEvent event;
  final String symbol;

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      Container(
        width: 16,
        height: 16,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: event.isEstimate ? BoxShape.rectangle : BoxShape.circle,
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: Text(
          event.isEstimate ? 'E' : 'C',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 9),
        ),
      ),
      const SizedBox(width: 3),
      Expanded(
        child: Text(
          symbol,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ),
    ],
  );
}

class _YearView extends StatelessWidget {
  const _YearView({
    required this.focus,
    required this.eventsByMonth,
    required this.holdings,
    required this.onMonthSelected,
  });

  final DateTime focus;
  final Map<int, List<DividendEvent>> eventsByMonth;
  final Map<String, Holding> holdings;
  final ValueChanged<int> onMonthSelected;

  @override
  Widget build(BuildContext context) {
    final double extent = MediaQuery.textScalerOf(context)
        .scale(190)
        .clamp(190, 400)
        .toDouble();
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 290,
        mainAxisExtent: extent,
        crossAxisSpacing: AppTheme.space,
        mainAxisSpacing: AppTheme.space,
      ),
      itemCount: 12,
      itemBuilder: (BuildContext context, int index) {
        final int month = index + 1;
        final List<DividendEvent> monthEvents =
            eventsByMonth[month] ?? const <DividendEvent>[];
        final Map<Currency, Money> totals = _heldTotalsByCurrency(
          monthEvents,
          holdings,
        );
        final String totalsLabel = totals.isEmpty
            ? 'no held payments'
            : totals.values
                  .map((Money total) => total.format(withSymbol: true))
                  .join(', ');
        return Semantics(
          button: true,
          label:
              '${_monthNames[index]} ${focus.year}, ${monthEvents.length} '
              'payments, $totalsLabel',
          hint: 'Open month',
          child: ExcludeSemantics(
            child: Card(
              child: InkWell(
                key: ValueKey<String>('year-month-$month'),
                onTap: () => onMonthSelected(month),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _monthNames[index],
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${monthEvents.length} payment${monthEvents.length == 1 ? '' : 's'}',
                      ),
                      const Spacer(),
                      if (totals.isEmpty)
                        Text(
                          'No held payments',
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      else ...<Widget>[
                        Text(
                          'Held gross',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        for (final Money total in totals.values)
                          MoneyText(
                            total,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AgendaView extends StatelessWidget {
  const _AgendaView({
    required this.grouped,
    required this.instruments,
    required this.holdings,
    required this.dateMode,
    required this.now,
  });

  final Map<DateTime, List<DividendEvent>> grouped;
  final Map<String, Instrument> instruments;
  final Map<String, Holding> holdings;
  final DividendDateMode dateMode;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final List<DateTime> days = grouped.keys.toList()..sort();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: days.length,
      itemBuilder: (BuildContext context, int index) {
        final DateTime day = days[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Text(
                _longDate(day),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final DividendEvent event in grouped[day]!)
              _EventCard(
                event: event,
                instrument: instruments[event.instrumentId],
                holding: holdings[event.instrumentId],
                dateMode: dateMode,
                now: now,
              ),
          ],
        );
      },
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.event,
    required this.instrument,
    required this.holding,
    required this.dateMode,
    required this.now,
  });

  final DividendEvent event;
  final Instrument? instrument;
  final Holding? holding;
  final DividendDateMode dateMode;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final Money? heldPayment = holding == null
        ? null
        : event.grossPaymentFor(holding!.quantity);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.space),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          instrument?.name ?? event.instrumentId,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(instrument?.displaySymbol ?? event.instrumentId),
                      ],
                    ),
                  ),
                  DividendStatusChip(event.status),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                runSpacing: 6,
                children: <Widget>[
                  Text(
                    '${event.amountPerShare.format(withSymbol: true)} / share',
                  ),
                  if (heldPayment != null)
                    GrossNetAmount(
                      event: event,
                      gross: heldPayment,
                      key: const ValueKey<String>('held-payment'),
                    ),
                  Text(
                    '${_modeLabel(dateMode)}: ${_date(event.dateFor(dateMode))}',
                  ),
                  Text('Ex-date: ${_date(event.exDate)}'),
                  Text('Payment: ${_date(event.paymentDate)}'),
                ],
              ),
              const SizedBox(height: 6),
              FreshnessLabel(event.provenance, now: now),
            ],
          ),
        ),
      ),
    );
  }
}

Map<Currency, Money> _heldTotalsByCurrency(
  Iterable<DividendEvent> events,
  Map<String, Holding> holdings,
) {
  final Map<Currency, List<Money>> values = <Currency, List<Money>>{};
  for (final DividendEvent event in events) {
    final Holding? holding = holdings[event.instrumentId];
    if (holding != null) {
      final Money payment = event.grossPaymentFor(holding.quantity);
      values.putIfAbsent(payment.currency, () => <Money>[]).add(payment);
    }
  }
  return <Currency, Money>{
    for (final MapEntry<Currency, List<Money>> entry in values.entries)
      entry.key: Money.sum(entry.value, entry.key),
  };
}

String _modeLabel(DividendDateMode mode) =>
    mode == DividendDateMode.exDate ? 'Ex-date' : 'Payment';

String _date(DateTime? value) =>
    value == null ? 'Not confirmed' : _longDate(value);

String _longDate(DateTime value) =>
    '${value.day} ${_monthNames[value.month - 1]} ${value.year}';

const List<String> _monthNames = <String>[
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];
