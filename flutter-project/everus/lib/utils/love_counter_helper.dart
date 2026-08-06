import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'file_helper/file_helper.dart';

class LoveCounterHelper {
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

  /// Save love counter configuration settings
  static Future<void> saveSettings({
    required String userName,
    required String loverName,
    required DateTime anniversaryDate,
    String? userImagePath,
    String? loverImagePath,
    bool? useDetailedView,
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
  }

  /// Save single image path specifically
  static Future<void> saveImagePath(String key, String path) async {
    final prefs = await SharedPreferences.getInstance();
    if (key == 'user') {
      await prefs.setString(_keyUserImagePath, path);
    } else if (key == 'lover') {
      await prefs.setString(_keyLoverImagePath, path);
    }
  }

  /// Save the detailed view toggle status
  static Future<void> saveUseDetailedView(bool useDetailed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyUseDetailedView, useDetailed);
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
