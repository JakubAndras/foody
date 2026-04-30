import 'dart:io';

import 'package:flutter/material.dart';
import 'package:diplomka/app_theme.dart';

class AppThemeData {
  ThemeData get themeData => _themeData;
  ThemeData get darkThemeData => _darkThemeData;

  final TextTheme _textTheme = TextTheme(
    displayLarge: AppTextStyles.displayXL,
    displayMedium: AppTextStyles.displayL,
    displaySmall: AppTextStyles.h1,
    headlineLarge: AppTextStyles.h2,
    headlineMedium: AppTextStyles.h3,
    headlineSmall: AppTextStyles.h4,
    titleLarge: AppTextStyles.title,
    titleMedium: AppTextStyles.body16.copyWith(fontWeight: FontWeight.w600),
    titleSmall: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w500, color: AppColors.textSecondary),
    bodyLarge: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w400, color: AppColors.textSecondary),
    bodyMedium: AppTextStyles.caption12.copyWith(fontWeight: FontWeight.w400, color: AppColors.textSecondary),
    bodySmall: AppTextStyles.label10.copyWith(fontWeight: FontWeight.w500, color: AppColors.textTertiary),
    labelLarge: AppTextStyles.body16.copyWith(fontWeight: FontWeight.w600),
    labelMedium: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w500),
    labelSmall: AppTextStyles.label9,
  );

  late final ThemeData _themeData = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    canvasColor: AppColors.surfaceMuted,
    cardColor: AppColors.surface,
    hintColor: AppColors.textTertiary,
    disabledColor: AppTheme.onLightColor,
    dividerColor: AppColors.outline,
    dividerTheme: DividerThemeData(color: AppColors.outline, thickness: 0.8),
    // dialogBackgroundColor: const Color(0xFF444444),
    floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary, shape: CircleBorder()),
    fontFamily: AppTheme.fontFamily,
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: Platform.isIOS,
      backgroundColor: AppColors.background,
      iconTheme: IconThemeData(color: AppColors.primary),
      titleTextStyle: AppTextStyles.body16.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
    ),
    buttonTheme: ButtonThemeData(height: AppSizes.buttonHeight, minWidth: AppSizes.minTap, buttonColor: AppColors.primary, textTheme: ButtonTextTheme.primary),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4), // Adjust the border radius here
        side: BorderSide(color: Colors.grey), // Set border color and width
      ),
    ),
    textTheme: _textTheme,
    cardTheme: CardThemeData(
      elevation: Platform.isIOS ? 0 : 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.l)),
    ),
    // Override Android's default ZoomPageTransitionsBuilder. The zoom
    // transition snapshots the outgoing page via SnapshotWidget, which
    // triggers markNeedsPaint inside RenderLiquidGlassLayer during the paint
    // phase — illegal in Flutter and shows up as a hard assertion in debug,
    // visual artefacts in release. The Cupertino slide transition does not
    // snapshot, so the issue disappears. iOS already uses Cupertino, so this
    // only changes Android visually. Drop this override once
    // liquid_glass_widgets ships a fix (current pinned version: 0.4.0-dev.4).
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.l))),
    ),
    bottomAppBarTheme: BottomAppBarThemeData(color: AppColors.surface),
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      surfaceTint: AppColors.surface,
      error: AppColors.error,
      onPrimary: AppColors.onPrimary,
      onSecondary: AppColors.onPrimary,
      onSurface: AppColors.textPrimary,
      outline: AppColors.outline,
    ).copyWith(surfaceContainerHighest: AppColors.surface, onSurfaceVariant: AppColors.textSecondary, outlineVariant: AppColors.outline),
  );

  late final ThemeData _darkThemeData = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFFFFFFFF),
    scaffoldBackgroundColor: const Color(0xFF000000),
    canvasColor: const Color(0xFF2C2C2E),
    cardColor: const Color(0xFF1C1C1E),
    hintColor: const Color(0xFF636366),
    disabledColor: const Color(0xFF1C1C1E),
    dividerColor: const Color(0xFF38383A),
    dividerTheme: const DividerThemeData(color: Color(0xFF38383A), thickness: 0.8),
    dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF2C2C2E)),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: Color(0xFFFFFFFF), foregroundColor: Color(0xFF0A0A0A), shape: CircleBorder()),
    fontFamily: AppTheme.fontFamily,
    appBarTheme: AppBarTheme(
      elevation: 0,
      shadowColor: Colors.black,
      centerTitle: Platform.isIOS,
      backgroundColor: const Color(0xFF000000),
      iconTheme: const IconThemeData(color: Color(0xFFFFFFFF)),
      titleTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFFFFFFFF), fontFamily: AppTheme.fontFamily),
    ),
    buttonTheme: const ButtonThemeData(height: AppSizes.buttonHeight, minWidth: AppSizes.minTap, buttonColor: Color(0xFFFFFFFF), textTheme: ButtonTextTheme.primary),
    textTheme: _textTheme.apply(bodyColor: const Color(0xFFFFFFFF), displayColor: const Color(0xFFFFFFFF)),
    cardTheme: CardThemeData(
      elevation: Platform.isIOS ? 0 : 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.l)),
    ),
    // Override Android's default ZoomPageTransitionsBuilder. The zoom
    // transition snapshots the outgoing page via SnapshotWidget, which
    // triggers markNeedsPaint inside RenderLiquidGlassLayer during the paint
    // phase — illegal in Flutter and shows up as a hard assertion in debug,
    // visual artefacts in release. The Cupertino slide transition does not
    // snapshot, so the issue disappears. iOS already uses Cupertino, so this
    // only changes Android visually. Drop this override once
    // liquid_glass_widgets ships a fix (current pinned version: 0.4.0-dev.4).
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xFF1C1C1E),
      surfaceTintColor: Color(0xFF1C1C1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.l))),
    ),
    bottomAppBarTheme: const BottomAppBarThemeData(color: Color(0xFF1C1C1E)),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFFFFFFF),
      secondary: Color(0xFF4F39F6),
      surface: Color(0xFF1C1C1E),
      surfaceTint: Color(0xFF1C1C1E),
      error: Color(0xFFDA0027),
      onPrimary: Color(0xFF0A0A0A),
      onSecondary: Color(0xFFFFFFFF),
      onSurface: Color(0xFFFFFFFF),
      outline: Color(0xFF38383A),
    ).copyWith(surfaceContainerHighest: const Color(0xFF2C2C2E), onSurfaceVariant: const Color(0xFF8E8E93), outlineVariant: const Color(0xFF38383A)),
  );
}
