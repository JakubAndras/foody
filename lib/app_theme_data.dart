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
    dividerTheme: const DividerThemeData(color: AppColors.outline, thickness: 0.8),
    // dialogBackgroundColor: const Color(0xFF444444),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      shape: CircleBorder(),
    ),
    fontFamily: AppTheme.fontFamily,
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: Platform.isIOS,
      backgroundColor: AppColors.background,
      iconTheme: const IconThemeData(color: AppColors.primary),
      titleTextStyle: AppTextStyles.body16.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
    ),
    buttonTheme: const ButtonThemeData(
      height: AppSizes.buttonHeight,
      minWidth: AppSizes.minTap,
      buttonColor: AppColors.primary,
      textTheme: ButtonTextTheme.primary,
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4), // Adjust the border radius here
        side: BorderSide(color: Colors.grey), // Set border color and width
      ),
    ),
    textTheme: _textTheme,
    cardTheme: CardThemeData(
      elevation: Platform.isIOS ? 0 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
      ),
    ),
    bottomAppBarTheme: const BottomAppBarThemeData(color: AppColors.surface),
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      surfaceTint: AppColors.surface,
      error: AppColors.error,
      onPrimary: AppColors.onPrimary,
      onSecondary: AppColors.onPrimary,
      onSurface: AppColors.textPrimary,
      outline: AppColors.outline,
    ).copyWith(
      surfaceContainerHighest: AppColors.surface,
      onSurfaceVariant: AppColors.textSecondary,
      outlineVariant: AppColors.outline,
    ),
  );

  late final ThemeData _darkThemeData = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.black,
    scaffoldBackgroundColor: Colors.black,
    canvasColor: Colors.black,
    cardColor: const Color(0xFF1E1E1E),
    hintColor: AppTheme.onAccentDisabledColor,
    disabledColor: const Color(0xFF222222),
    dividerColor: const Color(0xFF444444),
    dividerTheme: const DividerThemeData(color: Color(0xFF444444), thickness: 0.8),
    dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF444444)),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppTheme.accentColor, // Using ColorScheme's secondary color
        foregroundColor: Colors.white,
        shape: CircleBorder()
    ),
    fontFamily: AppTheme.fontFamily,
    appBarTheme: AppBarTheme(
      elevation: 0,
      shadowColor: Colors.black,
      centerTitle: Platform.isIOS,
      backgroundColor: Colors.black,
      iconTheme: const IconThemeData(color: AppTheme.accentColor),
      titleTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white, fontFamily: AppTheme.fontFamily),
    ),
    buttonTheme: const ButtonThemeData(
      height: AppSizes.buttonHeight,
      minWidth: AppSizes.minTap,
      buttonColor: AppTheme.accentColor,
      textTheme: ButtonTextTheme.primary,
    ),
    textTheme: _textTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    cardTheme: CardThemeData(
      elevation: Platform.isIOS ? 0 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
    ),
    bottomAppBarTheme: const BottomAppBarThemeData(color: Color(0xFF191919)),
    colorScheme: const ColorScheme.dark(
      primary: Colors.white,
      secondary: AppTheme.accentColor,
      tertiary: Color(0xFF444444),
      onSecondary: AppTheme.onAccentSecondaryColor,
      onSurface: Color(0x66FFFFFF),
      surface: Color(0xFF191919),
      surfaceTint: Color(0xFF191919),
    ).copyWith(
      surfaceContainerHighest: Color(0xFF1E1E1E),
    ),
  );
}
