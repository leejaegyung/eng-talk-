import 'package:flutter/material.dart';

/// Visual style after the "Speak Up" English-learning UI kit (Figma
/// community): royal blue primary, orange/yellow accents, white rounded
/// cards on a light grey-blue background.
abstract final class AppColors {
  static const blue = Color(0xFF2563EB);
  static const blueSoft = Color(0xFFE4ECFF);
  static const orange = Color(0xFFFE9518);
  static const orangeSoft = Color(0xFFFFF1DF);
  static const yellow = Color(0xFFFECC17);
  static const yellowSoft = Color(0xFFFFF7D6);
  static const green = Color(0xFF22A06B);
  static const greenSoft = Color(0xFFE3F6EC);
  static const ink = Color(0xFF263039);
  static const inkMuted = Color(0xFF7B8794);
  static const line = Color(0xFFE4E9F2);
  static const canvas = Color(0xFFF5F7FB);
}

/// Card / field radius used across the app.
const kRadius = 16.0;

ThemeData buildLightTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.blue,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppColors.blue,
        onPrimary: Colors.white,
        primaryContainer: AppColors.blueSoft,
        onPrimaryContainer: const Color(0xFF1E3A8A),
        secondary: AppColors.orange,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.orangeSoft,
        onSecondaryContainer: const Color(0xFF7A3E00),
        tertiary: const Color(0xFFB98A00),
        onTertiary: Colors.white,
        tertiaryContainer: AppColors.yellowSoft,
        onTertiaryContainer: const Color(0xFF5C4400),
        surface: Colors.white,
        onSurface: AppColors.ink,
        onSurfaceVariant: AppColors.inkMuted,
        surfaceContainerLowest: Colors.white,
        surfaceContainerLow: AppColors.canvas,
        surfaceContainer: const Color(0xFFF0F3F9),
        surfaceContainerHigh: const Color(0xFFEDF1F7),
        surfaceContainerHighest: const Color(0xFFE6EBF3),
        outline: const Color(0xFFA3ADBA),
        outlineVariant: AppColors.line,
      );
  return _build(scheme, AppColors.canvas);
}

ThemeData buildDarkTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.blue,
        brightness: Brightness.dark,
      ).copyWith(
        primary: const Color(0xFF6D9BF5),
        onPrimary: const Color(0xFF0B1B44),
        primaryContainer: const Color(0xFF1D3577),
        onPrimaryContainer: const Color(0xFFDCE6FF),
        secondary: const Color(0xFFFFB25C),
        onSecondary: const Color(0xFF3D1F00),
        secondaryContainer: const Color(0xFF4A2A06),
        onSecondaryContainer: const Color(0xFFFFDDB8),
        tertiary: AppColors.yellow,
        onTertiary: const Color(0xFF3A2C00),
        tertiaryContainer: const Color(0xFF453500),
        onTertiaryContainer: const Color(0xFFFFE9A3),
        surface: const Color(0xFF171E2B),
        onSurface: const Color(0xFFE6EAF1),
        onSurfaceVariant: const Color(0xFFA3ADBA),
        surfaceContainerLowest: const Color(0xFF0E131C),
        surfaceContainerLow: const Color(0xFF121824),
        surfaceContainer: const Color(0xFF1C2433),
        surfaceContainerHigh: const Color(0xFF232C3D),
        surfaceContainerHighest: const Color(0xFF2B3548),
        outline: const Color(0xFF6B7687),
        outlineVariant: const Color(0xFF2B3548),
      );
  return _build(scheme, const Color(0xFF0E131C));
}

ThemeData _build(ColorScheme c, Color background) {
  final base = ThemeData(
    colorScheme: c,
    useMaterial3: true,
    brightness: c.brightness,
  );
  final text = base.textTheme.apply(
    bodyColor: c.onSurface,
    displayColor: c.onSurface,
  );
  final rounded = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  );
  const buttonPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 14);
  final buttonText = text.labelLarge?.copyWith(fontWeight: FontWeight.w600);

  return base.copyWith(
    scaffoldBackgroundColor: background,
    textTheme: text.copyWith(
      headlineSmall: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      foregroundColor: c.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: text.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 20,
      ),
    ),
    cardTheme: CardThemeData(
      color: c.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadius),
        side: BorderSide(color: c.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: rounded,
        padding: buttonPadding,
        textStyle: buttonText,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: rounded,
        padding: buttonPadding,
        textStyle: buttonText,
        foregroundColor: c.primary,
        side: BorderSide(color: c.primary),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(shape: rounded, textStyle: buttonText),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: rounded,
        padding: buttonPadding,
        textStyle: buttonText,
        elevation: 0,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c.primary, width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c.outlineVariant.withValues(alpha: .5)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: c.surface,
      selectedColor: c.primaryContainer,
      side: BorderSide(color: c.outlineVariant),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      labelStyle: text.labelLarge,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: c.primary,
        selectedForegroundColor: c.onPrimary,
        side: BorderSide(color: c.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: c.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    expansionTileTheme: ExpansionTileThemeData(
      shape: const RoundedRectangleBorder(side: BorderSide.none),
      collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
      iconColor: c.primary,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: c.secondary,
      linearTrackColor: c.secondaryContainer,
      circularTrackColor: c.primaryContainer,
    ),
    dividerTheme: DividerThemeData(color: c.outlineVariant, space: 1),
    switchTheme: SwitchThemeData(
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}
