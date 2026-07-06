import 'dart:async';
import 'package:diplomka/app_theme.dart';
import 'package:diplomka/model/user_profile.dart';
import 'package:diplomka/screens/logs/voice_log_screen.dart';
import 'package:diplomka/services/shared_preferences_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sentinel pro `copyWith`, aby šlo nullovatelná pole explicitně nastavit na `null`.
const Object _undefined = Object();

/// Immutable stav uživatelské session.
@immutable
class SessionState {
  const SessionState({
    this.themeMode = ThemeMode.system,
    this.caloriesPlanEnabled = false,
    this.onboardingComplete = false,
    this.scanOnboardingComplete = false,
    this.heightCm,
    this.weightKg,
    this.goalWeightKg,
    this.sex,
    this.goal,
    this.dietType,
    this.customDietPreferences,
    this.prefersMetric = true,
    this.dateOfBirth,
    this.weightChangeRateKgPerWeek,
    this.savePhotosToGallery = false,
    this.burnedCaloriesEnabled = true,
    this.rolloverCaloriesEnabled = true,
    this.autoAdjustMacrosEnabled = true,
    this.editableNutrientsEnabled1 = false,
    this.sectionHeaderPaddingEnabled = true,
    this.workoutsPerWeek,
    this.voiceLogMode = VoiceLogMode.meals,
    this.bmr,
  });

  final ThemeMode themeMode;
  final bool caloriesPlanEnabled;
  final bool onboardingComplete;
  final bool scanOnboardingComplete;
  final double? heightCm;
  final double? weightKg;
  final double? goalWeightKg;
  final ProfileSex? sex;
  final ProfileGoal? goal;
  final ProfileDietType? dietType;
  final String? customDietPreferences;
  final bool prefersMetric;
  final DateTime? dateOfBirth;
  final double? weightChangeRateKgPerWeek;
  final bool savePhotosToGallery;
  final bool burnedCaloriesEnabled;
  final bool rolloverCaloriesEnabled;
  final bool autoAdjustMacrosEnabled;
  final bool editableNutrientsEnabled1;
  final bool sectionHeaderPaddingEnabled;
  final String? workoutsPerWeek;
  final VoiceLogMode voiceLogMode;
  final double? bmr;

