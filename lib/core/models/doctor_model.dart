/// Represents a doctor returned by the GetDoctors API.
class DoctorModel {
  final int docId;
  final String? nameEn;
  final String? nameAr;
  final String? clinicId;
  final String? clinicNameEn;
  final String? clinicNameAr;
  final String? specialtyEn;
  final String? specialtyAr;
  final String? phone;

  const DoctorModel({
    required this.docId,
    this.nameEn,
    this.nameAr,
    this.clinicId,
    this.clinicNameEn,
    this.clinicNameAr,
    this.specialtyEn,
    this.specialtyAr,
    this.phone,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      docId: _parseInt(json['doctorId'] ?? json['docId']) ?? 0,
      nameEn: _str(json['doctorNameEn'] ?? json['nameEn'] ?? json['nameEnglish']),
      nameAr: _str(json['doctorNameAr'] ?? json['nameAr'] ?? json['nameArabic']),
      clinicId: json['clinicId']?.toString(),
      clinicNameEn: _str(json['clinicNameEn'] ?? json['clinicNameEnglish']),
      clinicNameAr: _str(json['clinicNameAr'] ?? json['clinicNameArabic']),
      specialtyEn: _str(json['specialtyNameEn'] ?? json['specialtyEn']),
      specialtyAr: _str(json['specialtyNameAr'] ?? json['specialtyAr']),
      phone: json['phone']?.toString(),
    );
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  /// Safely convert dynamic to non-empty String or null.
  static String? _str(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  /// Display name based on current language.
  String displayName({bool isArabic = false}) {
    if (isArabic && nameAr != null && nameAr!.isNotEmpty) {
      return nameAr!;
    }
    return nameEn ?? nameAr ?? 'Doctor #$docId';
  }

  /// Display clinic name based on current language.
  String displayClinicName({bool isArabic = false}) {
    if (isArabic && clinicNameAr != null && clinicNameAr!.isNotEmpty) {
      return clinicNameAr!;
    }
    return clinicNameEn ?? clinicNameAr ?? '';
  }

  /// Display specialty based on current language.
  String displaySpecialty({bool isArabic = false}) {
    if (isArabic && specialtyAr != null && specialtyAr!.isNotEmpty) {
      return specialtyAr!;
    }
    return specialtyEn ?? specialtyAr ?? '';
  }
}
