import 'package:dividendendackel/domain/entities/instrument.dart';
import 'package:dividendendackel/domain/value_objects/currency.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const Instrument allianz = Instrument(
    internalId: 'isin:DE0008404005',
    symbol: 'ALV',
    name: 'Allianz SE',
    currency: Currency.eur,
    exchange: 'XETRA',
    mic: 'XETR',
    isin: 'DE0008404005',
    country: 'DE',
    sector: 'Financials',
    providerMappings: <ProviderMapping>[
      ProviderMapping(providerId: 'fmp', symbol: 'ALV.DE'),
      ProviderMapping(providerId: 'finnhub', symbol: 'ALV.XETRA'),
    ],
  );

  group('Instrument.buildInternalId', () {
    test('prefers the globally unique ISIN', () {
      expect(
        Instrument.buildInternalId(
          symbol: 'ALV',
          isin: 'DE0008404005',
          mic: 'XETR',
        ),
        'isin:DE0008404005',
      );
    });

    test('qualifies the symbol by market when there is no ISIN', () {
      expect(
        Instrument.buildInternalId(symbol: 'ALV', mic: 'XETR'),
        'sym:ALV@XETR',
      );
      expect(
        Instrument.buildInternalId(symbol: 'ALV', exchange: 'XETRA'),
        'sym:ALV@XETRA',
      );
    });

    test('disambiguates the same ticker on different markets', () {
      expect(
        Instrument.buildInternalId(symbol: 'ALV', mic: 'XETR'),
        isNot(Instrument.buildInternalId(symbol: 'ALV', mic: 'XNYS')),
      );
    });

    test('normalizes case and whitespace', () {
      expect(
        Instrument.buildInternalId(symbol: ' alv ', mic: ' xetr '),
        'sym:ALV@XETR',
      );
      expect(
        Instrument.buildInternalId(symbol: 'ALV', isin: ' de0008404005 '),
        'isin:DE0008404005',
      );
    });

    test('falls back to a bare symbol only when nothing else is known', () {
      expect(Instrument.buildInternalId(symbol: 'AAPL'), 'sym:AAPL');
      expect(
        Instrument.buildInternalId(symbol: 'AAPL', mic: '   '),
        'sym:AAPL',
      );
    });

    test('rejects an empty symbol', () {
      expect(
        () => Instrument.buildInternalId(symbol: '  '),
        throwsArgumentError,
      );
    });
  });

  group('Instrument', () {
    test('resolves the symbol each provider expects', () {
      expect(allianz.symbolFor('fmp'), 'ALV.DE');
      expect(allianz.symbolFor('finnhub'), 'ALV.XETRA');
      expect(allianz.symbolFor('sec'), isNull);
      expect(allianz.hasMappingFor('fmp'), isTrue);
      expect(allianz.hasMappingFor('sec'), isFalse);
    });

    test('prefers the MIC as the market', () {
      expect(allianz.market, 'XETR');
      const Instrument withoutMic = Instrument(
        internalId: 'sym:ALV@XETRA',
        symbol: 'ALV',
        name: 'Allianz SE',
        currency: Currency.eur,
        exchange: 'XETRA',
      );
      expect(withoutMic.market, 'XETRA');
    });

    test('copyWith keeps a field when passed null, so it cannot clear one', () {
      // Documented limitation: build a fresh instrument to drop a field.
      expect(allianz.copyWith(mic: null).mic, 'XETR');
    });

    test('renders a disambiguated display symbol', () {
      expect(allianz.displaySymbol, 'ALV · XETR');
      const Instrument bare = Instrument(
        internalId: 'sym:AAPL',
        symbol: 'AAPL',
        name: 'Apple Inc.',
        currency: Currency.usd,
      );
      expect(bare.displaySymbol, 'AAPL');
    });

    test('identity is the internal id, not the ticker', () {
      const Instrument enriched = Instrument(
        internalId: 'isin:DE0008404005',
        symbol: 'ALV',
        name: 'Allianz SE Registered Shares',
        currency: Currency.eur,
      );
      const Instrument otherAlv = Instrument(
        internalId: 'sym:ALV@XNYS',
        symbol: 'ALV',
        name: 'Something else entirely',
        currency: Currency.usd,
      );

      expect(allianz, enriched);
      expect(allianz.hashCode, enriched.hashCode);
      expect(allianz, isNot(otherAlv));
    });

    test('copyWith replaces only the named fields', () {
      final Instrument renamed = allianz.copyWith(name: 'Allianz');

      expect(renamed.name, 'Allianz');
      expect(renamed.isin, 'DE0008404005');
      expect(renamed.providerMappings, allianz.providerMappings);
    });
  });

  group('ProviderMapping', () {
    test('compares by value', () {
      expect(
        const ProviderMapping(providerId: 'fmp', symbol: 'ALV.DE'),
        const ProviderMapping(providerId: 'fmp', symbol: 'ALV.DE'),
      );
      expect(
        const ProviderMapping(providerId: 'fmp', symbol: 'ALV.DE'),
        isNot(const ProviderMapping(providerId: 'fmp', symbol: 'ALV.F')),
      );
    });

    test('renders as provider:symbol', () {
      expect(
        const ProviderMapping(providerId: 'fmp', symbol: 'ALV.DE').toString(),
        'fmp:ALV.DE',
      );
    });
  });
}
