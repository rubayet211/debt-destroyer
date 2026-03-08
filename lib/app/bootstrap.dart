import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import '../core/logging/app_logger.dart';
import '../shared/providers/app_providers.dart';
import 'app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    AppLogger.instance.info('No .env file found, using local-only defaults.');
  }

  final cameras = await _loadAvailableCameras();

  runApp(
    ProviderScope(
      overrides: [availableCamerasProvider.overrideWithValue(cameras)],
      child: const DebtDestroyerApp(),
    ),
  );
}

Future<List<CameraDescription>> _loadAvailableCameras() async {
  try {
    return await availableCameras();
  } catch (error, stackTrace) {
    AppLogger.instance.error('Camera discovery failed', error, stackTrace);
    return const [];
  }
}
