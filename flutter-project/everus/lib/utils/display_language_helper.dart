import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';

/// The user's chosen Display language (UI chrome only — Content stays as authored).
///
/// Stored per device, so it survives logout and is not synced between partners.
class DisplayLanguageHelper {
  static const String _keyLanguage = 'display_language_v1';
  static const Locale vietnamese = Locale('vi');
  static const Locale english = Locale('en');

  static final ValueNotifier<Locale> localeNotifier = ValueNotifier<Locale>(vietnamese);

  static bool get isEnglish => localeNotifier.value == english;

  /// Strings for code that runs outside the widget tree (exceptions, OS notifications).
  static AppLocalizations get strings => lookupAppLocalizations(localeNotifier.value);

  /// Call once during main() startup.
  static Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getString(_keyLanguage) == english.languageCode) {
        localeNotifier.value = english;
      }
    } catch (e) {
      debugPrint("Failed to load display language: $e");
    }
  }

  static Future<void> setLocale(Locale locale) async {
    localeNotifier.value = locale;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLanguage, locale.languageCode);
    } catch (e) {
      debugPrint("Failed to save display language: $e");
    }
  }
}
