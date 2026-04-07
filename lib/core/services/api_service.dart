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
  static const String _closeTimeRequestEndpoint = '/ords/alsaif_crm/CrmFunctions/CloseTimeRequest';
  static const String _getCloseRequestsEndpoint = '/ords/alsaif_crm/CrmFunctions/GetCloseRequests';
  static const String _getCloseRequestDetailsEndpoint = '/ords/alsaif_crm/CrmFunctions/GetCloseRequestDetails';
  static const String _getPatientsEndpoint = '/ords/alsaif_crm/CrmFunctions/GetPatients';

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
  static Future<Map<String, dynamic>> loginUser({
    required String username,
    required String password,
  }) async {
    final token = await _getAppToken();
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

    final errorMsg = body['messageEn']?.toString() ??
        body['message']?.toString() ??
        'Login failed';

    throw ApiException(
      statusCode: body['code'] as int? ?? response.statusCode,
      message: errorMsg,
    );
  }

  // ─── Close Time Request: Create ─────────────────────────────────────
  /// Creates a new close-time request for a doctor.
  static Future<Map<String, dynamic>> createCloseTimeRequest({
    required int clinicId,
    required int docId,
    required String startTime,
    required String endTime,
    required String closeTimeDate,
    required String fullDay,
    required String notes,
    required int createdUserId,
    required String createdUserBy,
  }) async {
    final token = await _getAppToken();
    final uri = Uri.parse('$baseUrl$_closeTimeRequestEndpoint');

    final response = await http.post(
      uri,
      headers: _authHeaders(token),
      body: jsonEncode({
        'ClinicId': clinicId,
        'DocId': docId,
        'StartTime': startTime,
        'EndTime': endTime,
        'CloseTimeDate': closeTimeDate,
        'FullDay': fullDay,
        'Notes': notes,
        'CreatedUserId': createdUserId,
        'CreatedUserBy': createdUserBy,
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 && body['status'] == 'success') {
      return body;
    }

    final errorMsg = body['messageEn']?.toString() ??
        body['message']?.toString() ??
        'Failed to create request';

    throw ApiException(
      statusCode: body['code'] as int? ?? response.statusCode,
      message: errorMsg,
    );
  }

  // ─── Close Time Request: List ───────────────────────────────────────
  /// Fetches all close-time requests for a given doctor.
  static Future<Map<String, dynamic>> getCloseRequests({
    required int docId,
  }) async {
    final token = await _getAppToken();
    final uri = Uri.parse('$baseUrl$_getCloseRequestsEndpoint');

    final response = await http.post(
      uri,
      headers: _authHeaders(token),
      body: jsonEncode({
        'DocId': docId,
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 && body['status'] == 'success') {
      return body;
    }

    final errorMsg = body['messageEn']?.toString() ??
        body['message']?.toString() ??
        'Failed to load requests';

    throw ApiException(
      statusCode: body['code'] as int? ?? response.statusCode,
      message: errorMsg,
    );
  }

  // ─── Close Time Request: Details ────────────────────────────────────
  /// Fetches the details of a single close-time request.
  static Future<Map<String, dynamic>> getCloseRequestDetails({
    required int requestId,
  }) async {
    final token = await _getAppToken();
    final uri = Uri.parse('$baseUrl$_getCloseRequestDetailsEndpoint');

    final response = await http.post(
      uri,
      headers: _authHeaders(token),
      body: jsonEncode({
        'RequestId': requestId,
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 && body['status'] == 'success') {
      return body;
    }

    final errorMsg = body['messageEn']?.toString() ??
        body['message']?.toString() ??
        'Failed to load request details';

    throw ApiException(
      statusCode: body['code'] as int? ?? response.statusCode,
      message: errorMsg,
    );
  }

  // ─── Patients: Search ───────────────────────────────────────────────
  /// Searches for patients using one of the supported search fields.
  /// Pass exactly one non-null parameter per call.
  static Future<Map<String, dynamic>> getPatients({
    String? patientCode,
    String? identityNo,
    String? patientName,
    String? phone,
  }) async {
    final token = await _getAppToken();
    final uri = Uri.parse('$baseUrl$_getPatientsEndpoint');

    // Build body with only the non-null search field
    final Map<String, dynamic> searchBody = {};
    if (patientCode != null && patientCode.isNotEmpty) {
      searchBody['PatientCode'] = patientCode;
    } else if (identityNo != null && identityNo.isNotEmpty) {
      searchBody['IdentityNo'] = identityNo;
    } else if (patientName != null && patientName.isNotEmpty) {
      searchBody['PatientName'] = patientName;
    } else if (phone != null && phone.isNotEmpty) {
      searchBody['Phone'] = phone;
    }

    final response = await http.post(
      uri,
      headers: _authHeaders(token),
      body: jsonEncode(searchBody),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 && body['status'] == 'success') {
      return body;
    }

    final errorMsg = body['messageEn']?.toString() ??
        body['message']?.toString() ??
        'Failed to search patients';

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
