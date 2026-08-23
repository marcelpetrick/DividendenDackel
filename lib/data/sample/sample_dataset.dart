import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:dividendendackel/core/errors/failure.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:flutter/services.dart' show rootBundle;

/// The bundled offline dataset (Vision.md §44, §51).
///
/// Lets every screen be populated and explored with no API key and no network,
/// which is also what makes the empty states, calendar and forecast testable.
///
/// The data is **illustrative, not real market data**. Everything materialized
/// from it carries `Provenance.sample`, and the UI must label it as such — the
/// vision's whole stance on transparency (§2.5) would be hollow if invented
/// numbers were shown as though a provider had supplied them.
final class SampleDataset {
  const SampleDataset._({
    required this.instruments,
    required this.dividendPatterns,
    required this.earningsPatterns,
    required this.corporateEventPatterns,
    required this.portfolio,
    required this.watchlist,
    required this.news,
  });

  /// Path of the bundled asset.
  static const String assetPath = 'assets/sample/dataset.json';

  /// Instruments in the dataset.
  final List<SampleInstrument> instruments;

  /// Recurring dividend schedules.
  final List<SampleDividendPattern> dividendPatterns;

  /// Recurring earnings schedules.
  final List<SampleEarningsPattern> earningsPatterns;

  /// Recurring illustrative company events.
  final List<SampleCorporateEventPattern> corporateEventPatterns;

  /// The demonstration portfolio.
  final List<SampleHolding> portfolio;

  /// The demonstration watchlist.
  final List<SampleWatchlistEntry> watchlist;

  /// Illustrative headlines.
  final List<SampleNews> news;

  /// Loads the dataset from the application bundle.
  static Future<SampleDataset> loadFromBundle() async =>
      parse(await rootBundle.loadString(assetPath));

  /// Parses the dataset from [source].
  ///
  /// Malformed data raises a [ParsingFailure]: the bundled asset is shipped
  /// with the app, so a failure here is a build defect worth surfacing rather
  /// than something to paper over.
  static SampleDataset parse(String source) {
    try {
      final Map<String, dynamic> json =
          jsonDecode(source) as Map<String, dynamic>;

      return SampleDataset._(
        instruments: _list(json, 'instruments', SampleInstrument._fromJson),
        dividendPatterns: _list(
          json,
          'dividendPatterns',
          SampleDividendPattern._fromJson,
        ),
        earningsPatterns: _list(
          json,
          'earningsPatterns',
          SampleEarningsPattern._fromJson,
        ),
        corporateEventPatterns: _list(
          json,
          'corporateEventPatterns',
          SampleCorporateEventPattern._fromJson,
        ),
        portfolio: _list(json, 'portfolio', SampleHolding._fromJson),
        watchlist: _list(json, 'watchlist', SampleWatchlistEntry._fromJson),
        news: _list(json, 'news', SampleNews._fromJson),
      );
    } on Failure {
      rethrow;
    } on Object catch (error, stackTrace) {
      throw ParsingFailure(
        technicalDetail: 'Sample dataset is malformed: $error\n$stackTrace',
        cause: error,
      );
    }
  }

  static List<T> _list<T>(
    Map<String, dynamic> json,
    String key,
    T Function(Map<String, dynamic>) build,
  ) {
    final Object? raw = json[key];
    if (raw is! List<dynamic>) {
      throw ParsingFailure(
        technicalDetail: 'Sample dataset is missing the "$key" list',
      );
    }
    return raw.cast<Map<String, dynamic>>().map(build).toList(growable: false);
  }

  /// Every instrument id referenced anywhere in the dataset resolves.
  ///
  /// Guards against a typo in the asset silently producing an empty calendar.
  bool get isReferentiallyComplete {
    final Set<String> ids = instruments
        .map((SampleInstrument i) => i.internalId)
        .toSet();
    return <Iterable<String>>[
      dividendPatterns.map((SampleDividendPattern p) => p.instrumentId),
      earningsPatterns.map((SampleEarningsPattern p) => p.instrumentId),
      corporateEventPatterns.map(
        (SampleCorporateEventPattern p) => p.instrumentId,
      ),
      portfolio.map((SampleHolding h) => h.instrumentId),
      watchlist.map((SampleWatchlistEntry w) => w.instrumentId),
      news.map((SampleNews n) => n.instrumentId),
    ].every((Iterable<String> refs) => refs.every(ids.contains));
  }
}

/// An instrument in the sample dataset.
final class SampleInstrument {
  const SampleInstrument._({
    required this.internalId,
    required this.instrument,
    required this.price,
    required this.previousClose,
  });

