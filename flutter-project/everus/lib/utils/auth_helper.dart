import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Defines the application run mode (can only be dev or prod)
enum AppMode { dev, prod }

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthHelper {
  static String get baseUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8009';
    }
    return 'http://127.0.0.1:8009';
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
      debugPrint("Failed to clear persisted session: $e");
    }
  }

  /// Normalizes signin/signup responses into a unified local session map
  static Map<String, dynamic> _normalizeSession(Map<String, dynamic> data) {
    // If it is the signup response, it contains nested 'session' and 'user' keys
    if (data.containsKey('session') && data['session'] != null) {
      final user = data['user'] as Map<String, dynamic>;
      final session = data['session'] as Map<String, dynamic>;
      return {
        'access_token': session['access_token'] as String?,
        'email': user['email'] as String?,
        'name': user['name'] as String?,
      };
    }
    // If it is the signin response, it contains top-level access_token and user keys
    final user = data['user'] as Map<String, dynamic>;
    final metadata = user['user_metadata'] as Map<String, dynamic>?;
    return {
      'access_token': data['access_token'] as String?,
      'email': user['email'] as String?,
      'name': metadata != null ? metadata['name'] as String? : '',
    };
  }

  /// Helper to perform HTTP POST requests using cross-platform http package
  static Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final response = await http.post(
        uri,
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
      final sessionData = _normalizeSession(response);
      sessionNotifier.value = sessionData;
      await _persistSession(sessionData);
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

    final sessionData = _normalizeSession(response);
    sessionNotifier.value = sessionData;
    await _persistSession(sessionData);
  }

  /// Log out current session
  static Future<void> signOut() async {
    try {
      final uri = Uri.parse('$baseUrl/auth/signout');
      await http.post(uri);
      
      // Also sign out from Google if logged in
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Ignore network errors on signout
    } finally {
      await _clearPersistedSession();
      sessionNotifier.value = null;
    }
  }

  /// Signs in a user using Google OAuth.
  static Future<void> signInWithGoogle() async {
    try {
      await GoogleSignIn.instance.initialize(
        clientId: kIsWeb ? '935315479839-f6rtlci4779ivfni4tm5hg1ko46uqa4r.apps.googleusercontent.com' : null,
        serverClientId: '935315479839-f6rtlci4779ivfni4tm5hg1ko46uqa4r.apps.googleusercontent.com',
      );

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

      final sessionData = _normalizeSession(response);
      sessionNotifier.value = sessionData;
      await _persistSession(sessionData);
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
