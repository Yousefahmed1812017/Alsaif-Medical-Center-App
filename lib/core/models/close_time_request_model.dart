/// Represents a Close Time Request returned by the API.
class CloseTimeRequestModel {
  final int requestId;
  final int clinicId;
  final int docId;
  final String? startTime;
  final String? endTime;
  final String closeTimeDate;
  final String fullDay; // "Y" or "N"
  final String requestStatus; // "P" = Pending, "A" = Approved, "R" = Rejected
  final String? notes;
  final int? createdUserId;
  final String? createdBy;
  final String? createdDate;

  const CloseTimeRequestModel({
    required this.requestId,
    required this.clinicId,
    required this.docId,
    this.startTime,
    this.endTime,
    required this.closeTimeDate,
    required this.fullDay,
    required this.requestStatus,
    this.notes,
    this.createdUserId,
    this.createdBy,
    this.createdDate,
  });

  factory CloseTimeRequestModel.fromJson(Map<String, dynamic> json) {
    return CloseTimeRequestModel(
      requestId: json['requestId'] as int,
      clinicId: json['clinicId'] as int,
      docId: json['docId'] as int,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      closeTimeDate: json['closeTimeDate'] as String,
      fullDay: json['fullDay'] as String,
      requestStatus: json['requestStatus'] as String,
      notes: json['notes'] as String?,
      createdUserId: json['createdUserId'] as int?,
      createdBy: json['createdBy'] as String?,
      createdDate: json['createdDate'] as String?,
    );
  }

  /// Whether this is a full-day closure.
  bool get isFullDay => fullDay.toUpperCase() == 'Y';

  /// Human-readable status label (English).
  String get statusLabelEn {
    switch (requestStatus.toUpperCase()) {
      case 'A':
        return 'Approved';
      case 'R':
        return 'Rejected';
      case 'P':
      default:
        return 'Pending';
    }
  }

  /// Human-readable status label (Arabic).
  String get statusLabelAr {
    switch (requestStatus.toUpperCase()) {
      case 'A':
        return 'مقبول';
      case 'R':
        return 'مرفوض';
      case 'P':
      default:
        return 'قيد المراجعة';
    }
  }
}
