import 'package:debt_destroyer/core/services/app_services.dart';
import 'package:debt_destroyer/core/services/telemetry_services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() {
    TelemetryRuntime.instance.resetForTest();
  });

  test('telemetry config stays disabled when firebase values are missing', () {
    final config = TelemetryConfig.fromValues(
      values: {'APP_ENV': 'staging', 'APP_FLAVOR': 'staging'},
    );

    expect(config.appEnvironment, 'staging');
    expect(config.appFlavor, 'staging');
    expect(config.isFirebaseConfigured, isFalse);
    expect(config.analyticsEnabled, isFalse);
    expect(config.crashReportingEnabled, isFalse);
  });

  test('telemetry config enables firebase when required values exist', () {
    final config = TelemetryConfig.fromValues(
      values: {
        'APP_ENV': 'prod',
        'APP_FLAVOR': 'prod',
        'ENABLE_ANALYTICS': 'true',
        'ENABLE_CRASH_REPORTING': 'true',
        'FIREBASE_ANDROID_API_KEY': 'api-key',
        'FIREBASE_ANDROID_APP_ID': 'app-id',
        'FIREBASE_MESSAGING_SENDER_ID': 'sender-id',
        'FIREBASE_PROJECT_ID': 'project-id',
      },
    );

    expect(config.isFirebaseConfigured, isTrue);
    expect(config.analyticsEnabled, isTrue);
    expect(config.crashReportingEnabled, isTrue);
    expect(config.firebaseOptions?.projectId, 'project-id');
  });

  test(
    'runtime falls back to noop telemetry when firebase config is absent',
    () async {
      final config = TelemetryConfig.fromValues(
        values: {'APP_ENV': 'development'},
      );

      await TelemetryRuntime.instance.initialize(config);

      expect(
        TelemetryRuntime.instance.analyticsService,
        isA<NoopAnalyticsService>(),
      );
      expect(TelemetryRuntime.instance.crashReporter, isA<NoopCrashReporter>());
    },
  );
}
