import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  StorageService._();

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static const String _keyOnboardingCompleted = 'onboarding_completed';
  static const String _keySelectedLanguage = 'selected_language'; // 'ar' or 'en'

  static bool get isOnboardingCompleted =>
      _prefs.getBool(_keyOnboardingCompleted) ?? false;

  static Future<void> setOnboardingCompleted() async {
    await _prefs.setBool(_keyOnboardingCompleted, true);
  }

  static String? get selectedLanguage =>
      _prefs.getString(_keySelectedLanguage);

  static Future<void> setSelectedLanguage(String languageCode) async {
    await _prefs.setString(_keySelectedLanguage, languageCode);
  }
}
