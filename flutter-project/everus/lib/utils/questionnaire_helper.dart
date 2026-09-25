import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';
import 'auth_helper.dart';

/// Answers previously submitted by the signed-in user, used to pre-fill the edit flow.
class QuestionnaireAnswers {
  final Map<String, dynamic> answers;
  final String? freeText;

  const QuestionnaireAnswers({required this.answers, this.freeText});
}

/// Tracks whether this user/device has answered the onboarding questionnaire.
///
/// The server (`GET /questionnaire/status`) is the source of truth; the local
/// flag is only a fast-path cache and is written only after the server has
/// confirmed an answer exists.
class QuestionnaireHelper {
  static const String _keyCompleted = 'has_completed_couple_onboarding_v1';
  static const Duration _timeout = Duration(seconds: 8);

  /// Reactive notifier for questionnaire completion state
  static final ValueNotifier<bool> isCompletedNotifier = ValueNotifier<bool>(false);

  static bool get isCompleted => isCompletedNotifier.value;

  /// Only accounts can revisit their answers; guests answer once.
  static bool get canEditAnswers => AuthHelper.isLoggedIn;

  /// Call once during main() startup (and again after sign-in via [refreshFromServer]).
  static Future<void> initialize() async {
    if (await _hasCachedCompletion()) {
      isCompletedNotifier.value = true;
      return;
    }
    await refreshFromServer();
  }

  /// Asks the server whether the current identity (account or device) has answered.
  static Future<void> refreshFromServer() async {
    try {
      final response = await ApiClient.client
          .get(ApiClient.uri('/questionnaire/status'), headers: await ApiClient.headers())
          .timeout(_timeout);
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        if (data['answered'] == true) {
          await _cacheCompletion();
          isCompletedNotifier.value = true;
          return;
        }
      }
    } catch (e) {
      debugPrint("Failed to check questionnaire status: $e");
    }
    isCompletedNotifier.value = isCompletedNotifier.value && await _hasCachedCompletion();
  }

  static Future<bool> hasCompletedQuestionnaire() => _hasCachedCompletion();

  static Future<bool> _hasCachedCompletion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyCompleted) ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> _cacheCompletion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyCompleted, true);
    } catch (e) {
      debugPrint("Failed to cache questionnaire completion: $e");
    }
  }

  /// Lets the user continue into the app for this session without caching the answer.
  static void markCompletedForSession() {
    isCompletedNotifier.value = true;
  }

  static Future<void> resetQuestionnaire() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyCompleted);
    } catch (e) {
      debugPrint("Failed to reset questionnaire status: $e");
    }
    isCompletedNotifier.value = false;
  }

  static Map<String, dynamic> _payload(Map<String, dynamic> answers, String? freeText) {
    String deviceInfo = 'web';
    if (!kIsWeb) {
      try {
        deviceInfo = Platform.operatingSystem;
      } catch (_) {
        deviceInfo = 'unknown';
      }
    }
    return {
      'answers': answers,
      'free_text': freeText,
      'client_timestamp': DateTime.now().toIso8601String(),
      'device_info': deviceInfo,
    };
  }

  /// Submits first-time answers. Returns whether the server stored them.
  ///
  /// The user is never blocked: on failure they continue for this session, and
  /// because nothing is cached the app asks again on the next launch.
  static Future<bool> submitToBackend({
    required Map<String, dynamic> answers,
    String? freeText,
  }) async {
    var stored = false;
    try {
      final response = await ApiClient.client
          .post(
            ApiClient.uri('/questionnaire/submit'),
            headers: await ApiClient.headers(),
            body: json.encode(_payload(answers, freeText)),
          )
          .timeout(_timeout);
      stored = response.statusCode >= 200 && response.statusCode < 300;
      if (!stored) {
        debugPrint("Backend responded with status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Failed to send questionnaire to backend: $e");
    }

    if (stored) {
      await _cacheCompletion();
    }
    markCompletedForSession();
    return stored;
  }

  /// Replaces a signed-in user's answers (edit flow from the profile page).
  static Future<bool> updateOnBackend({
    required Map<String, dynamic> answers,
    String? freeText,
  }) async {
    if (!canEditAnswers) return false;
    try {
      final response = await ApiClient.client
          .put(
            ApiClient.uri('/questionnaire/submit'),
            headers: await ApiClient.headers(),
            body: json.encode(_payload(answers, freeText)),
          )
          .timeout(_timeout);
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      debugPrint("Failed to update questionnaire answers: $e");
      return false;
    }
  }

  /// Autosaves in-progress answers so the user can resume where they left off.
  /// Fire-and-forget: never blocks the UI, silently ignored on failure/offline,
  /// and a no-op server-side once the questionnaire has been submitted.
  static Future<void> saveDraft({
    required Map<String, dynamic> answers,
    String? freeText,
  }) async {
    try {
      await ApiClient.client
          .patch(
            ApiClient.uri('/questionnaire/draft'),
            headers: await ApiClient.headers(),
            body: json.encode(_payload(answers, freeText)),
          )
          .timeout(_timeout);
    } catch (e) {
      debugPrint("Failed to autosave questionnaire draft: $e");
    }
  }

  /// The current identity's answers (in-progress or submitted), used to
  /// pre-fill the questionnaire on resume. Available to guests too, unlike
  /// [fetchMyAnswers] which is only for the signed-in edit flow.
  static Future<QuestionnaireAnswers?> fetchDraft() async {
    try {
      final response = await ApiClient.client
          .get(ApiClient.uri('/questionnaire/draft'), headers: await ApiClient.headers())
          .timeout(_timeout);
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return QuestionnaireAnswers(
          answers: Map<String, dynamic>.from(data['answers'] as Map? ?? {}),
          freeText: data['free_text'] as String?,
        );
      }
    } catch (e) {
      debugPrint("Failed to fetch questionnaire draft: $e");
    }
    return null;
  }

  /// The signed-in user's latest answers, or null when there are none (or on error).
  static Future<QuestionnaireAnswers?> fetchMyAnswers() async {
    if (!canEditAnswers) return null;
    try {
      final response = await ApiClient.client
          .get(ApiClient.uri('/questionnaire/me'), headers: await ApiClient.headers())
          .timeout(_timeout);
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return QuestionnaireAnswers(
          answers: Map<String, dynamic>.from(data['answers'] as Map? ?? {}),
          freeText: data['free_text'] as String?,
        );
      }
    } catch (e) {
      debugPrint("Failed to fetch questionnaire answers: $e");
    }
    return null;
  }
}
