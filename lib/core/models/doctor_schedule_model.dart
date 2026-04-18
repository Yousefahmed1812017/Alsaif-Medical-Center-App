/// Represents a single day from the GetDoctorSchedule API.
class DoctorScheduleModel {
  final int id;
  final int docId;
  final String date;
  final bool isWeekend;
  final String? startTime;
  final String? endTime;
  final String? startTime2;
  final String? endTime2;
  final String? startTime3;
  final String? endTime3;
  final String? startTime4;
  final String? endTime4;
  final String? duration;
  final int? mId;

  const DoctorScheduleModel({
    required this.id,
    required this.docId,
    required this.date,
    required this.isWeekend,
    this.startTime,
    this.endTime,
    this.startTime2,
    this.endTime2,
    this.startTime3,
    this.endTime3,
    this.startTime4,
    this.endTime4,
    this.duration,
    this.mId,
  });

  factory DoctorScheduleModel.fromJson(Map<String, dynamic> json) {
    return DoctorScheduleModel(
      id: _parseInt(json['id']) ?? 0,
      docId: _parseInt(json['docId']) ?? 0,
      date: json['date']?.toString() ?? '',
      isWeekend: json['isWeekend'] == true,
      startTime: json['startTime']?.toString(),
      endTime: json['endTime']?.toString(),
      startTime2: json['startTime2']?.toString(),
      endTime2: json['endTime2']?.toString(),
      startTime3: json['startTime3']?.toString(),
      endTime3: json['endTime3']?.toString(),
      startTime4: json['startTime4']?.toString(),
      endTime4: json['endTime4']?.toString(),
      duration: json['duration']?.toString(),
      mId: _parseInt(json['mId']),
    );
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  /// Whether this day is available for booking (not weekend and has schedule).
  bool get isAvailable => !isWeekend && startTime != null;

  /// Parse the date string into a DateTime.
  DateTime get dateTime => DateTime.parse(date);
}
