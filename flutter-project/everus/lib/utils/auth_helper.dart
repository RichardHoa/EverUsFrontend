import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';
import 'love_counter_helper.dart';
import 'questionnaire_helper.dart';

// Defines the application run mode (can only be dev or prod)
enum AppMode { dev, prod }

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthHelper {
  // Manual override (set to null for auto-detection, or AppMode.dev / AppMode.prod to force)
  static const AppMode? manualMode = null;

  static const String _prodUrl = 'https://everus-backend.richardhoa.io.vn';
  static const String _envBaseUrl = String.fromEnvironment('BACKEND_URL');

  static bool _isLocalHost(String host) {
    if (host.isEmpty) return true;
    final lower = host.toLowerCase();
    if (lower == 'localhost' || lower == '127.0.0.1' || lower == '0.0.0.0' || lower == '::1') {
      return true;
    }
    // Check private LAN IP ranges (192.168.x.x, 10.x.x.x, 172.16-31.x.x)
    if (lower.startsWith('192.168.') || lower.startsWith('10.') || RegExp(r'^172\.(1[6-9]|2[0-9]|3[0-1])\.').hasMatch(lower)) {
      return true;
    }
    return false;
  }

  static String get _devUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8009';
    }
    return 'http://localhost:8009';
  }

  static bool get isDevMode => baseUrl.contains('localhost') || baseUrl.contains('127.0.0.1') || baseUrl.contains('10.0.2.2');

  static String get baseUrl {
    // 1. Environment variable override (--dart-define=BACKEND_URL=https://...)
    if (_envBaseUrl.isNotEmpty) return _envBaseUrl;

    // 2. Manual override in code
    if (manualMode == AppMode.prod) return _prodUrl;
    if (manualMode == AppMode.dev) return _devUrl;

    // 3. Auto-detection:
    // When built for release (flutter build / flutter run --release), always use Production
    if (kReleaseMode) return _prodUrl;

    // On Web
    if (kIsWeb) {
      final host = Uri.base.host;
      // If deployed on a real public domain, use Production
      if (host.isNotEmpty && !_isLocalHost(host)) {
        return _prodUrl;
      }
      return _devUrl;
    }

    // Default for native local development (iOS Simulator / Android Emulator / Desktop)
    return _devUrl;
  }

  // Session state notifier
  static final ValueNotifier<Map<String, dynamic>?> sessionNotifier = ValueNotifier(null);

  // Helper getters
  static bool get isLoggedIn => sessionNotifier.value != null;

  static String? get currentUserName => sessionNotifier.value?['name'] as String?;

  static String? get currentUserEmail => sessionNotifier.value?['email'] as String?;

  static String? get currentAccessToken => sessionNotifier.value?['access_token'] as String?;

  static Future<void> initializeSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = prefs.getString('auth_session');
      final loginTimeStr = prefs.getString('auth_login_time');
      if (sessionJson != null && loginTimeStr != null) {
        final loginTime = DateTime.parse(loginTimeStr);
        final difference = DateTime.now().difference(loginTime);
        if (difference.inDays < 14) {
          sessionNotifier.value = Map<String, dynamic>.from(json.decode(sessionJson));
          LoveCounterHelper.handleAuthChange();
        } else {
          await signOut();
        }
      }
    } catch (e) {
      debugPrint("Failed to initialize session: $e");
    }
  }

  static Future<void> _persistSession(Map<String, dynamic> session) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_session', json.encode(session));
      await prefs.setString('auth_login_time', DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint("Failed to persist session: $e");
    }
  }

  static Future<void> _clearPersistedSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_session');
      await prefs.remove('auth_login_time');
    } catch (e) {
      debugPrint("Failed to clear persona data cache: $e");
    }
  }

  /// Normalizes signin/signup responses into a unified local session map
  static Map<String, dynamic> _normalizeSession(Map<String, dynamic> data) {
    // If it is the signup response, it contains nested 'session' and 'user' keys
    if (data.containsKey('session') && data['session'] != null) {
      final user = data['user'] as Map<String, dynamic>? ?? {};
      final session = data['session'] as Map<String, dynamic>? ?? {};
      return {
        'access_token': session['access_token'] as String?,
        'email': user['email'] as String?,
        'name': user['name'] as String? ?? (user['user_metadata'] is Map ? (user['user_metadata']['name'] as String?) : null) ?? '',
      };
    }
    // If it is the signin response, it contains top-level access_token and user keys
    final user = data['user'] as Map<String, dynamic>? ?? {};
    final metadata = user['user_metadata'] is Map<String, dynamic> ? user['user_metadata'] as Map<String, dynamic> : null;
    final String? nameFromMetadata = metadata != null ? (metadata['name'] as String? ?? metadata['full_name'] as String?) : null;
    return {
      'access_token': data['access_token'] as String?,
      'email': user['email'] as String?,
      'name': nameFromMetadata ?? user['name'] as String? ?? '',
    };
  }

  /// Helper to perform HTTP POST requests using cross-platform http package
  static Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    try {
      final response = await ApiClient.client.post(
        ApiClient.uri(path),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      
      final Map<String, dynamic> responseData = json.decode(utf8.decode(response.bodyBytes));
      
      if (response.statusCode >= 400) {
        throw AuthException(responseData['detail'] ?? 'Authentication failed');
      }
      
      return responseData;
    } on AuthException {
      rethrow;
    } on FormatException {
      throw const AuthException('Invalid response format from authentication server');
    } catch (e) {
      throw AuthException('Failed to connect to backend server. Make sure the backend is running.');
    }
  }

  /// Stores a fresh session, then moves this device's guest data onto the account.
  static Future<void> _startSession(Map<String, dynamic> sessionData) async {
    sessionNotifier.value = sessionData;
    await _persistSession(sessionData);
    await _mergeGuestDevice();
    // The account may already have answered the questionnaire elsewhere.
    await QuestionnaireHelper.refreshFromServer();
    LoveCounterHelper.handleAuthChange();
  }

  /// Reassigns likes/dislikes and questionnaire answers made as a guest on this
  /// install to the signed-in account. Best effort: never blocks sign-in.
  static Future<void> _mergeGuestDevice() async {
    try {
      final response = await ApiClient.client
          .post(ApiClient.uri('/auth/merge-device'), headers: await ApiClient.headers())
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) {
        debugPrint("Device merge responded with status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Failed to merge guest device data: $e");
    }
  }

  /// Signs up a new user using the FastAPI backend.
  static Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await _post('/auth/signup', {
      'email': email,
      'password': password,
      'name': name,
    });

    if (response['session'] != null) {
      await _startSession(_normalizeSession(response));
    }
  }

  /// Signs in a user using the FastAPI backend.
  static Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _post('/auth/signin', {
      'email': email,
      'password': password,
    });

    await _startSession(_normalizeSession(response));
  }

  /// Log out current session
  static Future<void> signOut() async {
    try {
      final uri = Uri.parse('$baseUrl/auth/signout');
      await http.post(uri).timeout(const Duration(seconds: 5), onTimeout: () => http.Response('', 408));
    } catch (e) {
      debugPrint("Signout network request failed or timed out: $e");
    }

    try {
      // Safely attempt Google sign-out with timeout to prevent hanging on Web when uninitialized
      await GoogleSignIn.instance.signOut().timeout(const Duration(seconds: 2), onTimeout: () => null);
    } catch (e) {
      debugPrint("Google signout failed or skipped: $e");
    }

    await _clearPersistedSession();
    sessionNotifier.value = null;

    // Wipe locally cached per-account state so the next user who signs in on
    // this device starts blank instead of seeing the previous user's love
    // counter or skipping the questionnaire because of a stale cached flag.
    await LoveCounterHelper.clearLocalData();
    await QuestionnaireHelper.resetQuestionnaire();
  }

  static bool _isGoogleSignInInitialized = false;

  static Future<void> _ensureGoogleSignInInitialized() async {
    if (_isGoogleSignInInitialized) return;
    try {
      await GoogleSignIn.instance.initialize(
        clientId: kIsWeb ? '935315479839-f6rtlci4779ivfni4tm5hg1ko46uqa4r.apps.googleusercontent.com' : null,
        serverClientId: kIsWeb ? null : '935315479839-f6rtlci4779ivfni4tm5hg1ko46uqa4r.apps.googleusercontent.com',
      );
      _isGoogleSignInInitialized = true;
    } catch (e) {
      if (e.toString().contains('already been called')) {
        _isGoogleSignInInitialized = true;
      } else {
        rethrow;
      }
    }
  }

  /// Signs in a user using Google OAuth.
  static Future<void> signInWithGoogle() async {
    try {
      await _ensureGoogleSignInInitialized();

      String? idToken;
      String? accessToken;

      if (GoogleSignIn.instance.supportsAuthenticate()) {
        // Native platforms (Android, iOS)
        final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();
        final GoogleSignInAuthentication googleAuth = googleUser.authentication;
        idToken = googleAuth.idToken;

        final clientAuth = await googleUser.authorizationClient.authorizationForScopes(['email', 'profile']);
        accessToken = clientAuth?.accessToken;
      } else {
        // Web platform (where authenticate() is not supported by Google Identity Services)
        final clientAuth = await GoogleSignIn.instance.authorizationClient.authorizeScopes(['email', 'profile']);
        accessToken = clientAuth.accessToken;
      }

      if ((idToken == null || idToken.isEmpty) && (accessToken == null || accessToken.isEmpty)) {
        throw const AuthException('Failed to retrieve Google authentication tokens.');
      }

      // Post to backend
      final Map<String, dynamic> body = {};
      if (idToken != null && idToken.isNotEmpty) {
        body['id_token'] = idToken;
      }
      if (accessToken != null && accessToken.isNotEmpty) {
        body['access_token'] = accessToken;
      }

      final response = await _post('/auth/google', body);

      await _startSession(_normalizeSession(response));
    } catch (e) {
      if (e is GoogleSignInException && e.code == GoogleSignInExceptionCode.canceled) {
        // User cancelled the sign-in
        return;
      }
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException('Google Sign-In failed: $e');
    }
  }
}
