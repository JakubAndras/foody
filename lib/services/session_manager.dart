import 'dart:async';
import 'package:diplomka/model/user_profile.dart';
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
  final RxBool onboardingComplete = false.obs;
  final RxBool scanOnboardingComplete = false.obs;
  final RxnDouble heightCm = RxnDouble();
  final RxnDouble weightKg = RxnDouble();
  final RxnDouble goalWeightKg = RxnDouble();
  final Rxn<ProfileSex> sex = Rxn<ProfileSex>();
  final Rxn<ProfileGoal> goal = Rxn<ProfileGoal>();
  final Rxn<ProfileDietType> dietType = Rxn<ProfileDietType>();
  final RxnString customDietPreferences = RxnString();
  final RxBool prefersMetric = true.obs;
  final Rxn<DateTime> dateOfBirth = Rxn<DateTime>();
  final RxnDouble weightChangeRateKgPerWeek = RxnDouble();
  final RxBool savePhotosToGallery = false.obs;

  Future<void> onAppInit() async {
    themeModeIndex.value = ThemeMode.values[await SharedPreferencesService.to.getInt(key: themeModeKey) ?? 0];
    onboardingComplete.value = await SharedPreferencesService.to.getBool(key: onboardingCompleteKey) ?? false;
    scanOnboardingComplete.value = await SharedPreferencesService.to.getBool(key: scanOnboardingCompleteKey) ?? false;
    heightCm.value = await SharedPreferencesService.to.getDouble(key: profileHeightCmKey);
    weightKg.value = await SharedPreferencesService.to.getDouble(key: profileWeightKgKey);
    goalWeightKg.value = await SharedPreferencesService.to.getDouble(key: profileGoalWeightKgKey);
    final sexCode = await SharedPreferencesService.to.getString(key: profileSexKey);
    sex.value = profileSexFromCode(sexCode);
    final goalCode = await SharedPreferencesService.to.getString(key: profileGoalKey);
    goal.value = profileGoalFromCode(goalCode);
    final dietTypeCode = await SharedPreferencesService.to.getString(key: profileDietTypeKey);
    dietType.value = profileDietTypeFromCode(dietTypeCode);
    customDietPreferences.value = await SharedPreferencesService.to.getString(key: profileCustomDietPreferencesKey);
    prefersMetric.value = await SharedPreferencesService.to.getBool(key: profilePrefersMetricKey) ?? true;
    final dobMillis = await SharedPreferencesService.to.getInt(key: profileDobKey);
    dateOfBirth.value = dobMillis == null ? null : DateTime.fromMillisecondsSinceEpoch(dobMillis);
    weightChangeRateKgPerWeek.value = await SharedPreferencesService.to.getDouble(key: profileWeightChangeRateKgPerWeekKey);
    savePhotosToGallery.value = await SharedPreferencesService.to.getBool(key: savePhotosToGalleryKey) ?? false;
  }

  Future<void> setOnboardingComplete(bool value) async {
    onboardingComplete.value = value;
    await SharedPreferencesService.to.setBool(key: onboardingCompleteKey, value: value);
  }

  Future<void> setScanOnboardingComplete(bool value) async {
    scanOnboardingComplete.value = value;
    await SharedPreferencesService.to.setBool(key: scanOnboardingCompleteKey, value: value);
  }

  Future<void> setHeightCm(double? value) async {
    heightCm.value = value;
    await SharedPreferencesService.to.setDouble(key: profileHeightCmKey, value: value);
  }

  Future<void> setWeightKg(double? value) async {
    weightKg.value = value;
    await SharedPreferencesService.to.setDouble(key: profileWeightKgKey, value: value);
  }

  Future<void> setGoalWeightKg(double? value) async {
    goalWeightKg.value = value;
    await SharedPreferencesService.to.setDouble(key: profileGoalWeightKgKey, value: value);
  }

  Future<void> setSex(ProfileSex? value) async {
    sex.value = value;
    await SharedPreferencesService.to.setString(
      key: profileSexKey,
      value: value?.code,
    );
  }

  Future<void> setGoal(ProfileGoal? value) async {
    goal.value = value;
    await SharedPreferencesService.to.setString(
      key: profileGoalKey,
      value: value?.code,
    );
  }

  Future<void> setDietType(ProfileDietType? value) async {
    dietType.value = value;
    await SharedPreferencesService.to.setString(
      key: profileDietTypeKey,
      value: value?.code,
    );
  }

  Future<void> setCustomDietPreferences(String? value) async {
    final normalized = value?.trim();
    customDietPreferences.value = normalized == null || normalized.isEmpty ? null : normalized;
    await SharedPreferencesService.to.setString(
      key: profileCustomDietPreferencesKey,
      value: customDietPreferences.value,
    );
  }

  Future<void> setPrefersMetric(bool value) async {
    prefersMetric.value = value;
    await SharedPreferencesService.to.setBool(
      key: profilePrefersMetricKey,
      value: value,
    );
  }

  Future<void> setDateOfBirth(DateTime? value) async {
    final normalized = value == null ? null : DateTime(value.year, value.month, value.day);
    dateOfBirth.value = normalized;
    await SharedPreferencesService.to.setInt(
      key: profileDobKey,
      value: normalized?.millisecondsSinceEpoch,
    );
  }

  Future<void> setWeightChangeRateKgPerWeek(double? value) async {
    weightChangeRateKgPerWeek.value = value;
    await SharedPreferencesService.to.setDouble(
      key: profileWeightChangeRateKgPerWeekKey,
      value: value,
    );
  }

  Future<void> setSavePhotosToGallery(bool value) async {
    savePhotosToGallery.value = value;
    await SharedPreferencesService.to.setBool(key: savePhotosToGalleryKey, value: value);
  }
}
