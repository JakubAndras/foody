import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData themeData = ThemeData(
    scaffoldBackgroundColor: const Color(0xFFF7F7F7),
    fontFamily: 'SF Pro Display',
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF000000),
      secondary: Color(0xFF757575),
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF000000),
    ),
  );

  static const paddingL = 32.0;
  static const paddingM = 16.0;
  static const paddingS = 8.0;
  static const paddingXS = 4.0;

  static const inputRadius = 8.0;
  static const cardRadius = 4.0;

  static const bgColor = Color(0xFFEAEBED);
  static const surfaceColor = Color(0xFFF7F7F7);
  static const accentColor = Color(0xFF000000); // Color(0xFFDA0027);
  static const criticalColor = Color(0xFFFA236E);
  static const okColor = Color(0xFF83B528);
  static const catOneColor = Color(0xFFFFCC33);
  static const catTwoColor = Color(0xFF682ADD);
  static const catThreeColor = Color(0xFF32AE95);
  static Color greyColor = const Color(0x80FFFFFF).withOpacity(0.5);

  // Bg, Surface, Critical, Ok, CatOne, CatThree -> barvy "ON" jsou vždy stejné
  static const onColor = Color(0xFF010101);
  static const onSecondaryColor = Color(0xBF010101); //75%
  static const onDisabledColor = Color(0x80010101); //50%
  static const onLightColor = Color(0x26010101); //15%
  static const onExtraLightColor = Color(0x14010101); //8%

  // Accent a CatTwo -> barvy "ON" jsou vždy stejné
  static const onAccentColor = Color(0xFFFFFFFF);
  static const onAccentSecondaryColor = Color(0xBFFFFFFF); //75%
  static const onAccentDisabledColor = Color(0x80FFFFFF); //50%
  static const onAccentLightColor = Color(0x26FFFFFF); //15%
  static const onAccentExtraLightColor = Color(0x14FFFFFF); //8%

  static const transitionDuration = Duration(milliseconds: 200);
}

const MaterialColor primarySwatch = MaterialColor(
  0xFFDA0027,
  <int, Color>{
    50: Color(0xFFDA0027),
    100: Color(0xFFDA0027),
    200: Color(0xFFDA0027),
    300: Color(0xFFDA0027),
    400: Color(0xFFDA0027),
    500: Color(0xFFDA0027),
    600: Color(0xFFDA0027),
    700: Color(0xFFDA0027),
    800: Color(0xFFDA0027),
    900: Color(0xFFDA0027),
  },
);
