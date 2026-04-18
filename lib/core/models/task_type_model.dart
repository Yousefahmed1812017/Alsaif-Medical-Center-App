/// Represents a task type returned by the GetTaskTypes API.
class TaskTypeModel {
  final int id;
  final String nameEnglish;
  final String nameArabic;

  const TaskTypeModel({
    required this.id,
    required this.nameEnglish,
    required this.nameArabic,
  });

  factory TaskTypeModel.fromJson(Map<String, dynamic> json) {
    return TaskTypeModel(
      id: json['id'] as int,
      nameEnglish: json['nameEnglish'] as String,
      nameArabic: json['nameArabic'] as String,
    );
  }

  /// Display name based on locale.
  String displayName({bool isArabic = false}) =>
      isArabic ? nameArabic : nameEnglish;
}
