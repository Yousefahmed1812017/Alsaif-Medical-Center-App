import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/models/clinic_model.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_loading_state.dart';
import '../../../../core/widgets/app_error_state.dart';

/// Step 1 — select a clinic from available clinics.
class ClinicPicker extends StatefulWidget {
  const ClinicPicker({
    super.key,
    required this.isArabic,
    required this.onClinicSelected,
  });

  final bool isArabic;
  final ValueChanged<ClinicModel> onClinicSelected;

  @override
  State<ClinicPicker> createState() => _ClinicPickerState();
}

class _ClinicPickerState extends State<ClinicPicker> {
  List<ClinicModel> _clinics = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadClinics();
  }

  Future<void> _loadClinics() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.getClinics();
      final data = response['data'] as List<dynamic>? ?? [];
      setState(() {
        _clinics = data
            .map((e) => ClinicModel.fromJson(e as Map<String, dynamic>))
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return AppLoadingState(
        message: widget.isArabic ? 'جاري تحميل العيادات...' : 'Loading clinics...',
      );
    }

    if (_error != null) {
      return AppErrorState(
        title: widget.isArabic ? 'خطأ' : 'Error',
        message: _error!,
        onRetry: _loadClinics,
      );
    }

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
                  child: FaIcon(FontAwesomeIcons.hospital,
                      size: 18, color: AppColors.primary500),
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isArabic ? 'اختر العيادة' : 'Select Clinic',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.headingText,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.isArabic
                          ? 'اختر قسم العيادة للمتابعة'
                          : 'Choose a clinic department to continue',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.mutedText,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.s24),

          // Clinic Cards
          Expanded(
            child: ListView.separated(
              itemCount: _clinics.length,
              separatorBuilder: (context2, index2) =>
                  const SizedBox(height: AppSpacing.s12),
              itemBuilder: (context, index) {
                final clinic = _clinics[index];
                return _ClinicCard(
                  clinic: clinic,
                  isArabic: widget.isArabic,
                  onTap: () => widget.onClinicSelected(clinic),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ClinicCard extends StatelessWidget {
  const _ClinicCard({
    required this.clinic,
    required this.isArabic,
    required this.onTap,
  });

  final ClinicModel clinic;
  final bool isArabic;
  final VoidCallback onTap;

  dynamic _clinicIcon(String id) {
    switch (id.trim()) {
      case '03.00':
        return FontAwesomeIcons.hand; // Dermatology
      case '11.00':
        return FontAwesomeIcons.eye; // Ophthalmology
      case '22.00':
        return FontAwesomeIcons.tooth; // Dental
      default:
        return FontAwesomeIcons.hospitalUser;
    }
  }

  @override
  Widget build(BuildContext context) {
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
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary500.withAlpha(20),
                      AppColors.primary500.withAlpha(8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.r12),
                ),
                child: Center(
                  child: FaIcon(
                    _clinicIcon(clinic.clinicId),
                    size: 20,
                    color: AppColors.primary500,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s16),
              Expanded(
                child: Text(
                  clinic.displayName(isArabic: isArabic),
                  style:
                      Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.headingText,
                          ),
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
}
