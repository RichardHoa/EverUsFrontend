import 'package:everus/utils/device_id_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_setup.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => resetAppState());

  test('generates a UUID v4 once and persists it', () async {
    final first = await DeviceIdHelper.getDeviceId();

    expect(first, matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')));
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(DeviceIdHelper.prefsKey), first);

    // Survives an app restart (in-memory cache cleared, prefs kept).
    DeviceIdHelper.resetForTesting();
    expect(await DeviceIdHelper.getDeviceId(), first);
  });

  test('reuses an id already stored on this install', () async {
    await resetAppState(prefs: {DeviceIdHelper.prefsKey: 'existing-id'});
    expect(await DeviceIdHelper.getDeviceId(), 'existing-id');
  });
}
