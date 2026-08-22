import 'dart:convert';

import 'package:dividendendackel/domain/analytics/analytics.dart';
import 'package:dividendendackel/domain/value_objects/value_objects.dart';
import 'package:flutter/services.dart' show AssetBundle, rootBundle;

/// Loads and validates the bundled withholding starter table.
abstract final class WithholdingRateLoader {
  /// Bundled asset path.
  static const String assetPath = 'assets/tax/withholding_rates.json';

  /// Reads from the application bundle.
  static Future<WithholdingRateTable> load({AssetBundle? bundle}) async =>
      parse(await (bundle ?? rootBundle).loadString(assetPath));

  /// Parses JSON independently for contract tests and user-edited imports.
  static WithholdingRateTable parse(String source) {
    final Object? decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Tax table root must be an object.');
    }
    final int version = _int(decoded, 'version');
    final DateTime asOf = DateTime.parse(_string(decoded, 'asOf'));
    final String sourceName = _string(decoded, 'source');
    final String sourceUrl = _string(decoded, 'sourceUrl');
    final Object? rawRates = decoded['rates'];
    if (rawRates is! Map<String, dynamic> || rawRates.isEmpty) {
      throw const FormatException(
        'Tax table rates must be a non-empty object.',
      );
    }
    final Map<String, WithholdingRule> rates = <String, WithholdingRule>{};
    for (final MapEntry<String, dynamic> entry in rawRates.entries) {
      if (entry.value is! Map<String, dynamic>) {
        throw FormatException('Rate ${entry.key} must be an object.');
      }
      final Map<String, dynamic> value = entry.value as Map<String, dynamic>;
      final String country = entry.key.trim().toUpperCase();
      if (!RegExp(r'^[A-Z]{2}$').hasMatch(country)) {
        throw FormatException('Invalid country code ${entry.key}.');
      }
      rates[country] = WithholdingRule(
        country: country,
        statutoryRate: Percentage.parsePercent(_string(value, 'statutory')),
        treatyRateWithForms: Percentage.parsePercent(
          _string(value, 'treatyWithForms'),
        ),
        creditableCap: Percentage.parsePercent(_string(value, 'creditableCap')),
      );
    }
    return WithholdingRateTable(
      version: version,
      asOf: asOf,
      source: sourceName,
      sourceUrl: sourceUrl,
      rates: rates,
    );
  }

  static String _string(Map<String, dynamic> object, String key) {
    final Object? value = object[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('$key must be a non-empty string.');
    }
    return value;
  }

  static int _int(Map<String, dynamic> object, String key) {
    final Object? value = object[key];
    if (value is! int) throw FormatException('$key must be an integer.');
    return value;
  }
}
