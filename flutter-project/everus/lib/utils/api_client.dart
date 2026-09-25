import 'package:http/http.dart' as http;
import 'auth_helper.dart';
import 'device_id_helper.dart';

/// Shared HTTP client and identity headers for backend calls.
///
/// [client] is swappable so tests can install a fake backend.
class ApiClient {
  static http.Client client = http.Client();

  static Uri uri(String path) => Uri.parse('${AuthHelper.baseUrl}$path');

  /// JSON headers with the bearer token (when logged in) and the install's device id.
  static Future<Map<String, String>> headers() async {
    final token = AuthHelper.currentAccessToken;
    return {
      'Content-Type': 'application/json',
      'X-Device-Id': await DeviceIdHelper.getDeviceId(),
      if (AuthHelper.isLoggedIn && token != null) 'Authorization': 'Bearer $token',
    };
  }
}