  bool get isDarkMode {
    if (themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return themeMode == ThemeMode.dark;
  }

  SessionState copyWith({
    ThemeMode? themeMode,
    bool? caloriesPlanEnabled,
    bool? onboardingComplete,
    bool? scanOnboardingComplete,
    Object? heightCm = _undefined,
    Object? weightKg = _undefined,
    Object? goalWeightKg = _undefined,
    Object? sex = _undefined,
    Object? goal = _undefined,
    Object? dietType = _undefined,
    Object? customDietPreferences = _undefined,
    bool? prefersMetric,
    Object? dateOfBirth = _undefined,
    Object? weightChangeRateKgPerWeek = _undefined,
    bool? savePhotosToGallery,
    bool? burnedCaloriesEnabled,
    bool? rolloverCaloriesEnabled,
    bool? autoAdjustMacrosEnabled,
    bool? editableNutrientsEnabled1,
    bool? sectionHeaderPaddingEnabled,
    Object? workoutsPerWeek = _undefined,
    VoiceLogMode? voiceLogMode,
    Object? bmr = _undefined,
  }) {
    return SessionState(
      themeMode: themeMode ?? this.themeMode,
      caloriesPlanEnabled: caloriesPlanEnabled ?? this.caloriesPlanEnabled,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      scanOnboardingComplete: scanOnboardingComplete ?? this.scanOnboardingComplete,
      heightCm: heightCm == _undefined ? this.heightCm : heightCm as double?,
      weightKg: weightKg == _undefined ? this.weightKg : weightKg as double?,
      goalWeightKg: goalWeightKg == _undefined ? this.goalWeightKg : goalWeightKg as double?,
      sex: sex == _undefined ? this.sex : sex as ProfileSex?,
      goal: goal == _undefined ? this.goal : goal as ProfileGoal?,
      dietType: dietType == _undefined ? this.dietType : dietType as ProfileDietType?,
      customDietPreferences: customDietPreferences == _undefined ? this.customDietPreferences : customDietPreferences as String?,
      prefersMetric: prefersMetric ?? this.prefersMetric,
      dateOfBirth: dateOfBirth == _undefined ? this.dateOfBirth : dateOfBirth as DateTime?,
      weightChangeRateKgPerWeek: weightChangeRateKgPerWeek == _undefined ? this.weightChangeRateKgPerWeek : weightChangeRateKgPerWeek as double?,
      savePhotosToGallery: savePhotosToGallery ?? this.savePhotosToGallery,
      burnedCaloriesEnabled: burnedCaloriesEnabled ?? this.burnedCaloriesEnabled,
      rolloverCaloriesEnabled: rolloverCaloriesEnabled ?? this.rolloverCaloriesEnabled,
      autoAdjustMacrosEnabled: autoAdjustMacrosEnabled ?? this.autoAdjustMacrosEnabled,
      editableNutrientsEnabled1: editableNutrientsEnabled1 ?? this.editableNutrientsEnabled1,
      sectionHeaderPaddingEnabled: sectionHeaderPaddingEnabled ?? this.sectionHeaderPaddingEnabled,
      workoutsPerWeek: workoutsPerWeek == _undefined ? this.workoutsPerWeek : workoutsPerWeek as String?,
      voiceLogMode: voiceLogMode ?? this.voiceLogMode,
      bmr: bmr == _undefined ? this.bmr : bmr as double?,
    );
  }
}

/// (`Get.changeThemeMode` / `Get.forceAppUpdate` odstraněno). Téma řídí `MaterialApp.themeMode`
/// čtením `sessionProvider`; `AppColors.updateDarkMode` se volá při každé změně tématu zde.
class SessionNotifier extends Notifier<SessionState> {
  // Nereaktivní pole (nejsou součástí stavu).
  double lyricsFontSize = 16.0;
  final double lyricsFontSizeMin = 10.0;
  final double lyricsFontSizeMax = 36.0;

  SharedPreferencesService get _prefs => ref.read(sharedPreferencesServiceProvider);

  @override
  SessionState build() => const SessionState();

  static double? _computeBmr({double? weightKg, double? heightCm, DateTime? dateOfBirth, ProfileSex? sex}) {
    if (weightKg == null || heightCm == null || dateOfBirth == null || sex == null) {
      return null;
    }
    final age = DateTime.now().difference(dateOfBirth).inDays ~/ 365;
    // ProfileSex.other averages the male (+5) and female (-161) constants.
    final double sexConstant = switch (sex) {
      ProfileSex.male => 5,
      ProfileSex.female => -161,
      ProfileSex.other => -78,
    };
    return 10 * weightKg + 6.25 * heightCm - 5 * age + sexConstant;
  }

  void _recalculateBmr() {
    state = state.copyWith(
      bmr: _computeBmr(
        weightKg: state.weightKg,
        heightCm: state.heightCm,
        dateOfBirth: state.dateOfBirth,
        sex: state.sex,
      ),
    );
  }