  factory SampleInstrument._fromJson(Map<String, dynamic> json) {
    final Currency currency = Currency.parse(json['currency'] as String);
    final String internalId = json['internalId'] as String;
    return SampleInstrument._(
      internalId: internalId,
      instrument: Instrument(
        internalId: internalId,
        symbol: json['symbol'] as String,
        name: json['name'] as String,
        currency: currency,
        exchange: json['exchange'] as String?,
        mic: json['mic'] as String?,
        isin: json['isin'] as String?,
        country: json['country'] as String?,
        sector: json['sector'] as String?,
        providerMappings:
            (json['providerMappings'] as List<dynamic>? ?? const <dynamic>[])
                .cast<Map<String, dynamic>>()
                .map(
                  (Map<String, dynamic> mapping) => ProviderMapping(
                    providerId: mapping['providerId'] as String,
                    symbol: mapping['symbol'] as String,
                    providerInstrumentId:
                        mapping['providerInstrumentId'] as String?,
                  ),
                )
                .toList(growable: false),
      ),
      price: Money(Decimal.parse(json['price'] as String), currency),
      previousClose: Money(
        Decimal.parse(json['previousClose'] as String),
        currency,
      ),
    );
  }

  /// App-internal identifier.
  final String internalId;

  /// The domain instrument.
  final Instrument instrument;

  /// Illustrative last price.
  final Money price;

  /// Illustrative previous close.
  final Money previousClose;
}

/// A recurring dividend schedule, materialized around a reference date.
///
/// Stored as a pattern rather than fixed dates so the calendar is populated
/// whenever the app is run, instead of only during the year the asset was
/// written.
final class SampleDividendPattern {
  const SampleDividendPattern._({
    required this.instrumentId,
    required this.currency,
    required this.currentAnnualAmount,
    required this.frequency,
    required this.anchors,
    required this.paymentOffsetDays,
    required this.annualGrowthRate,
    required this.historyYears,
  });

  factory SampleDividendPattern._fromJson(Map<String, dynamic> json) =>
      SampleDividendPattern._(
        instrumentId: json['instrumentId'] as String,
        currency: Currency.parse(json['currency'] as String),
        currentAnnualAmount: Decimal.parse(
          json['currentAnnualAmount'] as String,
        ),
        frequency: _frequency(json['frequency'] as String),
        anchors: (json['anchors'] as List<dynamic>)
            .cast<String>()
            .map(MonthDay.parse)
            .toList(growable: false),
        paymentOffsetDays: json['paymentOffsetDays'] as int,
        annualGrowthRate: Percentage.parsePercent(
          json['annualGrowthPercent'] as String,
        ),
        historyYears: json['historyYears'] as int,
      );

  static DividendFrequency _frequency(String raw) => switch (raw) {
    'monthly' => DividendFrequency.monthly,
    'quarterly' => DividendFrequency.quarterly,
    'semiAnnual' => DividendFrequency.semiAnnual,
    'annual' => DividendFrequency.annual,
    _ => DividendFrequency.irregular,
  };

  /// The paying instrument.
  final String instrumentId;

  /// Currency of the payments.
  final Currency currency;

  /// Total paid per share across the current year.
  final Decimal currentAnnualAmount;

  /// How often it pays.
  final DividendFrequency frequency;

  /// Ex-dates within a year, as month and day.
  final List<MonthDay> anchors;

  /// Days between the ex-date and the payment date.
  final int paymentOffsetDays;

  /// Year-on-year growth used to derive history and forecasts.
  final Percentage annualGrowthRate;

  /// How many past years to generate.
  final int historyYears;

  /// The amount of a single payment in the current year.
  Decimal get amountPerPayment => anchors.isEmpty
      ? Decimal.zero
      : (currentAnnualAmount / Decimal.fromInt(anchors.length)).toDecimal(
          scaleOnInfinitePrecision: 6,
        );
}

/// A recurring earnings schedule.
final class SampleEarningsPattern {
  const SampleEarningsPattern._({
    required this.instrumentId,
    required this.anchors,
    required this.timing,
  });

  factory SampleEarningsPattern._fromJson(Map<String, dynamic> json) =>
      SampleEarningsPattern._(
        instrumentId: json['instrumentId'] as String,
        anchors: (json['anchors'] as List<dynamic>)
            .cast<String>()
            .map(MonthDay.parse)
            .toList(growable: false),
        timing: switch (json['timing'] as String) {
          'beforeMarketOpen' => EarningsTiming.beforeMarketOpen,
          'afterMarketClose' => EarningsTiming.afterMarketClose,
          'duringMarketHours' => EarningsTiming.duringMarketHours,
          _ => EarningsTiming.unspecified,
        },
      );

  /// The reporting instrument.
  final String instrumentId;

  /// Reporting dates within a year.
  final List<MonthDay> anchors;

