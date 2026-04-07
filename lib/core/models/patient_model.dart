/// Represents a patient record returned by the GetPatients API.
class PatientModel {
  final String? patientCode;
  final String? patientName;
  final String? patientNameEn;
  final String? identityNo;
  final String? phone;
  final String? mobile;
  final String? gender;
  final String? birthDate;
  final String? nationality;
  final String? email;
  final String? bloodType;
  final String? maritalStatus;
  final String? city;
  final String? address;
  final String? insuranceCompany;
  final String? insurancePolicyNo;

  const PatientModel({
    this.patientCode,
    this.patientName,
    this.patientNameEn,
    this.identityNo,
    this.phone,
    this.mobile,
    this.gender,
    this.birthDate,
    this.nationality,
    this.email,
    this.bloodType,
    this.maritalStatus,
    this.city,
    this.address,
    this.insuranceCompany,
    this.insurancePolicyNo,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      patientCode: _str(json['patientCode'] ?? json['PATIENT_CODE'] ?? json['PatientCode']),
      patientName: _str(json['patientName'] ?? json['PATIENT_NAME'] ?? json['PatientName']),
      patientNameEn: _str(json['patientNameEn'] ?? json['PATIENT_NAME_EN'] ?? json['PatientNameEn']),
      identityNo: _str(json['identityNo'] ?? json['IDENTITY_NO'] ?? json['IdentityNo']),
      phone: _str(json['phone'] ?? json['PHONE'] ?? json['Phone']),
      mobile: _str(json['mobile'] ?? json['MOBILE'] ?? json['Mobile']),
      gender: _str(json['gender'] ?? json['GENDER'] ?? json['Gender']),
      birthDate: _str(json['birthDate'] ?? json['BIRTH_DATE'] ?? json['BirthDate']),
      nationality: _str(json['nationality'] ?? json['NATIONALITY'] ?? json['Nationality']),
      email: _str(json['email'] ?? json['EMAIL'] ?? json['Email']),
      bloodType: _str(json['bloodType'] ?? json['BLOOD_TYPE'] ?? json['BloodType']),
      maritalStatus: _str(json['maritalStatus'] ?? json['MARITAL_STATUS'] ?? json['MaritalStatus']),
      city: _str(json['city'] ?? json['CITY'] ?? json['City']),
      address: _str(json['address'] ?? json['ADDRESS'] ?? json['Address']),
      insuranceCompany: _str(json['insuranceCompany'] ?? json['INSURANCE_COMPANY'] ?? json['InsuranceCompany']),
      insurancePolicyNo: _str(json['insurancePolicyNo'] ?? json['INSURANCE_POLICY_NO'] ?? json['InsurancePolicyNo']),
    );
  }

  /// Display name — prefers Arabic, falls back to English, then MR# code.
  String get displayName {
    if (patientName != null && patientName!.isNotEmpty) return patientName!;
    if (patientNameEn != null && patientNameEn!.isNotEmpty) return patientNameEn!;
    return 'MR# ${patientCode ?? '—'}';
  }

  /// Safely convert dynamic to String or null.
  static String? _str(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }
}
