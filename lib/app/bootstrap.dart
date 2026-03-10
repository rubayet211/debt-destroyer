import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import '../core/logging/app_logger.dart';
import '../core/services/telemetry_services.dart';
import '../shared/providers/app_providers.dart';
import 'app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    AppLogger.instance.info(
      'dotenv.missing',
      context: const {'category': 'bootstrap', 'status': 'local_defaults'},
    );
  }

  final cameras = await _loadAvailableCameras();
  final telemetryConfig = TelemetryConfig.fromEnvironment();
  await TelemetryRuntime.instance.initialize(telemetryConfig);

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    AppLogger.instance.error(
      'flutter.framework_error',
      details.exception,
      details.stack ?? StackTrace.current,
      context: const {'category': 'telemetry', 'status': 'captured'},
    );
    unawaited(
      TelemetryRuntime.instance.crashReporter.recordError(
        details.exception,
        details.stack ?? StackTrace.current,
      ),
    );
  };
  WidgetsBinding.instance.platformDispatcher.onError = (error, stackTrace) {
    AppLogger.instance.error(
      'flutter.platform_error',
      error,
      stackTrace,
      context: const {'category': 'telemetry', 'status': 'captured'},
    );
    unawaited(
      TelemetryRuntime.instance.crashReporter.recordError(error, stackTrace),
    );
    return true;
  };

  runZonedGuarded(
    () {
      runApp(
        ProviderScope(
          overrides: [availableCamerasProvider.overrideWithValue(cameras)],
          child: const DebtDestroyerApp(),
        ),
      );
    },
    (error, stackTrace) {
      AppLogger.instance.error(
        'flutter.uncaught_zone_error',
        error,
        stackTrace,
        context: const {'category': 'telemetry', 'status': 'captured'},
      );
      unawaited(
        TelemetryRuntime.instance.crashReporter.recordError(error, stackTrace),
      );
    },
  );
}

Future<List<CameraDescription>> _loadAvailableCameras() async {
  try {
    return await availableCameras();
  } catch (error, stackTrace) {
    AppLogger.instance.error(
      'camera.discovery_failed',
      error,
      stackTrace,
      context: const {'category': 'bootstrap', 'operation': 'cameraDiscovery'},
    );
    return const [];
  }
}
