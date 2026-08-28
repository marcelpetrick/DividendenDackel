import 'package:dividendendackel/features/settings/data_source_settings.dart';

/// Step-by-step instructions for obtaining a provider credential.
///
/// A setting that says "API key required" and nothing else asks the user to go
/// and find out how, which most people will not do. These say where to go, what
/// to click and what to copy back, in the order it happens.
final class DataSourceGuide {
  /// Creates a guide.
  const DataSourceGuide({
    required this.source,
    required this.summary,
    required this.steps,
    required this.signUpUrl,
    this.caveat,
  });

  /// The provider this guide explains.
  final MarketDataSource source;

  /// One line on what the credential buys, before the effort is spent.
  final String summary;

  /// What to do, in order. Each step is one action.
  final List<String> steps;

  /// Page where the credential is obtained.
  final String signUpUrl;

  /// What to expect afterwards, when it is not obvious.
  final String? caveat;

  /// The guide for [source], or null when the source needs no credential.
  static DataSourceGuide? forSource(MarketDataSource source) => _guides[source];

  static const Map<MarketDataSource, DataSourceGuide>
  _guides = <MarketDataSource, DataSourceGuide>{
    MarketDataSource.alphaVantage: DataSourceGuide(
      source: MarketDataSource.alphaVantage,
      summary:
          'Prices for shares outside the United States, including German '
          'listings. Without it, those holdings show no value.',
      steps: <String>[
        'Open alphavantage.co/support/#api-key in a browser.',
        'Enter your email address and what you are building — a personal '
            'portfolio tracker is a fine answer.',
        'Press "GET FREE API KEY". The key appears on the page itself.',
        'Copy the key, return here and press "Add key".',
      ],
      signUpUrl: 'https://www.alphavantage.co/support/#api-key',
      caveat:
          'The free plan allows 25 price requests per day and returns each '
          'day\'s closing price rather than a live one. The app requests at '
          'most one price per holding per trading day and stops before the '
          'limit, so a portfolio of up to about 25 holdings is covered.',
    ),
    MarketDataSource.finnhub: DataSourceGuide(
      source: MarketDataSource.finnhub,
      summary:
          'Optional market data. The free plan covers US listings; other '
          'markets need a paid plan.',
      steps: <String>[
        'Open finnhub.io/register in a browser.',
        'Register with an email address and confirm it.',
        'Open the dashboard; the API key is shown there.',
        'Copy the key, return here and press "Add key".',
      ],
      signUpUrl: 'https://finnhub.io/register',
    ),
    MarketDataSource.financialModelingPrep: DataSourceGuide(
      source: MarketDataSource.financialModelingPrep,
      summary:
          'Optional fundamentals and calendars. The free plan is limited '
          'and covers mostly US listings.',
      steps: <String>[
        'Open site.financialmodelingprep.com/developer/docs/dashboard in a '
            'browser.',
        'Create an account and confirm your email address.',
        'The dashboard shows your API key.',
        'Copy the key, return here and press "Add key".',
      ],
      signUpUrl:
          'https://site.financialmodelingprep.com/developer/docs/dashboard',
    ),
  };
}