  Future<void> onAppInit() async {
    final prefs = _prefs;
    final themeMode = ThemeMode.values[await prefs.getInt(key: themeModeKey) ?? 0];
    final onboardingComplete = await prefs.getBool(key: onboardingCompleteKey) ?? false;
    final scanOnboardingComplete = await prefs.getBool(key: scanOnboardingCompleteKey) ?? false;
    final heightCm = await prefs.getDouble(key: profileHeightCmKey);
    final weightKg = await prefs.getDouble(key: profileWeightKgKey);
    final goalWeightKg = await prefs.getDouble(key: profileGoalWeightKgKey);
    final sex = profileSexFromCode(await prefs.getString(key: profileSexKey));
    final goal = profileGoalFromCode(await prefs.getString(key: profileGoalKey));
    final dietType = profileDietTypeFromCode(await prefs.getString(key: profileDietTypeKey));
    final customDietPreferences = await prefs.getString(key: profileCustomDietPreferencesKey);
    final prefersMetric = await prefs.getBool(key: profilePrefersMetricKey) ?? true;
    final dobMillis = await prefs.getInt(key: profileDobKey);
    final dateOfBirth = dobMillis == null ? null : DateTime.fromMillisecondsSinceEpoch(dobMillis);
    final weightChangeRateKgPerWeek = await prefs.getDouble(key: profileWeightChangeRateKgPerWeekKey);
    final savePhotosToGallery = await prefs.getBool(key: savePhotosToGalleryKey) ?? false;
    final burnedCaloriesEnabled = await prefs.getBool(key: burnedCaloriesEnabledKey) ?? true;
    final rolloverCaloriesEnabled = await prefs.getBool(key: rolloverCaloriesEnabledKey) ?? true;
    final autoAdjustMacrosEnabled = await prefs.getBool(key: autoAdjustMacrosEnabledKey) ?? true;
    final workoutsPerWeek = await prefs.getString(key: profileWorkoutsPerWeekKey);
    final voiceLogModeCode = await prefs.getString(key: voiceLogModeKey);
    final voiceLogMode = voiceLogModeCode == 'exercise' ? VoiceLogMode.exercise : VoiceLogMode.meals;

    state = state.copyWith(
      themeMode: themeMode,
      onboardingComplete: onboardingComplete,
      scanOnboardingComplete: scanOnboardingComplete,
      heightCm: heightCm,
      weightKg: weightKg,
      goalWeightKg: goalWeightKg,
      sex: sex,
      goal: goal,
      dietType: dietType,
      customDietPreferences: customDietPreferences,
      prefersMetric: prefersMetric,
      dateOfBirth: dateOfBirth,
      weightChangeRateKgPerWeek: weightChangeRateKgPerWeek,
      savePhotosToGallery: savePhotosToGallery,
      burnedCaloriesEnabled: burnedCaloriesEnabled,
      rolloverCaloriesEnabled: rolloverCaloriesEnabled,
      autoAdjustMacrosEnabled: autoAdjustMacrosEnabled,
      workoutsPerWeek: workoutsPerWeek,
      voiceLogMode: voiceLogMode,
      bmr: _computeBmr(weightKg: weightKg, heightCm: heightCm, dateOfBirth: dateOfBirth, sex: sex),
    );
    AppColors.updateDarkMode(state.isDarkMode);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    AppColors.updateDarkMode(state.isDarkMode);
    await _prefs.setInt(key: themeModeKey, value: mode.index);
  }

  Future<void> setOnboardingComplete(bool value) async {
    state = state.copyWith(onboardingComplete: value);
    await _prefs.setBool(key: onboardingCompleteKey, value: value);
  }

  Future<void> setScanOnboardingComplete(bool value) async {
    state = state.copyWith(scanOnboardingComplete: value);
    await _prefs.setBool(key: scanOnboardingCompleteKey, value: value);
  }

  Future<void> setHeightCm(double? value) async {
    state = state.copyWith(heightCm: value);
    await _prefs.setDouble(key: profileHeightCmKey, value: value);
    _recalculateBmr();
  }

  Future<void> setWeightKg(double? value) async {
    state = state.copyWith(weightKg: value);
    await _prefs.setDouble(key: profileWeightKgKey, value: value);
    _recalculateBmr();
  }

  Future<void> setGoalWeightKg(double? value) async {
    state = state.copyWith(goalWeightKg: value);
    await _prefs.setDouble(key: profileGoalWeightKgKey, value: value);
  }

