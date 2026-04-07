import '../models/user_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

/// Handles authentication logic: calls API, persists user data.
class AuthService {
  AuthService._();

  /// Cached user model for the current session.
  static UserModel? _currentUser;

  /// Attempts login with the given [username] (email) and [password].
  ///
  /// Internally:
  /// 1. Gets a bearer token from the app-level authenticate endpoint.
  /// 2. Calls LoginUser with user credentials + bearer token.
  /// 3. Stores the user profile locally.
  ///
  /// Returns the [UserModel] on success.
  /// Throws [ApiException] on failure.
  static Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    final response = await ApiService.loginUser(
      username: username,
      password: password,
    );

    final userData = response['data'] as Map<String, dynamic>;
    final user = UserModel.fromJson(userData);

    // Persist user profile for the session
    await StorageService.setUserProfile(user.toJsonString());

    _currentUser = user;
    return user;
  }

  /// Returns the current logged-in user, loading from storage if needed.
  static UserModel? get currentUser {
    if (_currentUser != null) return _currentUser;

    final json = StorageService.userProfile;
    if (json != null) {
      _currentUser = UserModel.fromJsonString(json);
    }
    return _currentUser;
  }

  /// Whether the user currently has a stored profile.
  static bool get isLoggedIn => StorageService.userProfile != null;

  /// Clears stored session data (logout).
  static Future<void> logout() async {
    _currentUser = null;
    await StorageService.clearSession();
  }
}
