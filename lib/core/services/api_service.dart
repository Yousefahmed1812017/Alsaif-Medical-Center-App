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

  // To-Do Tasks endpoints
  static const String _getTaskTypesEndpoint = '/ords/alsaif_crm/CrmFunctions/GetTaskTypes';
  static const String _addToDoTaskEndpoint = '/ords/alsaif_crm/CrmFunctions/AddToDoTask';
  static const String _getToDoTasksEndpoint = '/ords/alsaif_crm/CrmFunctions/GetToDoTasks';
  static const String _getToDoTaskDetailsEndpoint = '/ords/alsaif_crm/CrmFunctions/GetToDoTaskDetails';
  static const String _getUsersEndpoint = '/ords/alsaif_crm/CrmFunctions/GetUsers';

  // Booking / Appointment endpoints
  static const String _getClinicsEndpoint = '/ords/alsaif_crm/CrmFunctions/GetClinics';
  static const String _getDoctorsEndpoint = '/ords/alsaif_crm/CrmFunctions/GetDoctors';
  static const String _getDoctorScheduleEndpoint = '/ords/alsaif_crm/CrmFunctions/GetDoctorSchedule';
  static const String _getDoctorTimeSlotsEndpoint = '/ords/alsaif_crm/CrmFunctions/GetDoctorTimeSlots';
  static const String _createAppointmentEndpoint = '/ords/alsaif_crm/CrmFunctions/CreateAppointment';

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

  // ═══════════════════════════════════════════════════════════════════════
  // ─── To-Do Tasks APIs ──────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════════

  // ─── Task Types: List ───────────────────────────────────────────────
  /// Fetches all available task types. Returns the full response body.
  static Future<Map<String, dynamic>> getTaskTypes() async {
    final token = await _getAppToken();
    final uri = Uri.parse('$baseUrl$_getTaskTypesEndpoint');

    final response = await http.get(
      uri,
      headers: _authHeaders(token),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 && body['status'] == 'success') {
      return body;
    }

    final errorMsg = body['messageEn']?.toString() ??
        body['message']?.toString() ??
        'Failed to load task types';

    throw ApiException(
      statusCode: body['code'] as int? ?? response.statusCode,
      message: errorMsg,
    );
  }

  // ─── To-Do Task: Create ─────────────────────────────────────────────
  /// Creates a new to-do task.
  static Future<Map<String, dynamic>> addToDoTask({
    required String patientNo,
    required int whatToDo,
    required int receivedBy,
    required int taskRequiredBy,
    String? notes,
    String priority = 'Normal',
  }) async {
    final token = await _getAppToken();
    final uri = Uri.parse('$baseUrl$_addToDoTaskEndpoint');

    final response = await http.post(
      uri,
      headers: _authHeaders(token),
      body: jsonEncode({
        'PatientNo': patientNo,
        'WhatToDo': whatToDo,
        'ReceivedBy': receivedBy,
        'TaskRequiredBy': taskRequiredBy,
        'Notes': notes ?? '',
        'Priority': priority,
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 && body['status'] == 'success') {
      return body;
    }

    final errorMsg = body['messageEn']?.toString() ??
        body['message']?.toString() ??
        'Failed to create task';

    throw ApiException(
      statusCode: body['code'] as int? ?? response.statusCode,
      message: errorMsg,
    );
  }

  // ─── To-Do Tasks: List with Filters ─────────────────────────────────
  /// Fetches tasks with optional search/filter parameters.
  static Future<Map<String, dynamic>> getToDoTasks({
    String? patientNo,
    String? patientName,
    String? status,
    String? priority,
    int? receivedBy,
    int? taskRequiredBy,
  }) async {
    final token = await _getAppToken();
    final uri = Uri.parse('$baseUrl$_getToDoTasksEndpoint');

    final response = await http.post(
      uri,
      headers: _authHeaders(token),
      body: jsonEncode({
        'PatientNo': patientNo,
        'PatientName': patientName,
        'Status': status,
        'Priority': priority,
        'ReceivedBy': receivedBy,
        'TaskRequiredBy': taskRequiredBy,
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 && body['status'] == 'success') {
      return body;
    }

    final errorMsg = body['messageEn']?.toString() ??
        body['message']?.toString() ??
        'Failed to load tasks';

    throw ApiException(
      statusCode: body['code'] as int? ?? response.statusCode,
      message: errorMsg,
    );
  }

  // ─── To-Do Task: Details ────────────────────────────────────────────
  /// Fetches details of a single task by its ID.
  static Future<Map<String, dynamic>> getToDoTaskDetails({
    required int taskId,
  }) async {
    final token = await _getAppToken();
    final uri = Uri.parse('$baseUrl$_getToDoTaskDetailsEndpoint');

    final response = await http.post(
      uri,
      headers: _authHeaders(token),
      body: jsonEncode({
        'TaskId': taskId,
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 && body['status'] == 'success') {
      return body;
    }

    final errorMsg = body['messageEn']?.toString() ??
        body['message']?.toString() ??
        'Failed to load task details';

    throw ApiException(
      statusCode: body['code'] as int? ?? response.statusCode,
      message: errorMsg,
    );
  }

  // ─── Users: Search Staff ────────────────────────────────────────────
  /// Fetches staff users with optional search parameters.
  static Future<Map<String, dynamic>> getUsers({
    int? userId,
    String? userType,
    int? roleId,
    int? clinicCode,
    String? phone,
    String? searchName,
  }) async {
    final token = await _getAppToken();
    final uri = Uri.parse('$baseUrl$_getUsersEndpoint');

    final response = await http.post(
      uri,
      headers: _authHeaders(token),
      body: jsonEncode({
        'UserId': userId,
        'UserType': userType,
        'RoleId': roleId,
        'ClinicCode': clinicCode,
        'Phone': phone,
        'SearchName': searchName,
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 && body['status'] == 'success') {
      return body;
    }

    final errorMsg = body['messageEn']?.toString() ??
        body['message']?.toString() ??
        'Failed to load users';

    throw ApiException(
      statusCode: body['code'] as int? ?? response.statusCode,
      message: errorMsg,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ─── Booking / Appointment APIs ─────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════════

  // ─── Clinics: List ──────────────────────────────────────────────────
  /// Fetches all available clinics. POST with no body.
  static Future<Map<String, dynamic>> getClinics() async {
    final token = await _getAppToken();
    final uri = Uri.parse('$baseUrl$_getClinicsEndpoint');

    final response = await http.post(
      uri,
      headers: _authHeaders(token),
      body: jsonEncode({}),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 && body['status'] == 'success') {
      return body;
    }

    final errorMsg = body['messageEn']?.toString() ??
        body['message']?.toString() ??
        'Failed to load clinics';

    throw ApiException(
      statusCode: int.tryParse(body['code']?.toString() ?? '') ?? response.statusCode,
      message: errorMsg,
    );
  }

  // ─── Doctors: List / Search ─────────────────────────────────────────
  /// Fetches doctors, optionally filtered by clinic and/or name.
  static Future<Map<String, dynamic>> getDoctors({
    String? clinicId,
    String? searchName,
  }) async {
    final token = await _getAppToken();
    final uri = Uri.parse('$baseUrl$_getDoctorsEndpoint');

    final response = await http.post(
      uri,
      headers: _authHeaders(token),
      body: jsonEncode({
        'ClinicId': clinicId,
        'SearchName': searchName,
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 && body['status'] == 'success') {
      return body;
    }

    final errorMsg = body['messageEn']?.toString() ??
        body['message']?.toString() ??
        'Failed to load doctors';

    throw ApiException(
      statusCode: int.tryParse(body['code']?.toString() ?? '') ?? response.statusCode,
      message: errorMsg,
    );
  }

  // ─── Doctor Schedule: Calendar ──────────────────────────────────────
  /// Fetches a doctor's schedule for a date range.
  static Future<Map<String, dynamic>> getDoctorSchedule({
    required int docId,
    required String fromDate,
    required String toDate,
    String availableOnly = 'false',
  }) async {
    final token = await _getAppToken();
    final uri = Uri.parse('$baseUrl$_getDoctorScheduleEndpoint');

    final response = await http.post(
      uri,
      headers: _authHeaders(token),
      body: jsonEncode({
        'DocId': docId,
        'FromDate': fromDate,
        'ToDate': toDate,
        'AvailableOnly': availableOnly,
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 && body['status'] == 'success') {
      return body;
    }

    final errorMsg = body['messageEn']?.toString() ??
        body['message']?.toString() ??
        'Failed to load schedule';

    throw ApiException(
      statusCode: int.tryParse(body['code']?.toString() ?? '') ?? response.statusCode,
      message: errorMsg,
    );
  }

  // ─── Doctor Time Slots ──────────────────────────────────────────────
  /// Fetches available time slots for a doctor on a specific date.
  static Future<Map<String, dynamic>> getDoctorTimeSlots({
    required int doctorId,
    required String appointmentDate,
  }) async {
    final token = await _getAppToken();
    final uri = Uri.parse('$baseUrl$_getDoctorTimeSlotsEndpoint');

    final response = await http.post(
      uri,
      headers: _authHeaders(token),
      body: jsonEncode({
        'DoctorId': doctorId,
        'AppointmentDate': appointmentDate,
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 && body['status'] == 'success') {
      return body;
    }

    final errorMsg = body['messageEn']?.toString() ??
        body['message']?.toString() ??
        'Failed to load time slots';

    throw ApiException(
      statusCode: int.tryParse(body['code']?.toString() ?? '') ?? response.statusCode,
      message: errorMsg,
    );
  }

  // ─── Create Appointment ─────────────────────────────────────────────
  /// Creates a new appointment booking.
  static Future<Map<String, dynamic>> createAppointment({
    required int docId,
    required String clinicId,
    required int patientId,
    required String reDate,
    required String reTime,
    String source = '1',
    String? notes,
    required String createdBy,
    required int createdByUserId,
  }) async {
    final token = await _getAppToken();
    final uri = Uri.parse('$baseUrl$_createAppointmentEndpoint');

    final response = await http.post(
      uri,
      headers: _authHeaders(token),
      body: jsonEncode({
        'doctorId': docId,
        'ClinicId': clinicId,
        'PatientId': patientId,
        'appointmentDate': reDate,
        'appointmentTime': reTime,
        'Source': source,
        'Notes': notes ?? '',
        'CreatedBy': createdBy,
        'CreatedByUserId': createdByUserId,
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 && body['status'] == 'success') {
      return body;
    }

    final errorMsg = body['messageEn']?.toString() ??
        body['message']?.toString() ??
        'Failed to create appointment';

    throw ApiException(
      statusCode: int.tryParse(body['code']?.toString() ?? '') ?? response.statusCode,
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