  Future<void> setSex(ProfileSex? value) async {
    state = state.copyWith(sex: value);
    await _prefs.setString(key: profileSexKey, value: value?.code);
    _recalculateBmr();
  }

  Future<void> setGoal(ProfileGoal? value) async {
    state = state.copyWith(goal: value);
    await _prefs.setString(key: profileGoalKey, value: value?.code);
  }

  Future<void> setDietType(ProfileDietType? value) async {
    state = state.copyWith(dietType: value);
    await _prefs.setString(key: profileDietTypeKey, value: value?.code);
  }

  Future<void> setCustomDietPreferences(String? value) async {
    final normalized = value?.trim();
    final resolved = normalized == null || normalized.isEmpty ? null : normalized;
    state = state.copyWith(customDietPreferences: resolved);
    await _prefs.setString(key: profileCustomDietPreferencesKey, value: resolved);
  }

  Future<void> setPrefersMetric(bool value) async {
    state = state.copyWith(prefersMetric: value);
    await _prefs.setBool(key: profilePrefersMetricKey, value: value);
  }

  Future<void> setDateOfBirth(DateTime? value) async {
    final normalized = value == null ? null : DateTime(value.year, value.month, value.day);
    state = state.copyWith(dateOfBirth: normalized);
    await _prefs.setInt(key: profileDobKey, value: normalized?.millisecondsSinceEpoch);
    _recalculateBmr();
  }

  Future<void> setWeightChangeRateKgPerWeek(double? value) async {
    state = state.copyWith(weightChangeRateKgPerWeek: value);
    await _prefs.setDouble(key: profileWeightChangeRateKgPerWeekKey, value: value);
  }

  Future<void> applyRecommendedWeightChangeRate() async {
    final isGain = state.goal == ProfileGoal.gain;
    final w = state.weightKg;
    if (w == null) {
      await setWeightChangeRateKgPerWeek(isGain ? 0.4 : 0.8);
      return;
    }
    final double maxSpeed = isGain ? 1.0 : ((w * 0.012 * 10).round() / 10).clamp(0.5, 1.5);
    final double factor = isGain ? 0.005 : 0.0075;
    final double recommended = ((w * factor * 10).round() / 10).clamp(0.1, maxSpeed);
    await setWeightChangeRateKgPerWeek(recommended);
  }

  Future<void> setSavePhotosToGallery(bool value) async {
    state = state.copyWith(savePhotosToGallery: value);
    await _prefs.setBool(key: savePhotosToGalleryKey, value: value);
  }

  Future<void> setBurnedCaloriesEnabled(bool value) async {
    state = state.copyWith(burnedCaloriesEnabled: value);
    await _prefs.setBool(key: burnedCaloriesEnabledKey, value: value);
  }

  Future<void> setRolloverCaloriesEnabled(bool value) async {
    state = state.copyWith(rolloverCaloriesEnabled: value);
    await _prefs.setBool(key: rolloverCaloriesEnabledKey, value: value);
  }

  Future<void> setAutoAdjustMacrosEnabled(bool value) async {
    state = state.copyWith(autoAdjustMacrosEnabled: value);
    await _prefs.setBool(key: autoAdjustMacrosEnabledKey, value: value);
  }

  Future<void> setWorkoutsPerWeek(String? value) async {
    state = state.copyWith(workoutsPerWeek: value);
    await _prefs.setString(key: profileWorkoutsPerWeekKey, value: value);
  }

  void setSectionHeaderPaddingEnabled(bool value) {
    state = state.copyWith(sectionHeaderPaddingEnabled: value);
  }

  Future<void> setVoiceLogMode(VoiceLogMode mode) async {
    state = state.copyWith(voiceLogMode: mode);
    await _prefs.setString(
      key: voiceLogModeKey,
      value: mode == VoiceLogMode.exercise ? 'exercise' : 'meals',
    );
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, SessionState>(SessionNotifier.new);
