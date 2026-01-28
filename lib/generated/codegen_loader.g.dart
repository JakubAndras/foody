// DO NOT EDIT. This is code generated via package:easy_localization/generate.dart

// ignore_for_file: prefer_single_quotes, avoid_renaming_method_parameters, constant_identifier_names

import 'dart:ui';

import 'package:easy_localization/easy_localization.dart' show AssetLoader;

class CodegenLoader extends AssetLoader{
  const CodegenLoader();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) {
    return Future.value(mapLocales[locale.toString()]);
  }

  static const Map<String,dynamic> _tr = {
  "app_name": null,
  "day_monday_short": null,
  "day_tuesday_short": null,
  "day_wednesday_short": null,
  "day_thursday_short": null,
  "day_friday_short": null,
  "day_saturday_short": null,
  "day_sunday_short": null
};
static const Map<String,dynamic> _en = {
  "app_name": "Foody",
  "day_monday_short": "M",
  "day_tuesday_short": "T",
  "day_wednesday_short": "W",
  "day_thursday_short": "T",
  "day_friday_short": "F",
  "day_saturday_short": "S",
  "day_sunday_short": "S"
};
static const Map<String,dynamic> _cs = {
  "app_name": "Foody",
  "day_monday_short": "Po",
  "day_tuesday_short": "Út",
  "day_wednesday_short": "St",
  "day_thursday_short": "Čt",
  "day_friday_short": "Pá",
  "day_saturday_short": "So",
  "day_sunday_short": "Ne"
};
static const Map<String, Map<String,dynamic>> mapLocales = {"tr": _tr, "en": _en, "cs": _cs};
}
