import 'package:dividend_tracker/core/logging/logging.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LogRedactor', () {
    final LogRedactor redactor = LogRedactor();

    test('redacts credentials', () {
      expect(
        redactor.redact(<String, Object?>{'apiKey': 'abc123'}),
        <String, Object?>{'apiKey': LogRedactor.placeholder},
      );
      expect(redactor.isSensitive('Authorization'), isTrue);
      expect(redactor.isSensitive('bearerToken'), isTrue);
      expect(redactor.isSensitive('userSecret'), isTrue);
    });

    test('redacts portfolio content', () {
      expect(redactor.isSensitive('quantity'), isTrue);
      expect(redactor.isSensitive('purchasePrice'), isTrue);
      expect(redactor.isSensitive('expectedIncome'), isTrue);
      expect(redactor.isSensitive('portfolioValue'), isTrue);
      expect(redactor.isSensitive('notes'), isTrue);
    });

    test('keeps instrument identity readable for debugging', () {
      const Map<String, Object?> fields = <String, Object?>{
        'symbol': 'ALV',
        'exchange': 'XETR',
        'isin': 'DE0008404005',
        'cacheHit': true,
        'retries': 2,
      };

      expect(redactor.redact(fields), fields);
    });

    test('matches keys case-insensitively and by substring', () {
      expect(redactor.isSensitive('API_KEY'), isTrue);
      expect(redactor.isSensitive('grossAmountEur'), isTrue);
      expect(redactor.isSensitive('exchange'), isFalse);
    });

    test('redacts nested maps and lists', () {
      final Map<String, Object?> result = redactor.redact(<String, Object?>{
        'request': <String, Object?>{'symbol': 'AAPL', 'apiKey': 'abc123'},
        'events': <Object?>[
          <String, Object?>{'symbol': 'ALV', 'amount': 276.0},
        ],
      });

      expect(result['request'], <String, Object?>{
        'symbol': 'AAPL',
        'apiKey': LogRedactor.placeholder,
      });
      expect(result['events'], <Object?>[
        <String, Object?>{'symbol': 'ALV', 'amount': LogRedactor.placeholder},
      ]);
    });

    test('leaves an empty field map untouched', () {
      expect(redactor.redact(const <String, Object?>{}), isEmpty);
    });

    test('accepts additional sensitive keys', () {
      final LogRedactor strict = LogRedactor(
        additionalSensitiveKeys: const <String>{'broker'},
      );

      expect(strict.isSensitive('broker'), isTrue);
      expect(strict.isSensitive('apiKey'), isTrue);
    });

    test('accepts a replacement key set', () {
      final LogRedactor custom = LogRedactor(
        sensitiveKeys: const <String>{'only'},
      );

      expect(custom.isSensitive('onlyThis'), isTrue);
      expect(custom.isSensitive('apiKey'), isFalse);
    });
  });
}
