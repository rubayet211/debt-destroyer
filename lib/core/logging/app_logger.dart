import 'dart:convert';
import 'dart:developer' as developer;

class AppLogger {
  AppLogger._();

  static final instance = AppLogger._();
  static const _loggerName = 'debt_destroyer';
  static const _redactedPlaceholder = '[redacted]';
  static const _allowedKeys = {
    'event',
    'category',
    'status',
    'code',
    'requestId',
    'screen',
    'operation',
    'environment',
    'warning',
    'count',
  };
  static const _forbiddenKeys = {
    'ocr',
    'text',
    'payload',
    'creditor',
    'balance',
    'amount',
    'path',
    'storageref',
    'token',
    'secret',
    'authorization',
    'note',
  };

  void info(String event, {Map<String, Object?> context = const {}}) {
    final sanitized = _sanitizeContext(event, context);
    developer.log(jsonEncode(sanitized), name: _loggerName);
  }

  void error(
    String event,
    Object error,
    StackTrace stackTrace, {
    Map<String, Object?> context = const {},
  }) {
    final sanitized = _sanitizeContext(event, context);
    developer.log(
      jsonEncode(sanitized),
      name: _loggerName,
      error: _summarizeValue(error),
      stackTrace: stackTrace,
      level: 1000,
    );
  }

  String sanitizeForTest(String input) => _sanitizeString(input);

  Map<String, Object?> sanitizeContextForTest(
    String event,
    Map<String, Object?> context,
  ) {
    return _sanitizeContext(event, context);
  }

  Map<String, Object?> _sanitizeContext(
    String event,
    Map<String, Object?> context,
  ) {
    final sanitized = <String, Object?>{'event': _sanitizeString(event)};
    for (final entry in context.entries) {
      sanitized[entry.key] = _sanitizeEntry(entry.key, entry.value);
    }
    assert(() {
      for (final entry in sanitized.entries) {
        _assertSafe(entry.key, entry.value);
      }
      return true;
    }());
    return sanitized;
  }

  Object? _sanitizeEntry(String key, Object? value) {
    final normalizedKey = key.toLowerCase();
    if (_matchesForbiddenKey(normalizedKey)) {
      return _redactedPlaceholder;
    }
    if (_allowedKeys.contains(key)) {
      return _summarizeValue(value);
    }
    if (value is num || value is bool || value == null) {
      return value;
    }
    return _summarizeValue(value);
  }

  Object? _summarizeValue(Object? value) {
    if (value == null || value is num || value is bool) {
      return value;
    }
    if (value is DateTime) {
      return value.toIso8601String();
    }
    if (value is Iterable) {
      return 'list(len=${value.length})';
    }
    if (value is Map) {
      return 'map(keys=${value.keys.length})';
    }
    return _sanitizeString(value.toString());
  }

  String _sanitizeString(String input) {
    final compact = input.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (compact.isEmpty) {
      return compact;
    }
    final lowered = compact.toLowerCase();
    if (_forbiddenKeys.any(lowered.contains)) {
      return _redactedPlaceholder;
    }
    if (compact.length > 96) {
      return '${compact.substring(0, 24)}…(${compact.length} chars)';
    }
    return compact;
  }

  bool _matchesForbiddenKey(String key) {
    return _forbiddenKeys.any(key.contains);
  }

  void _assertSafe(String key, Object? value) {
    if (_matchesForbiddenKey(key.toLowerCase())) {
      throw StateError('Sensitive log key detected: $key');
    }
    if (value is String && value == _redactedPlaceholder) {
      return;
    }
    final asString = value?.toString().toLowerCase() ?? '';
    if (_forbiddenKeys.any(asString.contains)) {
      throw StateError('Sensitive log value detected for key: $key');
    }
  }
}
