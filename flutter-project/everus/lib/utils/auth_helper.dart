import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Defines the application run mode (can only be dev or prod)
enum AppMode { dev, prod }

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthHelper {
  // Constant to switch application mode
  static const AppMode mode = AppMode.dev;

  static const String _prodUrl = 'https://api.everus.example.com';

  static String get _devUrl {
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8000';
      }
    } catch (_) {
      // Fallback
    }
    return 'http://127.0.0.1:8000';
  }

  static String get baseUrl => mode == AppMode.prod ? _prodUrl : _devUrl;

  // Session state notifier
  static final ValueNotifier<Map<String, dynamic>?> sessionNotifier = ValueNotifier(null);

  // Helper getters
  static bool get isLoggedIn => sessionNotifier.value != null;

  static String? get currentUserName => sessionNotifier.value?['name'] as String?;

  static String? get currentUserEmail => sessionNotifier.value?['email'] as String?;

  static String? get currentAccessToken => sessionNotifier.value?['access_token'] as String?;

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

  /// Helper to perform HTTP POST requests using Dart's native HttpClient (no dependencies)
  static Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    final client = HttpClient();
    try {
      final uri = Uri.parse('$baseUrl$path');
      final request = await client.postUrl(uri);
      
      request.headers.contentType = ContentType.json;
      request.write(json.encode(body));
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      final Map<String, dynamic> responseData = json.decode(responseBody);
      
      if (response.statusCode >= 400) {
        throw AuthException(responseData['detail'] ?? 'Authentication failed');
      }
      
      return responseData;
    } on SocketException {
      throw const AuthException('Failed to connect to backend server. Make sure the backend is running.');
    } on FormatException {
      throw const AuthException('Invalid response format from authentication server');
    } finally {
      client.close();
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
      sessionNotifier.value = _normalizeSession(response);
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

    sessionNotifier.value = _normalizeSession(response);
  }

  /// Log out current session
  static Future<void> signOut() async {
    final client = HttpClient();
    try {
      final uri = Uri.parse('$baseUrl/auth/signout');
      final request = await client.postUrl(uri);
      await request.close();
      
      // Also sign out from Google if logged in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
    } catch (_) {
      // Ignore network errors on signout
    } finally {
      client.close();
      sessionNotifier.value = null;
    }
  }

  // Google Sign-In instance configured with Web Client ID
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '935315479839-f6rtlci4779ivfni4tm5hg1ko46uqa4r.apps.googleusercontent.com',
  );

  /// Signs in a user using Google OAuth.
  static Future<void> signInWithGoogle() async {
    try {
      // Trigger the flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the sign-in
        return;
      }

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw const AuthException('Failed to retrieve Google ID Token.');
      }

      // Post to backend
      final response = await _post('/auth/google', {
        'id_token': idToken,
      });

      sessionNotifier.value = _normalizeSession(response);
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException('Google Sign-In failed: $e');
    }
  }
}
