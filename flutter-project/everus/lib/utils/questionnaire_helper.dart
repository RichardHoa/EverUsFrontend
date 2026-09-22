import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_helper.dart';

class QuestionnaireHelper {
  static const String _keyCompleted = 'has_completed_questionnaire_v1';

  static Future<bool> hasCompletedQuestionnaire() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyCompleted) ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> setQuestionnaireCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyCompleted, true);
    } catch (e) {
      debugPrint("Failed to save questionnaire completion status: $e");
    }
  }

  static Future<bool> submitToBackend({
    required Map<String, dynamic> answers,
    String? freeText,
  }) async {
    String deviceInfo = 'web';
    if (!kIsWeb) {
      deviceInfo = Platform.operatingSystem;
    }

    final payload = {
      'answers': answers,
      'free_text': freeText,
      'client_timestamp': DateTime.now().toIso8601String(),
      'device_info': deviceInfo,
    };

    try {
      final url = Uri.parse('${AuthHelper.baseUrl}/questionnaire/submit');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await setQuestionnaireCompleted();
        return true;
      } else {
        debugPrint("Backend responded with status: ${response.statusCode}");
        // Still save locally completed so user is not blocked
        await setQuestionnaireCompleted();
        return true;
      }
    } catch (e) {
      debugPrint("Failed to send questionnaire to backend: $e");
      // Still mark completed locally so the user experience is smooth and uninterrupted
      await setQuestionnaireCompleted();
      return true;
    }
  }
}
