import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diplomka/model/tracking_reminder_setting.dart';

const String themeModeKey = "themeModeKey";
const String onboardingCompleteKey = "onboardingCompleteKey";
const String scanOnboardingCompleteKey = "scanOnboardingCompleteKey";
const String profileHeightCmKey = "profileHeightCmKey";
const String profileWeightKgKey = "profileWeightKgKey";
const String profileGoalWeightKgKey = "profileGoalWeightKgKey";
const String profileSexKey = "profileSexKey";
const String profileDobKey = "profileDobKey";
const String profileGoalKey = "profileGoalKey";
const String profilePrefersMetricKey = "profilePrefersMetricKey";
const String profileWeightChangeRateKgPerWeekKey = "profileWeightChangeRateKgPerWeekKey";

class SharedPreferencesService extends GetxService {
  static SharedPreferencesService get to => Get.find();

  SharedPreferences? _prefsInstance;

  Future<SharedPreferences> get getPrefsInstance async {
    return _prefsInstance ??= await SharedPreferences.getInstance();
  }

  Future<bool> setBool({bool? value, required String key}) async {
    if (value == null) {
      return remove(key);
    }
    return getPrefsInstance.then((SharedPreferences prefs) => prefs.setBool(key, value));
  }

  Future<bool> setDouble({double? value, required String key}) async {
    if (value == null) {
      return remove(key);
    }
    return getPrefsInstance.then((SharedPreferences prefs) => prefs.setDouble(key, value));
  }

  Future<bool> setInt({int? value, required String key}) async {
    if (value == null) {
      return remove(key);
    }
    return getPrefsInstance.then((SharedPreferences prefs) => prefs.setInt(key, value));
  }

  Future<bool> setString({String? value, required String key}) async {
    if (value == null) {
      return remove(key);
    }
    return getPrefsInstance.then((SharedPreferences prefs) => prefs.setString(key, value));
  }

  Future<bool> remove(String key) async {
    return getPrefsInstance.then((SharedPreferences prefs) => prefs.remove(key));
  }

  Future<bool> containsKey(String key) async {
    return getPrefsInstance.then((SharedPreferences prefs) => prefs.containsKey(key));
  }

  Future<String?> getString({required String key}) async {
    return getPrefsInstance.then((prefs) => prefs.getString(key));
  }

  Future<bool?> getBool({required String key}) async {
    return getPrefsInstance.then((prefs) => prefs.getBool(key));
  }

  Future<double?> getDouble({required String key}) async {
    return getPrefsInstance.then((prefs) => prefs.getDouble(key));
  }

  Future<int?> getInt({required String key}) async {
    return getPrefsInstance.then((prefs) => prefs.getInt(key));
  }

  String trackingReminderEnabledKey(TrackingReminderType type) => 'trackingReminder_${type.code}_enabled';

  String trackingReminderHourKey(TrackingReminderType type) => 'trackingReminder_${type.code}_hour';

  String trackingReminderMinuteKey(TrackingReminderType type) => 'trackingReminder_${type.code}_minute';

  Future<TrackingReminderSetting> getTrackingReminderSetting(TrackingReminderType type) async {
    final defaultSetting = TrackingReminderSetting.defaults(type);
    final enabled = await getBool(key: trackingReminderEnabledKey(type)) ?? defaultSetting.enabled;
    final hour = await getInt(key: trackingReminderHourKey(type)) ?? defaultSetting.hour;
    final minute = await getInt(key: trackingReminderMinuteKey(type)) ?? defaultSetting.minute;

    return TrackingReminderSetting(
      type: type,
      enabled: enabled,
      hour: hour.clamp(0, 23),
      minute: minute.clamp(0, 59),
    );
  }

  Future<void> setTrackingReminderSetting(TrackingReminderSetting setting) async {
    await setBool(key: trackingReminderEnabledKey(setting.type), value: setting.enabled);
    await setInt(key: trackingReminderHourKey(setting.type), value: setting.hour);
    await setInt(key: trackingReminderMinuteKey(setting.type), value: setting.minute);
  }
}
