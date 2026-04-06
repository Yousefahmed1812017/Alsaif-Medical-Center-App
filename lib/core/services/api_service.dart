import 'dart:convert';
import 'package:http/http.dart' as http;

/// Centralized API configuration and HTTP client for the Alsaif Medical app.
class ApiService {
  ApiService._();

  // ─── Base URL ───────────────────────────────────────────────────────
  static const String baseUrl = 'https://clinicintouch.com';

  // ─── Endpoints ──────────────────────────────────────────────────────
  static const String _authenticateEndpoint = '/ords/alsaif_crm/oauth/authenticate';

  // ─── Headers ────────────────────────────────────────────────────────
  static Map<String, String> get _defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Map<String, String> authHeaders(String token) => {
        ..._defaultHeaders,
        'Authorization': 'Bearer $token',
      };

  // ─── Authentication ─────────────────────────────────────────────────
  /// Calls the authenticate endpoint and returns the parsed JSON response.
  ///
  /// On success the response contains:
  /// ```json
  /// { "status": "success", "message": "...", "client": "...", "token": "..." }
  /// ```
  ///
  /// Throws [ApiException] on HTTP errors or unexpected responses.
  static Future<Map<String, dynamic>> authenticate({
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl$_authenticateEndpoint');

    final response = await http.post(
      uri,
      headers: _defaultHeaders,
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 && body['status'] == 'success') {
      return body;
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: body['message']?.toString() ?? 'Authentication failed',
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