  /// When during the day it reports.
  final EarningsTiming timing;
}

/// A recurring illustrative company-event schedule.
final class SampleCorporateEventPattern {
  const SampleCorporateEventPattern._({
    required this.instrumentId,
    required this.anchor,
    required this.type,
    required this.title,
  });

  factory SampleCorporateEventPattern._fromJson(Map<String, dynamic> json) =>
      SampleCorporateEventPattern._(
        instrumentId: json['instrumentId'] as String,
        anchor: MonthDay.parse(json['anchor'] as String),
        type: CorporateEventType.values.firstWhere(
          (CorporateEventType type) => type.name == json['type'],
          orElse: () => CorporateEventType.other,
        ),
        title: json['title'] as String,
      );

  /// Company instrument.
  final String instrumentId;

  /// Annual month/day anchor.
  final MonthDay anchor;

  /// Normalized category.
  final CorporateEventType type;

  /// Display label.
  final String title;
}

/// A position in the demonstration portfolio.
final class SampleHolding {
  const SampleHolding._({
    required this.instrumentId,
    required this.quantity,
    required this.averagePrice,
    required this.purchaseOffsetDays,
  });

  factory SampleHolding._fromJson(Map<String, dynamic> json) => SampleHolding._(
    instrumentId: json['instrumentId'] as String,
    quantity: Decimal.parse(json['quantity'] as String),
    averagePrice: Decimal.parse(json['averagePrice'] as String),
    purchaseOffsetDays: json['purchaseOffsetDays'] as int,
  );

  /// The held instrument.
  final String instrumentId;

  /// Share count.
  final Decimal quantity;

  /// Average purchase price per share.
  final Decimal averagePrice;

  /// Days before the reference date the position was opened. Negative.
  final int purchaseOffsetDays;
}

/// An entry in the demonstration watchlist.
final class SampleWatchlistEntry {
  const SampleWatchlistEntry._({
    required this.instrumentId,
    required this.addedOffsetDays,
  });

  factory SampleWatchlistEntry._fromJson(Map<String, dynamic> json) =>
      SampleWatchlistEntry._(
        instrumentId: json['instrumentId'] as String,
        addedOffsetDays: json['addedOffsetDays'] as int,
      );

  /// The watched instrument.
  final String instrumentId;

  /// Days before the reference date it was added. Negative.
  final int addedOffsetDays;
}

/// An illustrative headline.
final class SampleNews {
  const SampleNews._({
    required this.instrumentId,
    required this.headline,
    required this.sourceName,
    required this.url,
    required this.category,
    required this.offsetHours,
  });

  factory SampleNews._fromJson(Map<String, dynamic> json) => SampleNews._(
    instrumentId: json['instrumentId'] as String,
    headline: json['headline'] as String,
    sourceName: json['source'] as String,
    url: Uri.parse(json['url'] as String),
    category: _category(json['category'] as String),
    offsetHours: json['offsetHours'] as int,
  );

  static NewsCategory _category(String raw) => NewsCategory.values.firstWhere(
    (NewsCategory c) => c.name == raw,
    orElse: () => NewsCategory.general,
  );

  /// The instrument the headline concerns.
  final String instrumentId;

  /// The headline text.
  final String headline;

  /// Publication name.
  final String sourceName;

  /// Original publisher page, or the reserved sample page for sample rows.
  final Uri url;

  /// Category of the item.
  final NewsCategory category;

  /// Hours before the reference date it was published. Negative.
  final int offsetHours;
}

/// A day of the year without a year attached.
final class MonthDay {
  /// Creates a month and day.
  const MonthDay(this.month, this.day);

  /// Parses `MM-DD`.
  factory MonthDay.parse(String raw) {
    final List<String> parts = raw.split('-');
    if (parts.length != 2) {
      throw ParsingFailure(technicalDetail: 'Malformed month-day: "$raw"');
    }
    final int? month = int.tryParse(parts[0]);
    final int? day = int.tryParse(parts[1]);
    if (month == null || day == null || month < 1 || month > 12 || day < 1) {
      throw ParsingFailure(technicalDetail: 'Malformed month-day: "$raw"');
    }
    return MonthDay(month, day);
  }

  /// Month, 1 to 12.
  final int month;

  /// Day of the month.
  final int day;

  /// This month and day in [year], clamped to the length of the month.
  DateTime inYear(int year) {
    final int lastDay = DateTime.utc(year, month + 1, 0).day;
    return DateTime.utc(year, month, day > lastDay ? lastDay : day);
  }

  @override
  String toString() =>
      '${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) =>
      other is MonthDay && other.month == month && other.day == day;

  @override
  int get hashCode => Object.hash(month, day);
}
