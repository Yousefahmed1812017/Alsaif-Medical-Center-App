import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  StorageService._();

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static const String _keyOnboardingCompleted = 'onboarding_completed';
  static const String _keySelectedLanguage = 'selected_language'; // 'ar' or 'en'
  static const String _keyAuthToken = 'auth_token';
  static const String _keyUserProfile = 'user_profile';

  // ─── Onboarding ─────────────────────────────────────────────────────
  static bool get isOnboardingCompleted =>
      _prefs.getBool(_keyOnboardingCompleted) ?? false;

  static Future<void> setOnboardingCompleted() async {
    await _prefs.setBool(_keyOnboardingCompleted, true);
  }

  // ─── Language ───────────────────────────────────────────────────────
  static String? get selectedLanguage =>
      _prefs.getString(_keySelectedLanguage);

  static Future<void> setSelectedLanguage(String languageCode) async {
    await _prefs.setString(_keySelectedLanguage, languageCode);
  }

  // ─── Auth Token ─────────────────────────────────────────────────────
  static String? get authToken => _prefs.getString(_keyAuthToken);

  static Future<void> setAuthToken(String token) async {
    await _prefs.setString(_keyAuthToken, token);
  }

  static Future<void> clearAuthToken() async {
    await _prefs.remove(_keyAuthToken);
  }

  // ─── User Profile ──────────────────────────────────────────────────
  static String? get userProfile => _prefs.getString(_keyUserProfile);

  static Future<void> setUserProfile(String jsonString) async {
    await _prefs.setString(_keyUserProfile, jsonString);
  }

  static Future<void> clearUserProfile() async {
    await _prefs.remove(_keyUserProfile);
  }

  // ─── Clear All Session Data ────────────────────────────────────────
  static Future<void> clearSession() async {
    await Future.wait([
      clearAuthToken(),
      clearUserProfile(),
    ]);
  }
}
