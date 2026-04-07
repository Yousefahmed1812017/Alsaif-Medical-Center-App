import 'dart:convert';

/// Represents the logged-in user data returned by the LoginUser API.
class UserModel {
  final int userId;
  final String userType; // EMPLOYEE, DOCTOR, ADMIN
  final String? nameEnglish;
  final String? nameArabic;
  final String? phone;
  final String? email;
  final int? roleId;
  final String? roleName;
  final int? clinicCode;
  final String? clinicNameEnglish;
  final String? clinicNameArabic;
  final int? specialtyCode;
  final String? specialtyNameEnglish;
  final String? specialtyNameArabic;

  const UserModel({
    required this.userId,
    required this.userType,
    this.nameEnglish,
    this.nameArabic,
    this.phone,
    this.email,
    this.roleId,
    this.roleName,
    this.clinicCode,
    this.clinicNameEnglish,
    this.clinicNameArabic,
    this.specialtyCode,
    this.specialtyNameEnglish,
    this.specialtyNameArabic,
  });

  /// Creates a [UserModel] from a JSON map (the `data` field of the API response).
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] as int,
      userType: json['userType'] as String,
      nameEnglish: json['nameEnglish'] as String?,
      nameArabic: json['nameArabic'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      roleId: json['roleId'] as int?,
      roleName: json['roleName'] as String?,
      clinicCode: json['clinicCode'] as int?,
      clinicNameEnglish: json['clinicNameEnglish'] as String?,
      clinicNameArabic: json['clinicNameArabic'] as String?,
      specialtyCode: json['specialtyCode'] as int?,
      specialtyNameEnglish: json['specialtyNameEnglish'] as String?,
      specialtyNameArabic: json['specialtyNameArabic'] as String?,
    );
  }

  /// Serializes to JSON map for local persistence.
  Map<String, dynamic> toJson() => {
        'userId': userId,
        'userType': userType,
        'nameEnglish': nameEnglish,
        'nameArabic': nameArabic,
        'phone': phone,
        'email': email,
        'roleId': roleId,
        'roleName': roleName,
        'clinicCode': clinicCode,
        'clinicNameEnglish': clinicNameEnglish,
        'clinicNameArabic': clinicNameArabic,
        'specialtyCode': specialtyCode,
        'specialtyNameEnglish': specialtyNameEnglish,
        'specialtyNameArabic': specialtyNameArabic,
      };

  /// Serializes to a JSON string for storage.
  String toJsonString() => jsonEncode(toJson());

  /// Deserializes from a JSON string.
  factory UserModel.fromJsonString(String jsonString) {
    return UserModel.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  /// Lowercase role key for routing (e.g. 'employee', 'doctor', 'admin').
  String get roleKey => userType.toLowerCase();

  /// Display name — prefer Arabic if available, otherwise English.
  String displayName({bool preferArabic = false}) {
    if (preferArabic && nameArabic != null && nameArabic!.isNotEmpty) {
      return nameArabic!;
    }
    return nameEnglish ?? email ?? 'User';
  }
}
