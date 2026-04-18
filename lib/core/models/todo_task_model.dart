import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Represents a task item from the GetToDoTasks API list response.
class ToDoTaskModel {
  final int taskId;
  final String patientNo;
  final String? patientEnglishName;
  final String? patientArabicName;
  final String? dateRequest;
  final String? whatToDo;
  final String? receivedBy;
  final String status;
  final String? taskRequiredBy;
  final String? notes;
  final String priority;

  const ToDoTaskModel({
    required this.taskId,
    required this.patientNo,
    this.patientEnglishName,
    this.patientArabicName,
    this.dateRequest,
    this.whatToDo,
    this.receivedBy,
    required this.status,
    this.taskRequiredBy,
    this.notes,
    required this.priority,
  });

  factory ToDoTaskModel.fromJson(Map<String, dynamic> json) {
    return ToDoTaskModel(
      taskId: json['taskId'] as int,
      patientNo: json['patientNo']?.toString() ?? '',
      patientEnglishName: json['patientEnglishName'] as String?,
      patientArabicName: json['patientArabicName'] as String?,
      dateRequest: json['dateRequest'] as String?,
      whatToDo: json['whatToDo']?.toString(),
      receivedBy: json['receivedBy']?.toString(),
      status: json['status']?.toString() ?? 'Pending',
      taskRequiredBy: json['taskRequiredBy']?.toString(),
      notes: json['notes'] as String?,
      priority: json['priority']?.toString() ?? 'Normal',
    );
  }

  /// Patient display name based on locale.
  String patientName({bool isArabic = false}) {
    if (isArabic && patientArabicName != null && patientArabicName!.isNotEmpty) {
      return patientArabicName!;
    }
    return patientEnglishName ?? 'Patient #$patientNo';
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

  String priorityLabelAr() {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return 'عاجل';
      case 'high':
        return 'مرتفع';
      case 'normal':
      default:
        return 'عادي';
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

  String statusLabelAr() {
    switch (status.toLowerCase()) {
      case 'done':
        return 'مكتمل';
      case 'in progress':
        return 'قيد التنفيذ';
      case 'pending':
      default:
        return 'قيد الانتظار';
    }
  }
}
