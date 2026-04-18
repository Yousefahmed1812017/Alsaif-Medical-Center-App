/// Represents a single time slot from the GetDoctorTimeSlots API.
class TimeSlotModel {
  final int period;
  final String time;
  final String time12hr;
  final String time12hrAr;
  final String status;
  final bool isAvailable;

  const TimeSlotModel({
    required this.period,
    required this.time,
    required this.time12hr,
    required this.time12hrAr,
    required this.status,
    required this.isAvailable,
  });

  factory TimeSlotModel.fromJson(Map<String, dynamic> json) {
    return TimeSlotModel(
      period: json['period'] as int? ?? 0,
      time: json['time']?.toString() ?? '',
      time12hr: json['time12hr']?.toString() ?? '',
      time12hrAr: json['time12hrAr']?.toString() ?? '',
      status: json['status']?.toString() ?? 'RESERVED',
      isAvailable: json['isAvailable'] == true,
    );
  }

  /// Display-friendly time based on locale.
  String displayTime({bool isArabic = false}) {
    return isArabic ? time12hrAr : time12hr;
  }
}
