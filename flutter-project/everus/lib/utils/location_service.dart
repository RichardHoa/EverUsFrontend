import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'api_client.dart';

class UserLocation {
  final double latitude;
  final double longitude;

  /// Human-readable description (e.g. the geocoded address), if known.
  final String? label;

  const UserLocation({required this.latitude, required this.longitude, this.label});
}

/// The user declined (or the platform blocks) location access.
class LocationPermissionDeniedException implements Exception {
  const LocationPermissionDeniedException();

  @override
  String toString() => 'Không thể truy cập vị trí. Hãy nhập địa chỉ của bạn nhé!';
}

class LocationLookupException implements Exception {
  final String message;
  const LocationLookupException(this.message);

  @override
  String toString() => message;
}

abstract class LocationService {
  /// Current device position. Throws [LocationPermissionDeniedException] when not allowed.
  Future<UserLocation> currentLocation();

  /// Resolves a typed address. Throws [LocationLookupException] when it cannot be found.
  Future<UserLocation> geocode(String address);
}

/// Device GPS via geolocator, with manual addresses geocoded by the backend.
class DeviceLocationService implements LocationService {
  const DeviceLocationService();

  @override
  Future<UserLocation> currentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw const LocationPermissionDeniedException();
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        throw const LocationPermissionDeniedException();
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium, timeLimit: Duration(seconds: 15)),
      );
      return UserLocation(latitude: position.latitude, longitude: position.longitude);
    } on LocationPermissionDeniedException {
      rethrow;
    } catch (_) {
      // Unsupported platform, timeout, or browser-level block: fall back to a typed address.
      throw const LocationPermissionDeniedException();
    }
  }

  @override
  Future<UserLocation> geocode(String address) async {
    final uri = ApiClient.uri('/api/date-planner/geocode').replace(queryParameters: {'q': address});
    final response = await ApiClient.client.get(uri, headers: await ApiClient.headers()).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return UserLocation(
        latitude: (data['latitude'] as num).toDouble(),
        longitude: (data['longitude'] as num).toDouble(),
        label: data['display_name'] as String? ?? address,
      );
    }
    throw const LocationLookupException('Không tìm thấy địa chỉ này. Hãy thử nhập chi tiết hơn nhé!');
  }
}
