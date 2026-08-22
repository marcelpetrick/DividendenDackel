import 'package:dividendendackel/core/errors/result.dart';
import 'package:dividendendackel/core/networking/request_coordinator.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/domain/repositories/repositories.dart';

/// Domain data categories a provider may supply.
enum ProviderDataType {
  /// Instrument lookup by name, ticker, exchange or ISIN.
  instrumentSearch,

  /// Latest price.
  quote,

  /// Historical, announced or estimated dividends.
  dividends,

  /// Earnings dates and results.
  earnings,

  /// News metadata linking to the original source.
  news,

  /// Regulatory filing metadata.
  filings,
}

/// Identity and declared capabilities shared by every adapter.
abstract interface class MarketDataProvider {
  /// Stable identifier used in configuration, logs and provenance.
  String get id;

  /// Data categories this adapter currently implements.
  Set<ProviderDataType> get capabilities;
}

/// Instrument search adapter contract.
abstract interface class InstrumentSearchProvider
    implements MarketDataProvider {
  /// Searches and returns normalized domain instruments.
  Future<Result<List<Instrument>>> searchInstruments(
    String query, {
    required int limit,
    required CancellationToken cancellationToken,
  });
}

/// Quote adapter contract.
abstract interface class QuoteDataProvider implements MarketDataProvider {
  /// Retrieves a normalized quote for [instrument].
  Future<Result<Quote>> fetchQuote(
    Instrument instrument, {
    required CancellationToken cancellationToken,
  });
}

/// Dividend adapter contract.
abstract interface class DividendDataProvider implements MarketDataProvider {
  /// Retrieves normalized dividends inside [range].
  Future<Result<List<DividendEvent>>> fetchDividends(
    Instrument instrument,
    DateRange range, {
    required CancellationToken cancellationToken,
  });
}

/// Earnings adapter contract.
abstract interface class EarningsDataProvider implements MarketDataProvider {
  /// Retrieves normalized earnings events inside [range].
  Future<Result<List<EarningsEvent>>> fetchEarnings(
    Instrument instrument,
    DateRange range, {
    required CancellationToken cancellationToken,
  });
}

/// News adapter contract.
abstract interface class NewsDataProvider implements MarketDataProvider {
  /// Retrieves normalized news metadata, never full article bodies.
  Future<Result<List<NewsItem>>> fetchNews(
    Instrument instrument, {
    required int limit,
    required CancellationToken cancellationToken,
  });
}

/// Filing adapter contract.
abstract interface class FilingDataProvider implements MarketDataProvider {
  /// Retrieves normalized filing metadata inside [range].
  Future<Result<List<Filing>>> fetchFilings(
    Instrument instrument,
    DateRange range, {
    required CancellationToken cancellationToken,
  });
}

/// Whether [provider] actually implements the contract it advertises.
bool providerImplementsCapability(
  MarketDataProvider provider,
  ProviderDataType capability,
) => switch (capability) {
  ProviderDataType.instrumentSearch => provider is InstrumentSearchProvider,
  ProviderDataType.quote => provider is QuoteDataProvider,
  ProviderDataType.dividends => provider is DividendDataProvider,
  ProviderDataType.earnings => provider is EarningsDataProvider,
  ProviderDataType.news => provider is NewsDataProvider,
  ProviderDataType.filings => provider is FilingDataProvider,
};
