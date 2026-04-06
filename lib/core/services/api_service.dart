import 'dart:convert';
import 'package:http/http.dart' as http;

/// Centralized API configuration and HTTP client for the Alsaif Medical app.
class ApiService {
  ApiService._();

  // ─── Base URL ───────────────────────────────────────────────────────
  static const String baseUrl = 'https://clinicintouch.com';

  // ─── Endpoints ──────────────────────────────────────────────────────
  static const String _authenticateEndpoint = '/ords/alsaif_crm/oauth/authenticate';
  static const String _loginUserEndpoint = '/ords/alsaif_crm/CrmFunctions/LoginUser';

  // ─── App Credentials (for bearer token) ─────────────────────────────
  static const String _appUsername = 'alsaif';
  static const String _appPassword = 'SHA408716';

  // ─── Headers ────────────────────────────────────────────────────────
  static Map<String, String> get _defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Map<String, String> _authHeaders(String token) => {
        ..._defaultHeaders,
        'Authorization': 'Bearer $token',
      };

  // ─── Step 1: Get Bearer Token ───────────────────────────────────────
  /// Authenticates with app-level credentials and returns a bearer token.
  ///
  /// Response: `{ "status": "success", "token": "..." }`
  static Future<String> _getAppToken() async {
    final uri = Uri.parse('$baseUrl$_authenticateEndpoint');

    final response = await http.post(
      uri,
      headers: _defaultHeaders,
      body: jsonEncode({
        'username': _appUsername,
        'password': _appPassword,
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 && body['status'] == 'success') {
      return body['token'] as String;
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: body['message']?.toString() ?? 'Failed to obtain app token',
    );
  }

  // ─── Step 2: Login User ─────────────────────────────────────────────
  /// Authenticates a real user (employee / doctor / admin) using the
  /// bearer token from Step 1.
  ///
  /// Returns the full JSON response:
  /// ```json
  /// {
  ///   "status": "success",
  ///   "code": 200,
  ///   "message": "...",
  ///   "messageEn": "Login successful",
  ///   "data": { ... }
  /// }
  /// ```
  static Future<Map<String, dynamic>> loginUser({
    required String username,
    required String password,
  }) async {
    // Step 1 — obtain a fresh bearer token
    final token = await _getAppToken();

    // Step 2 — call LoginUser with that token
    final uri = Uri.parse('$baseUrl$_loginUserEndpoint');

    final response = await http.post(
      uri,
      headers: _authHeaders(token),
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 && body['status'] == 'success') {
      return body;
    }

    // Use the Arabic or English message from the API if available
    final errorMsg = body['messageEn']?.toString() ??
        body['message']?.toString() ??
        'Login failed';

    throw ApiException(
      statusCode: body['code'] as int? ?? response.statusCode,
      message: errorMsg,
    );
  }
}

/// A simple exception type for API errors.
class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
