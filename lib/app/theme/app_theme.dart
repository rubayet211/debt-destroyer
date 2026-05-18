import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';

class AppTheme {
  static const primaryNavy = AppColors.primaryContainer;
  static const accentGreen = Color(0xFF2BB673);
  static const warningOrange = AppColors.warning;
  static const dangerRed = AppColors.error;
  static const softBackground = AppColors.background;
  static const darkSurface = AppColors.darkSurface;
  static const darkBackground = AppColors.darkBackground;
  static const cardDarkSurface = Color(0xFF162232);

  static ThemeData light() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.primaryFixedDim,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: Color(0xFF002110),
      tertiary: AppColors.tertiary,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: Color(0xFF19A09A),
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: Color(0xFF93000A),
      surface: AppColors.surfaceLowest,
      onSurface: AppColors.onSurface,
      surfaceContainerHighest: AppColors.surfaceHighest,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: Color(0xFF16334A),
      onInverseSurface: Color(0xFFE8F2FF),
      inversePrimary: AppColors.primaryFixedDim,
    );
    return _buildTheme(colorScheme, AppColors.background);
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryContainer,
      brightness: Brightness.dark,
      primary: AppColors.primaryFixedDim,
      secondary: AppColors.secondaryFixedDim,
      surface: cardDarkSurface,
      error: AppColors.errorContainer,
    );
    return _buildTheme(colorScheme, darkBackground);
  }

  static ThemeData _buildTheme(
    ColorScheme colorScheme,
    Color scaffoldBackgroundColor,
  ) {
    final base = GoogleFonts.manropeTextTheme();
    final textTheme = base.copyWith(
      displayLarge: GoogleFonts.manrope(
        fontSize: 48,
        height: 56 / 48,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.96,
        color: colorScheme.onSurface,
      ),
      headlineLarge: GoogleFonts.manrope(
        fontSize: 32,
        height: 40 / 32,
        fontWeight: FontWeight.w800,
        color: colorScheme.onSurface,
      ),
      headlineMedium: GoogleFonts.manrope(
        fontSize: 24,
        height: 32 / 24,
        fontWeight: FontWeight.w800,
        color: colorScheme.onSurface,
      ),
      headlineSmall: GoogleFonts.manrope(
        fontSize: 20,
        height: 28 / 20,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
      titleLarge: GoogleFonts.manrope(
        fontSize: 18,
        height: 26 / 18,
        fontWeight: FontWeight.w800,
        color: colorScheme.onSurface,
      ),
      titleMedium: GoogleFonts.manrope(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
      titleSmall: GoogleFonts.manrope(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
      bodyLarge: GoogleFonts.manrope(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      bodyMedium: GoogleFonts.manrope(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      bodySmall: GoogleFonts.manrope(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurfaceVariant,
      ),
      labelLarge: GoogleFonts.manrope(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
        color: colorScheme.onSurface,
      ),
      labelMedium: GoogleFonts.manrope(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: colorScheme.onSurfaceVariant,
      ),
    );

    final isLight = colorScheme.brightness == Brightness.light;
    final surfaceTint = isLight ? AppColors.primary : colorScheme.primary;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: isLight
            ? AppColors.surfaceLowest
            : scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(
            color: isLight
                ? AppColors.outlineVariant.withValues(alpha: 0.55)
                : colorScheme.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight ? AppColors.surfaceLowest : colorScheme.surface,
        labelStyle: textTheme.labelLarge?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
        prefixIconColor: colorScheme.onSurfaceVariant,
        suffixIconColor: colorScheme.onSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: surfaceTint, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(64, 52),
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: textTheme.labelLarge,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52),
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outlineVariant, width: 1.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          textStyle: textTheme.labelLarge,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        backgroundColor: colorScheme.surface,
        selectedColor: colorScheme.primary,
        secondarySelectedColor: colorScheme.primary,
        checkmarkColor: colorScheme.onPrimary,
        labelStyle: textTheme.labelMedium,
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(
          color: colorScheme.onPrimary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 76,
        backgroundColor: isLight
            ? AppColors.surfaceContainer
            : colorScheme.surface,
        indicatorColor: colorScheme.secondaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelMedium?.copyWith(
            color: selected
                ? colorScheme.onSecondaryContainer
                : colorScheme.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected
                ? colorScheme.onSecondaryContainer
                : colorScheme.onSurfaceVariant,
            size: 22,
          );
        }),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.secondary,
        linearTrackColor: isLight ? AppColors.surfaceHigh : colorScheme.surface,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        space: 1,
      ),
    );
  }
}
