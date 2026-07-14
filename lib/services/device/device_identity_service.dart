import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diplomka/di/providers.dart';

/// Klíč v SharedPreferences, pod kterým je uloženo stabilní ID instalace.
const String deviceIdKey = 'device_id';

/// Poskytuje stabilní identifikátor instalace, který se posílá backendu
/// v hlavičce `X-Device-Id`. ID se generuje jednou při první potřebě
/// (v4 UUID přes [Random.secure]), uloží se do SharedPreferences a při dalších
/// spuštěních se čte z persistence, takže je pro danou instalaci neměnné.
///
/// Prefs se předávají v konstruktoru (musí být již načtené), takže přístup
/// přes [deviceId] je synchronní.
class DeviceIdentityService {
  DeviceIdentityService(this._prefs);

  final SharedPreferences _prefs;

  String? _cachedDeviceId;

  /// Stabilní ID instalace. Při prvním čtení případně vygeneruje a uloží nové.
  String get deviceId => _cachedDeviceId ??= _readOrCreateDeviceId();

  String _readOrCreateDeviceId() {
    final existing = _prefs.getString(deviceIdKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final generated = _generateUuidV4();
    // Persist je fire-and-forget; in-memory cache SharedPreferences se aktualizuje
    // synchronně, takže následné čtení vrátí stejnou hodnotu i před dokončením zápisu.
    _prefs.setString(deviceIdKey, generated);
    return generated;
  }

  /// Vygeneruje náhodné v4 UUID (RFC 4122) pomocí kryptograficky bezpečného generátoru.
  static String _generateUuidV4() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));

    // Verze 4 (horní čtyři bity 7. bajtu = 0100).
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    // Varianta RFC 4122 (horní dva bity 9. bajtu = 10).
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}

/// Co-located provider. Závisí na [sharedPreferencesProvider], který se
/// injektuje přes override v `main()` (stejně jako `databaseProvider`).
final deviceIdentityServiceProvider = Provider<DeviceIdentityService>(
  (ref) => DeviceIdentityService(ref.watch(sharedPreferencesProvider)),
);
