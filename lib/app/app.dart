import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shared/enums/app_enums.dart';
import '../shared/providers/app_providers.dart';
import 'theme/app_theme.dart';

class DebtDestroyerApp extends ConsumerWidget {
  const DebtDestroyerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(userPreferencesProvider).valueOrNull;
    final themeMode = preferences?.themeMode.toThemeMode() ?? ThemeMode.system;
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'DEBT DESTROYER',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      themeMode: themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
    );
  }
}
