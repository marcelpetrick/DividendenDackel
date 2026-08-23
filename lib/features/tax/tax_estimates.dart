import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/domain/analytics/analytics.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/domain/repositories/repositories.dart';
import 'package:dividendendackel/features/calendar/calendar_state.dart';
import 'package:dividendendackel/features/currency/fx_state.dart';
import 'package:dividendendackel/features/settings/tax_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Gross and estimated-net result attached to one held dividend event.
final class TaxEventEstimate {
  /// Creates an estimate.
  const TaxEventEstimate({
    required this.gross,
    required this.result,
    this.fxConversion,
  });
  final Money gross;
  final DividendTaxResult result;
  final FxConversion? fxConversion;
}

/// Annual estimates keyed by a stable event identity.
final class PortfolioTaxEstimates {
  /// Creates annual estimates.
  const PortfolioTaxEstimates({required this.year, required this.byEventKey});
  final int year;
  final Map<String, TaxEventEstimate> byEventKey;
}

/// Applies one profile to held events in annual allowance order.
///
/// Keeping this calculation outside Riverpod lets forecasts use their generated
/// events without persisting them or quietly using a different tax model.
abstract final class PortfolioTaxEstimator {
  /// Calculates all [events] for [year]. Events outside that year are ignored.
  static PortfolioTaxEstimates calculate({
    required int year,
    required Iterable<DividendEvent> events,
    required Iterable<Holding> holdings,
    required Map<String, Instrument> instruments,
    required TaxSettings settings,
    Iterable<FxRate> fxRates = const <FxRate>[],
  }) {
    final Map<String, Holding> held = <String, Holding>{
      for (final Holding holding in holdings) holding.instrumentId: holding,
    };
    final Map<String, TaxEventEstimate> output = <String, TaxEventEstimate>{};
    final List<(DividendEvent, TaxableDividend, Money, FxConversion?)> taxable =
        <(DividendEvent, TaxableDividend, Money, FxConversion?)>[];
    for (final DividendEvent event in events) {
      final Holding? holding = held[event.instrumentId];
      if (holding == null || event.paymentDate?.year != year) continue;
      final Money gross = event.grossPaymentFor(holding.quantity);
      final Instrument? instrument = instruments[event.instrumentId];
      FxConversion? fxConversion;
      Money grossEur = gross;
      if (gross.currency != Currency.eur) {
        fxConversion = FxRateBook(fxRates)
            .convert(gross, Currency.eur, asOf: event.paymentDate!);
        if (fxConversion != null) grossEur = fxConversion.converted;
      }
      if (gross.currency != Currency.eur && fxConversion == null) {
        output[dividendTaxEventKey(event)] = TaxEventEstimate(
          gross: gross,
          result: const UnsupportedTaxCalculation(
            'Net needs a dated EUR exchange rate; native gross was not relabelled.',
          ),
        );
        continue;
      }
      if (instrument?.country == null) {
        output[dividendTaxEventKey(event)] = TaxEventEstimate(
          gross: gross,
          result: const UnsupportedTaxCalculation(
            'Net needs the instrument’s source country.',
          ),
        );
        continue;
      }
      taxable.add((
        event,
        TaxableDividend(
          instrumentId: event.instrumentId,
          sourceCountry: instrument!.country!,
          paymentDate: event.paymentDate!,
          grossEur: grossEur,
        ),
        gross,
        fxConversion,
      ));
    }
    taxable.sort((left, right) {
      final int byDate = left.$2.paymentDate.compareTo(right.$2.paymentDate);
      if (byDate != 0) return byDate;
      final int byInstrument = left.$2.instrumentId.compareTo(
        right.$2.instrumentId,
      );
      return byInstrument != 0
          ? byInstrument
          : dividendTaxEventKey(left.$1)
                .compareTo(dividendTaxEventKey(right.$1));
    });
    final AnnualDividendTaxResult calculated =
        DividendTaxCalculator(settings.table).calculateYear(
          dividends: taxable.map((item) => item.$2).toList(),
          profile: settings.profile,
        );
    for (int index = 0; index < taxable.length; index++) {
      final DividendEvent event = taxable[index].$1;
      output[dividendTaxEventKey(event)] = TaxEventEstimate(
        gross: taxable[index].$3,
        result: calculated.results[index],
        fxConversion: taxable[index].$4,
      );
    }
    return PortfolioTaxEstimates(
      year: year,
      byEventKey: Map<String, TaxEventEstimate>.unmodifiable(output),
    );
  }
}

/// Stable identity shared by screens and annual calculation output.
String dividendTaxEventKey(DividendEvent event) => <Object?>[
  event.instrumentId,
  event.paymentDate?.toIso8601String(),
  event.exDate?.toIso8601String(),
  event.amountPerShare.currency.code,
  event.amountPerShare.amount,
  event.status.name,
].join('|');

/// Tax estimates for every held payment in one calendar year.
final portfolioTaxEstimatesProvider =
    FutureProvider.family<PortfolioTaxEstimates, int>((
      Ref ref,
      int year,
    ) async {
      final List<Holding> holdings = await ref.watch(holdingsProvider.future);
      final Map<String, Instrument> instruments = await ref.watch(
        instrumentsByIdProvider.future,
      );
      final TaxSettings settings = await ref.watch(taxSettingsProvider.future);
      final Set<String> ids = <String>{
        for (final Holding holding in holdings) holding.instrumentId,
      };
      final List<DividendEvent> events = await ref.watch(
        calendarEventsProvider(
          CalendarEventsQuery(
            range: DateRange(DateTime(year), DateTime(year + 1)),
            dateMode: DividendDateMode.paymentDate,
            instrumentIds: ids,
          ),
        ).future,
      );
      final bool needsFx = events.any(
        (DividendEvent event) => event.amountPerShare.currency != Currency.eur,
      );
      final List<FxRate> fxRates = needsFx
          ? await ref.watch(cachedFxRatesProvider.future)
          : const <FxRate>[];
      return PortfolioTaxEstimator.calculate(
        year: year,
        events: events,
        holdings: holdings,
        instruments: instruments,
        settings: settings,
        fxRates: fxRates,
      );
    });
