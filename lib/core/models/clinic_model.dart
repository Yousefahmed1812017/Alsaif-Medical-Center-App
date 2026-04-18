/// Represents a clinic returned by the GetClinics API.
class ClinicModel {
  final String clinicId;
  final String? clinicNameEn;
  final String? clinicNameAr;

  const ClinicModel({
    required this.clinicId,
    this.clinicNameEn,
    this.clinicNameAr,
  });

  factory ClinicModel.fromJson(Map<String, dynamic> json) {
    return ClinicModel(
      clinicId: json['clinicId']?.toString() ?? '',
      clinicNameEn: json['clinicNameEn']?.toString(),
      clinicNameAr: json['clinicNameAr']?.toString(),
    );
  }

  /// Display name — prefer Arabic if requested, fallback to English.
  String displayName({bool isArabic = false}) {
    if (isArabic && clinicNameAr != null && clinicNameAr!.isNotEmpty) {
      return clinicNameAr!;
    }
    return clinicNameEn ?? 'Clinic #$clinicId';
  }
}
