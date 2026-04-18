import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/models/doctor_model.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_loading_state.dart';
import '../../../../core/widgets/app_error_state.dart';

/// Step 2 — select a doctor, optionally filtered by clinic.
class DoctorPicker extends StatefulWidget {
  const DoctorPicker({
    super.key,
    required this.isArabic,
    required this.onDoctorSelected,
    this.clinicId,
  });

  final bool isArabic;
  final String? clinicId;
  final ValueChanged<DoctorModel> onDoctorSelected;

  @override
  State<DoctorPicker> createState() => _DoctorPickerState();
}

class _DoctorPickerState extends State<DoctorPicker> {
  List<DoctorModel> _doctors = [];
  bool _isLoading = true;
  String? _error;
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadDoctors({String? searchName}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.getDoctors(
        clinicId: widget.clinicId,
        searchName: searchName,
      );
      final data = response['data'] as List<dynamic>? ?? [];
      setState(() {
        _doctors = data
            .map((e) => DoctorModel.fromJson(e as Map<String, dynamic>))
            .toList();
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _loadDoctors(searchName: query.isEmpty ? null : query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary500.withAlpha(20),
                  borderRadius: BorderRadius.circular(AppRadius.r12),
                ),
                child: const Center(
                  child: FaIcon(FontAwesomeIcons.userDoctor,
                      size: 18, color: AppColors.primary500),
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isArabic ? 'اختر الطبيب' : 'Select Doctor',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.headingText,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.isArabic
                          ? 'ابحث واختر الطبيب المطلوب'
                          : 'Search and select the desired doctor',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.mutedText,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.s16),

          // Search Field
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.r12),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: widget.isArabic ? 'ابحث باسم الطبيب...' : 'Search by doctor name...',
                hintStyle: const TextStyle(color: AppColors.mutedText, fontSize: 14),
                prefixIcon: const Icon(Icons.search,
                    color: AppColors.mutedText, size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s16,
                  vertical: AppSpacing.s12,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.s16),

          // Results
          Expanded(
            child: _isLoading
                ? AppLoadingState(
                    message: widget.isArabic
                        ? 'جاري تحميل الأطباء...'
                        : 'Loading doctors...',
                  )
                : _error != null
                    ? AppErrorState(
                        title: widget.isArabic ? 'خطأ' : 'Error',
                        message: _error!,
                        onRetry: _loadDoctors,
                      )
                    : _doctors.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(FontAwesomeIcons.userDoctor,
                                    size: 40, color: AppColors.mutedText.withAlpha(80)),
                                const SizedBox(height: AppSpacing.s12),
                                Text(
                                  widget.isArabic
                                      ? 'لا يوجد أطباء'
                                      : 'No doctors found',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: AppColors.mutedText),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: _doctors.length,
                            separatorBuilder: (context2, index2) =>
                                const SizedBox(height: AppSpacing.s12),
                            itemBuilder: (context, index) {
                              final doctor = _doctors[index];
                              return _DoctorCard(
                                doctor: doctor,
                                isArabic: widget.isArabic,
                                onTap: () =>
                                    widget.onDoctorSelected(doctor),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({
    required this.doctor,
    required this.isArabic,
    required this.onTap,
  });

  final DoctorModel doctor;
  final bool isArabic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = doctor.displayName(isArabic: isArabic);
    final specialty = doctor.displaySpecialty(isArabic: isArabic);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.r16),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.s16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.r16),
            border: Border.all(color: AppColors.border.withAlpha(120)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary500.withAlpha(6),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary500.withAlpha(30),
                      AppColors.primary300.withAlpha(20),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.r12),
                ),
                child: Center(
                  child: Text(
                    _getInitials(name),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary500,
                        ),
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.s12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.headingText,
                          ),
                    ),
                    if (specialty.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const FaIcon(FontAwesomeIcons.stethoscope,
                              size: 11, color: AppColors.mutedText),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              specialty,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.mutedText),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const FaIcon(FontAwesomeIcons.chevronRight,
                  size: 14, color: AppColors.mutedText),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    // Remove prefix like "د." or "DR."
    final cleanName = name
        .replaceAll(RegExp(r'^(د\.|DR\.|OP\.|أ\.)\s*', caseSensitive: false), '')
        .trim();
    final parts = cleanName.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }
}
