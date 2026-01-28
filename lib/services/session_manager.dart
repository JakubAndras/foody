import 'dart:async';
import 'package:diplomka/services/shared_preferences_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SessionManager extends GetxService {
  static SessionManager get to => Get.find();

  double lyricsFontSize = 16.0;
  final double lyricsFontSizeMin = 10.0;
  final double lyricsFontSizeMax = 36.0;

  Rx<ThemeMode> themeModeIndex = ThemeMode.dark.obs; // ThemeMode.system.obs;
  bool get isDarkMode {
    // if (themeModeIndex.value == ThemeMode.system) {
    //   return Get.mediaQuery.platformBrightness == Brightness.dark;
    // }
    return themeModeIndex.value == ThemeMode.dark;
  }

  final RxBool caloriesPlanEnabled = false.obs;

  Future<void> onAppInit() async {
    themeModeIndex.value = ThemeMode.values[await SharedPreferencesService.to.getInt(key: themeModeKey) ?? 0];
  }
}