import 'api_service.dart';
import 'storage_service.dart';

/// Result model returned after a successful login.
class AuthResult {
  final String token;
  final String client;
  final String message;

  const AuthResult({
    required this.token,
    required this.client,
    required this.message,
  });
}

/// Handles authentication logic: calls API, persists token.
class AuthService {
  AuthService._();

  /// Attempts login with the given [username] and [password].
  ///
  /// On success, stores the token via [StorageService] and returns an [AuthResult].
  /// On failure, throws an [ApiException] (from [ApiService]).
  static Future<AuthResult> login({
    required String username,
    required String password,
  }) async {
    final data = await ApiService.authenticate(
      username: username,
      password: password,
    );

    final token = data['token'] as String;
    final client = data['client'] as String? ?? '';
    final message = data['message'] as String? ?? '';

    // Persist token for future API calls
    await StorageService.setAuthToken(token);

    return AuthResult(
      token: token,
      client: client,
      message: message,
    );
  }

  /// Whether the user currently has a stored auth token.
  static bool get isLoggedIn => StorageService.authToken != null;

  /// Clears the stored auth token (logout).
  static Future<void> logout() async {
    await StorageService.clearAuthToken();
  }
}
