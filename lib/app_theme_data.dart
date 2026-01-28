import 'dart:io';

import 'package:flutter/material.dart';
import 'package:diplomka/app_theme.dart';

class AppThemeData {
  ThemeData get themeData => _themeData;
  ThemeData get darkThemeData => _darkThemeData;

  final ThemeData _themeData = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.white,
    scaffoldBackgroundColor: AppTheme.surfaceColor,
    canvasColor: AppTheme.bgColor,
    cardColor: Colors.white,
    hintColor: AppTheme.onDisabledColor,
    disabledColor: const Color(0x14010101),
    dividerColor: AppTheme.onLightColor,
    dividerTheme: const DividerThemeData(color: AppTheme.onLightColor, thickness: 0.8),
    // dialogBackgroundColor: const Color(0xFF444444),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppTheme.accentColor, // Using ColorScheme's secondary color
        foregroundColor: Colors.white,
        shape: CircleBorder()
    ),
    fontFamily: 'Ubuntu',
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: Platform.isIOS,
      color: AppTheme.surfaceColor,
      iconTheme: const IconThemeData(color: AppTheme.accentColor),
      titleTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black, fontFamily: 'Ubuntu'),
    ),
    buttonTheme: const ButtonThemeData(
      height: 56,
      minWidth: 48,
      buttonColor: AppTheme.accentColor,
      textTheme: ButtonTextTheme.primary,
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4), // Adjust the border radius here
        side: BorderSide(color: Colors.grey), // Set border color and width
      ),
    ),
    textTheme: const TextTheme(
      bodySmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
      labelSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF777777)),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black),
      displayLarge: TextStyle(fontSize: 30, fontWeight: FontWeight.w500, color: Colors.black),
      displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.black),
      displaySmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black),
      headlineMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
      headlineSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
      titleLarge: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black),
      labelLarge: TextStyle(fontSize: 16.0),
    ),
    cardTheme: CardThemeData(
      elevation: Platform.isIOS ? 0 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
    ),
    bottomAppBarTheme: const BottomAppBarThemeData(color: AppTheme.surfaceColor),
    colorScheme: const ColorScheme.light(
      primary: Colors.black,
      secondary: AppTheme.accentColor,
      onSecondary: AppTheme.onSecondaryColor,
      onBackground: AppTheme.onLightColor,
      onSurface: Color(0x44000000),
      surfaceTint: Colors.white,
      surface: Colors.white,
    ).copyWith(
      background: AppTheme.surfaceColor,
    ),
  );

  final ThemeData _darkThemeData = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.black,
    scaffoldBackgroundColor: Colors.black,
    canvasColor: Colors.black,
    cardColor: const Color(0xFF1E1E1E),
    hintColor: AppTheme.onAccentDisabledColor,
    disabledColor: const Color(0xFF222222),
    dividerColor: const Color(0xFF444444),
    dividerTheme: const DividerThemeData(color: Color(0xFF444444), thickness: 0.8),
    dialogBackgroundColor: const Color(0xFF444444),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppTheme.accentColor, // Using ColorScheme's secondary color
        foregroundColor: Colors.white,
        shape: CircleBorder()
    ),
    fontFamily: 'Ubuntu',
    appBarTheme: AppBarTheme(
      elevation: 0,
      shadowColor: Colors.black,
      centerTitle: Platform.isIOS,
      color: Colors.black,
      iconTheme: const IconThemeData(color: AppTheme.accentColor),
      titleTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white, fontFamily: 'Ubuntu'),
    ),
    buttonTheme: const ButtonThemeData(
      height: 56,
      minWidth: 48,
      buttonColor: AppTheme.accentColor,
      textTheme: ButtonTextTheme.primary,
    ),
    textTheme: const TextTheme(
      bodySmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
      labelSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFFAAAAAA)),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white),
      displayLarge: TextStyle(fontSize: 30, fontWeight: FontWeight.w500, color: Colors.white),
      displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.white),
      displaySmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
      headlineMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
      headlineSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
      titleLarge: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
      labelLarge: TextStyle(fontSize: 16.0),
    ),
    cardTheme: CardThemeData(
      elevation: Platform.isIOS ? 0 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
    ),
    bottomAppBarTheme: const BottomAppBarThemeData(color: Color(0xFF191919)),
    colorScheme: const ColorScheme.dark(
      primary: Colors.white,
      secondary: AppTheme.accentColor,
      tertiary: Color(0xFF444444),
      onSecondary: AppTheme.onAccentSecondaryColor,
      onBackground: AppTheme.onAccentLightColor,
      onSurface: Color(0x66FFFFFF),
      surface: Color(0xFF191919),
      surfaceTint: Color(0xFF191919),
      background: Colors.black,

    ).copyWith(
      background: Colors.black,
    ),
  );
}
