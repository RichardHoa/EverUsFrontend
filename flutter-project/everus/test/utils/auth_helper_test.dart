import 'package:everus/utils/auth_helper.dart';
import 'package:everus/utils/device_id_helper.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_setup.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => resetAppState());

  RecordingClient fakeBackend() => RecordingClient((req) {
        switch (req.url.path) {
          case '/auth/signin':
            return jsonResponse({
              'access_token': 'new-token',
              'user': {'email': 'a@b.c', 'name': 'A'},
            });
          case '/auth/signup':
            return jsonResponse({
              'session': {'access_token': 'new-token'},
              'user': {'email': 'a@b.c', 'name': 'A'},
            });
          case '/auth/merge-device':
            return jsonResponse({'merged_preferences': 1, 'merged_questionnaire_responses': 0});
          case '/questionnaire/status':
            return jsonResponse({'answered': true});
          default:
            return jsonResponse({}, 404);
        }
      });

  test('sign-in merges the guest device into the account', () async {
    final backend = fakeBackend();
    final deviceId = await DeviceIdHelper.getDeviceId();

    await AuthHelper.signIn(email: 'a@b.c', password: 'pw');

    final merge = backend.to('POST', '/auth/merge-device').single;
    expect(merge.headers['Authorization'], 'Bearer new-token');
    expect(merge.headers['X-Device-Id'], deviceId);
  });

  test('sign-up merges the guest device into the account', () async {
    final backend = fakeBackend();

    await AuthHelper.signUp(email: 'a@b.c', password: 'password1', name: 'A');

    expect(backend.to('POST', '/auth/merge-device'), hasLength(1));
  });

  test('a failed merge does not break sign-in', () async {
    RecordingClient((req) => req.url.path == '/auth/signin'
        ? jsonResponse({'access_token': 't', 'user': {'email': 'a@b.c', 'name': 'A'}})
        : jsonResponse({'detail': 'down'}, 500));

    await AuthHelper.signIn(email: 'a@b.c', password: 'pw');

    expect(AuthHelper.isLoggedIn, isTrue);
  });
}
