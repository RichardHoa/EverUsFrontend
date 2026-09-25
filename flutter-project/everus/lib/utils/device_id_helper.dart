import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Anonymous per-install identity sent to the backend as the `X-Device-Id` header.
///
/// Lets guests keep likes/dislikes and questionnaire answers server-side; the
/// backend moves that data onto the account when the device signs in.
class DeviceIdHelper {
  static const String prefsKey = 'everus_device_id';

  static String? _cached;

  static Future<String> getDeviceId() async {
    if (_cached != null) return _cached!;
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getString(prefsKey);
      if (existing != null && existing.isNotEmpty) {
        return _cached = existing;
      }
      final created = _uuidV4();
      await prefs.setString(prefsKey, created);
      return _cached = created;
    } catch (e) {
      debugPrint("Failed to load device id: $e");
      return _cached = _uuidV4();
    }
  }

  static String _uuidV4() {
    final rng = Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // version 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // RFC 4122 variant
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-'
        '${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  @visibleForTesting
  static void resetForTesting() => _cached = null;
}
