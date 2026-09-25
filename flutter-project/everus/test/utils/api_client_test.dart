import 'package:everus/utils/api_client.dart';
import 'package:everus/utils/device_id_helper.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_setup.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => resetAppState());

  test('guest headers carry the device id but no token', () async {
    final headers = await ApiClient.headers();
    expect(headers['X-Device-Id'], await DeviceIdHelper.getDeviceId());
    expect(headers.containsKey('Authorization'), isFalse);
    expect(headers['Content-Type'], 'application/json');
  });

  test('logged-in headers carry the bearer token and the device id', () async {
    logIn(token: 'abc');
    final headers = await ApiClient.headers();
    expect(headers['Authorization'], 'Bearer abc');
    expect(headers['X-Device-Id'], isNotEmpty);
  });
}
