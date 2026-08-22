import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cache hit rate is absent before a cache lookup', () {
    final ProviderStatus status = ProviderStatus(providerId: 'sec');

    expect(status.cacheHitRate, isNull);
  });

  test('cache hit rate uses both hits and misses', () {
    final ProviderStatus status = ProviderStatus(
      providerId: 'sec',
      cacheHits: 3,
      cacheMisses: 1,
    );

    expect(status.cacheHitRate, 0.75);
  });

  test('rejects invalid identifiers and counters', () {
    expect(() => ProviderStatus(providerId: ' '), throwsArgumentError);
    expect(
      () => ProviderStatus(providerId: 'sec', cacheHits: -1),
      throwsArgumentError,
    );
  });
}
