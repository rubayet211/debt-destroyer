import 'dart:developer' as developer;

class AppLogger {
  AppLogger._();

  static final instance = AppLogger._();

  void info(String message) {
    developer.log(message, name: 'debt_destroyer');
  }

  void error(String message, Object error, StackTrace stackTrace) {
    developer.log(
      message,
      name: 'debt_destroyer',
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }
}
