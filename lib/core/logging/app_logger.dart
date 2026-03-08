import 'dart:developer' as developer;

class AppLogger {
  AppLogger._();

  static final instance = AppLogger._();
  static const _forbiddenTokens = [
    'ocr',
    'token',
    'refresh',
    'attestation',
    'balance',
    'note',
    'path',
    'authorization',
    'secret',
  ];

  void info(String message) {
    developer.log(_sanitize(message), name: 'debt_destroyer');
  }

  void error(String message, Object error, StackTrace stackTrace) {
    developer.log(
      _sanitize(message),
      name: 'debt_destroyer',
      error: _sanitize(error.toString()),
      stackTrace: stackTrace,
      level: 1000,
    );
  }

  String sanitizeForTest(String input) => _sanitize(input);

  String _sanitize(String input) {
    var sanitized = input;
    for (final token in _forbiddenTokens) {
      final pattern = RegExp(token, caseSensitive: false);
      sanitized = sanitized.replaceAll(pattern, '[redacted]');
    }
    assert(() {
      final lowered = sanitized.toLowerCase();
      for (final token in _forbiddenTokens) {
        if (lowered.contains(token)) {
          throw StateError('Sensitive log content detected');
        }
      }
      return true;
    }());
    return sanitized;
  }
}
