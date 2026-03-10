import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../logging/app_logger.dart';
import 'app_services.dart';

class TelemetryConfig {
  const TelemetryConfig({
    required this.appEnvironment,
    required this.appFlavor,
    required this.analyticsEnabled,
    required this.crashReportingEnabled,
    required this.firebaseOptions,
  });

  factory TelemetryConfig.fromEnvironment() {
    const definedAppEnvironment = String.fromEnvironment(
      'APP_ENV',
      defaultValue: '',
    );
    const definedAppFlavor = String.fromEnvironment(
      'APP_FLAVOR',
      defaultValue: '',
    );
    const definedAnalyticsEnabled = String.fromEnvironment(
      'ENABLE_ANALYTICS',
      defaultValue: '',
    );
    const definedCrashReportingEnabled = String.fromEnvironment(
      'ENABLE_CRASH_REPORTING',
      defaultValue: '',
    );
    const definedApiKey = String.fromEnvironment(
      'FIREBASE_ANDROID_API_KEY',
      defaultValue: '',
    );
    const definedAppId = String.fromEnvironment(
      'FIREBASE_ANDROID_APP_ID',
      defaultValue: '',
    );
    const definedMessagingSenderId = String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
      defaultValue: '',
    );
    const definedProjectId = String.fromEnvironment(
      'FIREBASE_PROJECT_ID',
      defaultValue: '',
    );
    const definedStorageBucket = String.fromEnvironment(
      'FIREBASE_STORAGE_BUCKET',
      defaultValue: '',
    );

    return TelemetryConfig.fromValues(
      values: {
        'APP_ENV': definedAppEnvironment.isNotEmpty
            ? definedAppEnvironment
            : (dotenv.env['APP_ENV'] ?? dotenv.env['BACKEND_ENV'] ?? ''),
        'APP_FLAVOR': definedAppFlavor.isNotEmpty
            ? definedAppFlavor
            : (dotenv.env['APP_FLAVOR'] ?? ''),
        'ENABLE_ANALYTICS': definedAnalyticsEnabled.isNotEmpty
            ? definedAnalyticsEnabled
            : (dotenv.env['ENABLE_ANALYTICS'] ?? ''),
        'ENABLE_CRASH_REPORTING': definedCrashReportingEnabled.isNotEmpty
            ? definedCrashReportingEnabled
            : (dotenv.env['ENABLE_CRASH_REPORTING'] ?? ''),
        'FIREBASE_ANDROID_API_KEY': definedApiKey.isNotEmpty
            ? definedApiKey
            : (dotenv.env['FIREBASE_ANDROID_API_KEY'] ?? ''),
        'FIREBASE_ANDROID_APP_ID': definedAppId.isNotEmpty
            ? definedAppId
            : (dotenv.env['FIREBASE_ANDROID_APP_ID'] ?? ''),
        'FIREBASE_MESSAGING_SENDER_ID': definedMessagingSenderId.isNotEmpty
            ? definedMessagingSenderId
            : (dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? ''),
        'FIREBASE_PROJECT_ID': definedProjectId.isNotEmpty
            ? definedProjectId
            : (dotenv.env['FIREBASE_PROJECT_ID'] ?? ''),
        'FIREBASE_STORAGE_BUCKET': definedStorageBucket.isNotEmpty
            ? definedStorageBucket
            : (dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? ''),
      },
    );
  }

  @visibleForTesting
  factory TelemetryConfig.fromValues({required Map<String, String> values}) {
    final appEnvironment = values['APP_ENV']?.trim().isNotEmpty == true
        ? values['APP_ENV']!.trim()
        : 'development';
    final appFlavor = values['APP_FLAVOR']?.trim().isNotEmpty == true
        ? values['APP_FLAVOR']!.trim()
        : appEnvironment;
    final analyticsEnabled = _readBool(
      value: values['ENABLE_ANALYTICS'],
      fallback: appEnvironment == 'prod' || appEnvironment == 'production',
    );
    final crashReportingEnabled = _readBool(
      value: values['ENABLE_CRASH_REPORTING'],
      fallback: appEnvironment == 'prod' || appEnvironment == 'production',
    );
    final apiKey = values['FIREBASE_ANDROID_API_KEY']?.trim() ?? '';
    final appId = values['FIREBASE_ANDROID_APP_ID']?.trim() ?? '';
    final messagingSenderId =
        values['FIREBASE_MESSAGING_SENDER_ID']?.trim() ?? '';
    final projectId = values['FIREBASE_PROJECT_ID']?.trim() ?? '';
    final storageBucket = values['FIREBASE_STORAGE_BUCKET']?.trim() ?? '';

    final firebaseOptions =
        apiKey.isNotEmpty &&
            appId.isNotEmpty &&
            messagingSenderId.isNotEmpty &&
            projectId.isNotEmpty
        ? FirebaseOptions(
            apiKey: apiKey,
            appId: appId,
            messagingSenderId: messagingSenderId,
            projectId: projectId,
            storageBucket: storageBucket.isEmpty ? null : storageBucket,
          )
        : null;

    return TelemetryConfig(
      appEnvironment: appEnvironment,
      appFlavor: appFlavor,
      analyticsEnabled: analyticsEnabled,
      crashReportingEnabled: crashReportingEnabled,
      firebaseOptions: firebaseOptions,
    );
  }

  final String appEnvironment;
  final String appFlavor;
  final bool analyticsEnabled;
  final bool crashReportingEnabled;
  final FirebaseOptions? firebaseOptions;

  bool get isFirebaseConfigured => firebaseOptions != null;

  static bool _readBool({required String? value, required bool fallback}) {
    if (value == null || value.trim().isEmpty) {
      return fallback;
    }
    switch (value.trim().toLowerCase()) {
      case '1':
      case 'true':
      case 'yes':
      case 'on':
        return true;
      case '0':
      case 'false':
      case 'no':
      case 'off':
        return false;
      default:
        return fallback;
    }
  }
}

