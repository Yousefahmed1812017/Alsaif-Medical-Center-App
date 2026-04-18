/// Lightweight user model returned by the GetUsers API.
/// Used for staff selection when assigning tasks.
class StaffUserModel {
  final int userId;
  final String? nameEnglish;
  final String? nameArabic;
  final String? phone;
  final String? userType;
  final int? roleId;
  final int? clinicCode;

  const StaffUserModel({
    required this.userId,
    this.nameEnglish,
    this.nameArabic,
    this.phone,
    this.userType,
    this.roleId,
    this.clinicCode,
  });

  factory StaffUserModel.fromJson(Map<String, dynamic> json) {
    return StaffUserModel(
      userId: _parseInt(json['userId']) ?? 0,
      nameEnglish: json['nameEnglish']?.toString(),
      nameArabic: json['nameArabic']?.toString(),
      phone: json['phone']?.toString(),
      userType: json['userType']?.toString(),
      roleId: _parseInt(json['roleId']),
      clinicCode: _parseInt(json['clinicCode']),
    );
  }

  /// Safely parse dynamic to int (handles String, int, and null).
  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  /// Display name — prefer Arabic if requested, fallback to English.
  String displayName({bool isArabic = false}) {
    if (isArabic && nameArabic != null && nameArabic!.isNotEmpty) {
      return nameArabic!;
    }
    return nameEnglish ?? 'User #$userId';
  }
}
