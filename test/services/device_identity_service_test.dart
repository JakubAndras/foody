import 'package:diplomka/services/device/device_identity_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final RegExp uuidV4Pattern = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  );

  group('DeviceIdentityService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('vrátí neprázdné ID ve tvaru v4 UUID', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = DeviceIdentityService(prefs);

      final id = service.deviceId;

      expect(id, isNotEmpty);
      expect(id.length, 36);
      expect(id[8], '-');
      expect(id[13], '-');
      expect(id[18], '-');
      expect(id[23], '-');
      expect(uuidV4Pattern.hasMatch(id), isTrue, reason: 'ID musí být validní v4 UUID: $id');
    });

    test('vrátí stejné ID při opakovaném čtení v rámci jedné instance', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = DeviceIdentityService(prefs);

      expect(service.deviceId, service.deviceId);
    });

    test('perzistuje ID — nová instance nad stejnými prefs vrátí totéž ID', () async {
      final prefs = await SharedPreferences.getInstance();
      final first = DeviceIdentityService(prefs).deviceId;

      // Uložená hodnota musí být v persistenci.
      expect(prefs.getString(deviceIdKey), first);

      // Nová instance nad stejnými (persistovanými) prefs čte tutéž hodnotu.
      final reloadedPrefs = await SharedPreferences.getInstance();
      final second = DeviceIdentityService(reloadedPrefs).deviceId;

      expect(second, first);
    });
  });
}