class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService(this._analytics);

  final FirebaseAnalytics _analytics;

  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const {},
  }) {
    final safeParameters = <String, Object>{};
    for (final entry in parameters.entries) {
      final value = entry.value;
      if (value is num || value is String) {
        safeParameters[entry.key] = value as Object;
      } else if (value is bool) {
        safeParameters[entry.key] = value ? 1 : 0;
      } else if (value != null) {
        safeParameters[entry.key] = value.toString();
      }
    }
    return _analytics.logEvent(name: name, parameters: safeParameters);
  }
}

class FirebaseCrashReporter implements CrashReporter {
  FirebaseCrashReporter(this._crashlytics);

  final FirebaseCrashlytics _crashlytics;

  @override
  Future<void> recordError(Object error, StackTrace stackTrace) {
    return _crashlytics.recordError(error, stackTrace, fatal: true);
  }
}

class TelemetryRuntime {
  TelemetryRuntime._();

  static final instance = TelemetryRuntime._();

  AnalyticsService _analyticsService = NoopAnalyticsService();
  CrashReporter _crashReporter = NoopCrashReporter();
  TelemetryConfig? _config;

  AnalyticsService get analyticsService => _analyticsService;
  CrashReporter get crashReporter => _crashReporter;
  TelemetryConfig? get config => _config;

  Future<void> initialize(TelemetryConfig config) async {
    _config = config;
    _analyticsService = NoopAnalyticsService();
    _crashReporter = NoopCrashReporter();

    if (!config.isFirebaseConfigured) {
      AppLogger.instance.info(
        'telemetry.disabled',
        context: {
          'category': 'telemetry',
          'environment': config.appEnvironment,
          'status': 'firebase_config_missing',
        },
      );
      return;
    }

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(options: config.firebaseOptions!);
      }
      final analytics = FirebaseAnalytics.instance;
      final crashlytics = FirebaseCrashlytics.instance;
      await analytics.setAnalyticsCollectionEnabled(config.analyticsEnabled);
      await crashlytics.setCrashlyticsCollectionEnabled(
        config.crashReportingEnabled,
      );
      _analyticsService = config.analyticsEnabled
          ? FirebaseAnalyticsService(analytics)
          : NoopAnalyticsService();
      _crashReporter = config.crashReportingEnabled
          ? FirebaseCrashReporter(crashlytics)
          : NoopCrashReporter();
      AppLogger.instance.info(
        'telemetry.initialized',
        context: {
          'category': 'telemetry',
          'environment': config.appEnvironment,
          'status': 'ready',
        },
      );
    } catch (error, stackTrace) {
      _analyticsService = NoopAnalyticsService();
      _crashReporter = NoopCrashReporter();
      AppLogger.instance.error(
        'telemetry.init_failed',
        error,
        stackTrace,
        context: {
          'category': 'telemetry',
          'environment': config.appEnvironment,
          'status': 'fallback_noop',
        },
      );
    }
  }

  @visibleForTesting
  void resetForTest() {
    _config = null;
    _analyticsService = NoopAnalyticsService();
    _crashReporter = NoopCrashReporter();
  }
}
