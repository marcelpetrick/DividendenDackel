/// Keeps user-sensitive values out of the logs (Vision.md §56, §80).
///
/// The vision forbids logging sensitive user information and forbids portfolio
/// content in crash logs by default. Rather than relying on every call site to
/// remember that, structured fields pass through a redactor: anything whose key
/// looks like a credential or like portfolio content is replaced with
/// [LogRedactor.placeholder] before it reaches a sink.
///
/// Instrument identity (symbol, exchange, ISIN) is intentionally *not*
/// redacted — it is needed to debug provider issues and does not reveal how
/// much of an instrument the user owns.
final class LogRedactor {
  /// Creates a redactor. Pass [additionalSensitiveKeys] to redact more keys,
  /// or [sensitiveKeys] to replace the defaults entirely.
  LogRedactor({
    Set<String>? sensitiveKeys,
    Set<String> additionalSensitiveKeys = const <String>{},
  }) : _sensitiveKeys = <String>{
         ...(sensitiveKeys ?? defaultSensitiveKeys),
         ...additionalSensitiveKeys,
       }.map((String key) => key.toLowerCase()).toSet();

  /// Substrings that mark a field key as sensitive. Matching is
  /// case-insensitive and by substring, so `purchasePrice` matches `price`.
  static const Set<String> defaultSensitiveKeys = <String>{
    // Credentials (Vision.md §34).
    'apikey', 'key', 'token', 'secret', 'password', 'credential', 'auth',
    // Portfolio content (Vision.md §80).
    'quantity', 'shares', 'amount', 'price', 'value', 'cost', 'balance',
    'income', 'payout', 'position', 'holding', 'portfolio', 'notes', 'total',
  };

  /// Replacement written in place of a sensitive value.
  static const String placeholder = '<redacted>';

  final Set<String> _sensitiveKeys;

  /// Whether [key] is considered sensitive.
  bool isSensitive(String key) {
    final String lower = key.toLowerCase();
    return _sensitiveKeys.any(lower.contains);
  }

  /// Returns a copy of [fields] with every sensitive value replaced.
  ///
  /// Nested maps are redacted recursively; nested lists have their map entries
  /// redacted so a list of holdings cannot leak through.
  Map<String, Object?> redact(Map<String, Object?> fields) {
    if (fields.isEmpty) {
      return const <String, Object?>{};
    }
    return <String, Object?>{
      for (final MapEntry<String, Object?> entry in fields.entries)
        entry.key: isSensitive(entry.key)
            ? placeholder
            : _redactValue(entry.value),
    };
  }

  Object? _redactValue(Object? value) => switch (value) {
    final Map<String, Object?> map => redact(map),
    final List<Object?> list => list.map(_redactValue).toList(growable: false),
    _ => value,
  };
}
