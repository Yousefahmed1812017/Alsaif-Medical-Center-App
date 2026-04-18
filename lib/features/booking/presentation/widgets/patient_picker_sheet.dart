import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/models/patient_model.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_loading_state.dart';
import '../../../../core/widgets/app_error_state.dart';

/// Step 5 — search and select a patient for the appointment.
class PatientPickerSheet extends StatefulWidget {
  const PatientPickerSheet({
    super.key,
    required this.isArabic,
    required this.onPatientSelected,
    required this.onBack,
  });

  final bool isArabic;
  final ValueChanged<PatientModel> onPatientSelected;
  final VoidCallback onBack;

  @override
  State<PatientPickerSheet> createState() => _PatientPickerSheetState();
}

class _PatientPickerSheetState extends State<PatientPickerSheet> {
  List<PatientModel> _patients = [];
  bool _isLoading = true;
  String? _error;
  final _searchController = TextEditingController();
  Timer? _debounce;

  // Search type
  String _searchField = 'name'; // name, code, phone, identity

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadPatients({String? query}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.getPatients(
        patientName: _searchField == 'name' ? query : null,
        patientCode: _searchField == 'code' ? query : null,
        phone: _searchField == 'phone' ? query : null,
        identityNo: _searchField == 'identity' ? query : null,
      );

      final data = response['data'] as List<dynamic>? ?? [];
      setState(() {
        _patients = data
            .map((e) => PatientModel.fromJson(e as Map<String, dynamic>))
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
      _loadPatients(query: query.isEmpty ? null : query);
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
                  child: FaIcon(FontAwesomeIcons.userInjured,
                      size: 18, color: AppColors.primary500),
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isArabic ? 'اختر المريض' : 'Select Patient',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.headingText,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.isArabic
                          ? 'ابحث واختر المريض للحجز'
                          : 'Search and select a patient for the booking',
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

          // Search Type Chips
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _SearchChip(
                  label: widget.isArabic ? 'الاسم' : 'Name',
                  isSelected: _searchField == 'name',
                  onTap: () => setState(() => _searchField = 'name'),
                ),
                const SizedBox(width: AppSpacing.s8),
                _SearchChip(
                  label: widget.isArabic ? 'رقم الملف' : 'MR#',
                  isSelected: _searchField == 'code',
                  onTap: () => setState(() => _searchField = 'code'),
                ),
                const SizedBox(width: AppSpacing.s8),
                _SearchChip(
                  label: widget.isArabic ? 'الهاتف' : 'Phone',
                  isSelected: _searchField == 'phone',
                  onTap: () => setState(() => _searchField = 'phone'),
                ),
                const SizedBox(width: AppSpacing.s8),
                _SearchChip(
                  label: widget.isArabic ? 'الهوية' : 'Identity',
                  isSelected: _searchField == 'identity',
                  onTap: () => setState(() => _searchField = 'identity'),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.s12),

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
                hintText: widget.isArabic ? 'ابحث عن مريض...' : 'Search patient...',
                hintStyle: TextStyle(color: AppColors.mutedText, fontSize: 14),
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
                        ? 'جاري البحث...'
                        : 'Searching...',
                  )
                : _error != null
                    ? AppErrorState(
                        title: widget.isArabic ? 'خطأ' : 'Error',
                        message: _error!,
                        onRetry: _loadPatients,
                      )
                    : _patients.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(FontAwesomeIcons.userInjured,
                                    size: 40,
                                    color: AppColors.mutedText.withAlpha(80)),
                                const SizedBox(height: AppSpacing.s12),
                                Text(
                                  widget.isArabic
                                      ? 'لا يوجد نتائج'
                                      : 'No patients found',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: AppColors.mutedText),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: _patients.length,
                            separatorBuilder: (context2, index2) =>
                                const SizedBox(height: AppSpacing.s8),
                            itemBuilder: (context, index) {
                              final patient = _patients[index];
                              return _PatientCard(
                                patient: patient,
                                isArabic: widget.isArabic,
                                onTap: () =>
                                    widget.onPatientSelected(patient),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

// ─── Search Chip ───────────────────────────────────────────────────────────

class _SearchChip extends StatelessWidget {
  const _SearchChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary500 : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary500 : AppColors.border,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.white : AppColors.bodyText,
                  fontSize: 12,
                ),
          ),
        ),
      ),
    );
  }
}

// ─── Patient Card ──────────────────────────────────────────────────────────

class _PatientCard extends StatelessWidget {
  const _PatientCard({
    required this.patient,
    required this.isArabic,
    required this.onTap,
  });

  final PatientModel patient;
  final bool isArabic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = isArabic
        ? (patient.patientName ?? patient.patientNameEn ?? '')
        : (patient.patientNameEn ?? patient.patientName ?? '');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.r12),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.s12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.r12),
            border: Border.all(color: AppColors.border.withAlpha(120)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary500.withAlpha(15),
                  borderRadius: BorderRadius.circular(AppRadius.r8),
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary500,
                        ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isEmpty ? 'Unknown' : name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.headingText,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          'MR#: ${patient.patientCode}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.mutedText,
                                fontSize: 11,
                              ),
                        ),
                        if (patient.phone != null &&
                            patient.phone!.isNotEmpty) ...[
                          const SizedBox(width: AppSpacing.s8),
                          Text(
                            patient.phone!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppColors.mutedText,
                                  fontSize: 11,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const FaIcon(FontAwesomeIcons.chevronRight,
                  size: 12, color: AppColors.mutedText),
            ],
          ),
        ),
      ),
    );
  }
}
