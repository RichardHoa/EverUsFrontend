import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_helper.dart';
import 'file_helper/file_helper.dart';

class LoveCounterHelper {
  /// Calculates exact calendar days between an anniversary date and target date (defaults to today).
  static int calculateLoveDays(DateTime anniversaryDate, [DateTime? targetDate]) {
    final now = targetDate ?? DateTime.now();
    final aDate = DateTime(anniversaryDate.year, anniversaryDate.month, anniversaryDate.day);
    final cDate = DateTime(now.year, now.month, now.day);
    final diff = cDate.difference(aDate).inDays;
    return diff >= 0 ? diff + 1 : 0;
  }

  static const String _keyUserName = 'love_user_name';
  static const String _keyLoverName = 'love_lover_name';
  static const String _keyAnniversaryDate = 'love_anniversary_date';
  static const String _keyUserImagePath = 'love_user_image_path';
  static const String _keyLoverImagePath = 'love_lover_image_path';
  static const String _keyUseDetailedView = 'love_use_detailed_view';

  /// Check if the configuration has been set (i.e. names and date exist)
  static Future<bool> isConfigured() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString(_keyUserName);
    final loverName = prefs.getString(_keyLoverName);
    final dateStr = prefs.getString(_keyAnniversaryDate);
    return userName != null && 
           userName.isNotEmpty && 
           loverName != null && 
           loverName.isNotEmpty && 
           dateStr != null;
  }

  /// Load current love counter configuration
  static Future<Map<String, dynamic>> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = prefs.getString(_keyAnniversaryDate);
    DateTime? annivDate;
    if (dateStr != null) {
      try {
        annivDate = DateTime.parse(dateStr);
      } catch (_) {
        // Ignore parsing errors
      }
    }

    return {
      'userName': prefs.getString(_keyUserName) ?? '',
      'loverName': prefs.getString(_keyLoverName) ?? '',
      'anniversaryDate': annivDate,
      'userImagePath': prefs.getString(_keyUserImagePath),
      'loverImagePath': prefs.getString(_keyLoverImagePath),
      'useDetailedView': prefs.getBool(_keyUseDetailedView) ?? false,
    };
  }

  /// Save love counter configuration settings (to local storage and backend if logged in)
  static Future<void> saveSettings({
    required String userName,
    required String loverName,
    required DateTime anniversaryDate,
    String? userImagePath,
    String? loverImagePath,
    bool? useDetailedView,
    bool syncToBackend = true,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserName, userName);
    await prefs.setString(_keyLoverName, loverName);
    await prefs.setString(_keyAnniversaryDate, anniversaryDate.toIso8601String());
    
    if (userImagePath != null) {
      await prefs.setString(_keyUserImagePath, userImagePath);
    }
    if (loverImagePath != null) {
      await prefs.setString(_keyLoverImagePath, loverImagePath);
    }
    if (useDetailedView != null) {
      await prefs.setBool(_keyUseDetailedView, useDetailedView);
    }

    if (syncToBackend && AuthHelper.isLoggedIn) {
      syncWithBackend();
    }
  }

  /// Upload local date counter configuration to backend database
  static Future<bool> syncWithBackend() async {
    if (!AuthHelper.isLoggedIn) return false;
    final token = AuthHelper.currentAccessToken;
    if (token == null) return false;

    try {
      final settings = await loadSettings();
      final userName = settings['userName'] as String?;
      final loverName = settings['loverName'] as String?;
      final annivDate = settings['anniversaryDate'] as DateTime?;

      if (userName == null || userName.isEmpty || loverName == null || loverName.isEmpty || annivDate == null) {
        return false;
      }

      final uri = Uri.parse('${AuthHelper.baseUrl}/api/date-counter');
      final response = await http.put(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_name': userName,
          'lover_name': loverName,
          'anniversary_date': annivDate.toUtc().toIso8601String(),
          'use_detailed_view': settings['useDetailedView'] ?? false,
          'user_image_path': settings['userImagePath'],
          'lover_image_path': settings['loverImagePath'],
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error syncing date counter to backend: $e");
      return false;
    }
  }

  /// Fetch date counter configuration from backend and restore locally
  static Future<bool> fetchAndRestoreFromBackend() async {
    if (!AuthHelper.isLoggedIn) return false;
    final token = AuthHelper.currentAccessToken;
    if (token == null) return false;

    try {
      final uri = Uri.parse('${AuthHelper.baseUrl}/api/date-counter');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 && response.body.isNotEmpty && response.body != 'null') {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>?;
        if (data != null && data['anniversary_date'] != null) {
          final annivDate = DateTime.parse(data['anniversary_date']);
          await saveSettings(
            userName: data['user_name'] ?? '',
            loverName: data['lover_name'] ?? '',
            anniversaryDate: annivDate,
            userImagePath: data['user_image_path'],
            loverImagePath: data['lover_image_path'],
            useDetailedView: data['use_detailed_view'] ?? false,
            syncToBackend: false,
          );
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint("Error fetching date counter from backend: $e");
      return false;
    }
  }

  /// Wipes all locally cached love-counter data for the current install.
  /// Call this on logout so the next signed-in user starts blank instead of
  /// inheriting (and potentially overwriting) the previous account's data.
  static Future<void> clearLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyLoverName);
    await prefs.remove(_keyAnniversaryDate);
    await prefs.remove(_keyUserImagePath);
    await prefs.remove(_keyLoverImagePath);
    await prefs.remove(_keyUseDetailedView);
  }

  /// Trigger sync or restore upon authentication change
  static Future<void> handleAuthChange() async {
    if (!AuthHelper.isLoggedIn) return;
    try {
      final isLocalConfigured = await isConfigured();
      if (isLocalConfigured) {
        await syncWithBackend();
      } else {
        await fetchAndRestoreFromBackend();
      }
    } catch (e) {
      debugPrint("Error handling auth change in LoveCounterHelper: $e");
    }
  }

  /// Save single image path specifically
  static Future<void> saveImagePath(String key, String path) async {
    final prefs = await SharedPreferences.getInstance();
    if (key == 'user') {
      await prefs.setString(_keyUserImagePath, path);
    } else if (key == 'lover') {
      await prefs.setString(_keyLoverImagePath, path);
    }
    if (AuthHelper.isLoggedIn) {
      syncWithBackend();
    }
  }

  /// Save the detailed view toggle status
  static Future<void> saveUseDetailedView(bool useDetailed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyUseDetailedView, useDetailed);
    if (AuthHelper.isLoggedIn) {
      syncWithBackend();
    }
  }

  /// Pick an image from gallery or camera and save it using cross-platform AppFileHelper
  static Future<String?> pickAndSaveImage(ImageSource source, String? oldPath) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: source, imageQuality: 85);
      if (pickedFile == null) return null;

      return await AppFileHelper.savePickedImage(pickedFile, oldPath);
    } catch (e) {
      return null;
    }
  }
}

