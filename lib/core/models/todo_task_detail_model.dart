import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Detailed task data returned by the GetToDoTaskDetails API.
class ToDoTaskDetailModel {
  final int taskId;
  final String patientNo;
  final String? patientNameEn;
  final String? patientNameAr;
  final String? dateRequest;
  final String? whatToDo;
  final int? receivedBy;
  final String? receivedByName;
  final String status;
  final int? taskRequiredBy;
  final String? taskRequiredByName;
  final String? notes;
  final String priority;

  const ToDoTaskDetailModel({
    required this.taskId,
    required this.patientNo,
    this.patientNameEn,
    this.patientNameAr,
    this.dateRequest,
    this.whatToDo,
    this.receivedBy,
    this.receivedByName,
    required this.status,
    this.taskRequiredBy,
    this.taskRequiredByName,
    this.notes,
    required this.priority,
  });

  factory ToDoTaskDetailModel.fromJson(Map<String, dynamic> json) {
    return ToDoTaskDetailModel(
      taskId: json['taskId'] as int,
      patientNo: json['patientNo']?.toString() ?? '',
      patientNameEn: json['patientNameEn'] as String?,
      patientNameAr: json['patientNameAr'] as String?,
      dateRequest: json['dateRequest'] as String?,
      whatToDo: json['whatToDo']?.toString(),
      receivedBy: json['receivedBy'] as int?,
      receivedByName: json['receivedByName'] as String?,
      status: json['status']?.toString() ?? 'Pending',
      taskRequiredBy: json['taskRequiredBy'] as int?,
      taskRequiredByName: json['taskRequiredByName'] as String?,
      notes: json['notes'] as String?,
      priority: json['priority']?.toString() ?? 'Normal',
    );
  }

  /// Patient display name based on locale.
  String patientName({bool isArabic = false}) {
    if (isArabic && patientNameAr != null && patientNameAr!.isNotEmpty) {
      return patientNameAr!;
    }
    return patientNameEn ?? 'Patient #$patientNo';
  }

  // ─── Priority helpers ────────────────────────────────────────────────

  Color get priorityColor {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return AppColors.error;
      case 'high':
        return AppColors.warning;
      case 'normal':
      default:
        return AppColors.info;
    }
  }

  Color get priorityBgColor {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return AppColors.errorSoft;
      case 'high':
        return AppColors.warningSoft;
      case 'normal':
      default:
        return AppColors.infoSoft;
    }
  }

  String priorityLabel({bool isArabic = false}) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return isArabic ? 'عاجل' : 'Urgent';
      case 'high':
        return isArabic ? 'مرتفع' : 'High';
      case 'normal':
      default:
        return isArabic ? 'عادي' : 'Normal';
    }
  }

  // ─── Status helpers ──────────────────────────────────────────────────

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'done':
        return AppColors.success;
      case 'in progress':
        return AppColors.info;
      case 'pending':
      default:
        return AppColors.warning;
    }
  }

  Color get statusBgColor {
    switch (status.toLowerCase()) {
      case 'done':
        return AppColors.successSoft;
      case 'in progress':
        return AppColors.infoSoft;
      case 'pending':
      default:
        return AppColors.warningSoft;
    }
  }

  String statusLabel({bool isArabic = false}) {
    switch (status.toLowerCase()) {
      case 'done':
        return isArabic ? 'مكتمل' : 'Done';
      case 'in progress':
        return isArabic ? 'قيد التنفيذ' : 'In Progress';
      case 'pending':
      default:
        return isArabic ? 'قيد الانتظار' : 'Pending';
    }
  }
}
