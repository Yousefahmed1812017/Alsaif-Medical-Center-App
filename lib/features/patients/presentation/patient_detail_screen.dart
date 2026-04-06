import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/models/patient_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_app_bar.dart';

/// Displays detailed patient info fetched by MR# code.
class PatientDetailScreen extends StatefulWidget {
  const PatientDetailScreen({super.key, required this.patientCode});

  final String patientCode;

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  PatientModel? _patient;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.getPatients(patientCode: widget.patientCode);
      final data = response['data'];
      if (data is List && data.isNotEmpty) {
        _patient = PatientModel.fromJson(data.first as Map<String, dynamic>);
      } else if (data is Map<String, dynamic>) {
        _patient = PatientModel.fromJson(data);
      }
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppAppBar(
        title: isArabic ? 'ملف المريض' : 'Patient File',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError(isArabic)
              : _patient == null
                  ? _buildNotFound(isArabic)
                  : _buildContent(context, isArabic),
    );
  }

  Widget _buildError(bool isArabic) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(FontAwesomeIcons.circleExclamation, size: 48, color: AppColors.error),
            const SizedBox(height: AppSpacing.s16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.s16),
            OutlinedButton.icon(
              onPressed: _load,
              icon: const FaIcon(FontAwesomeIcons.arrowsRotate, size: 16),
              label: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFound(bool isArabic) {
    return Center(
      child: Text(
        isArabic ? 'لم يتم العثور على المريض' : 'Patient not found',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.mutedText),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isArabic) {
    final p = _patient!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.s24),
      child: Column(
        children: [
          // ── Header Card ──────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.s24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary700,
                  AppColors.primary400,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.r20),
            ),
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withAlpha(60), width: 2),
                  ),
                  child: Center(
                    child: Text(
                      _initials(p.displayName),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s12),
                Text(
                  p.displayName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                  textAlign: TextAlign.center,
                ),
                if (p.patientNameEn != null && p.patientName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    p.patientNameEn!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withAlpha(180),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: AppSpacing.s8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'MR# ${p.patientCode ?? '—'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.s24),

          // ── Information Card ──────────────────────────────────
          _SectionCard(
            title: isArabic ? 'المعلومات الشخصية' : 'Personal Information',
            icon: FontAwesomeIcons.user,
            children: [
              if (p.identityNo != null)
                _InfoRow(
                  label: isArabic ? 'رقم الهوية' : 'Identity No',
                  value: p.identityNo!,
                ),
              if (p.gender != null)
                _InfoRow(
                  label: isArabic ? 'الجنس' : 'Gender',
                  value: p.gender!,
                ),
              if (p.birthDate != null)
                _InfoRow(
                  label: isArabic ? 'تاريخ الميلاد' : 'Birth Date',
                  value: p.birthDate!,
                ),
              if (p.nationality != null)
                _InfoRow(
                  label: isArabic ? 'الجنسية' : 'Nationality',
                  value: p.nationality!,
                ),
              if (p.maritalStatus != null)
                _InfoRow(
                  label: isArabic ? 'الحالة الاجتماعية' : 'Marital Status',
                  value: p.maritalStatus!,
                ),
              if (p.bloodType != null)
                _InfoRow(
                  label: isArabic ? 'فصيلة الدم' : 'Blood Type',
                  value: p.bloodType!,
                ),
            ],
          ),

          const SizedBox(height: AppSpacing.s16),

          // ── Contact Card ─────────────────────────────────────
          _SectionCard(
            title: isArabic ? 'معلومات الاتصال' : 'Contact Information',
            icon: FontAwesomeIcons.addressBook,
            children: [
              if (p.phone != null)
                _InfoRow(
                  label: isArabic ? 'الهاتف' : 'Phone',
                  value: p.phone!,
                ),
              if (p.mobile != null)
                _InfoRow(
                  label: isArabic ? 'الجوال' : 'Mobile',
                  value: p.mobile!,
                ),
              if (p.email != null)
                _InfoRow(
                  label: isArabic ? 'البريد' : 'Email',
                  value: p.email!,
                ),
              if (p.city != null)
                _InfoRow(
                  label: isArabic ? 'المدينة' : 'City',
                  value: p.city!,
                ),
              if (p.address != null)
                _InfoRow(
                  label: isArabic ? 'العنوان' : 'Address',
                  value: p.address!,
                ),
            ],
          ),

          const SizedBox(height: AppSpacing.s16),

          // ── Insurance Card ───────────────────────────────────
          if (p.insuranceCompany != null || p.insurancePolicyNo != null)
            _SectionCard(
              title: isArabic ? 'التأمين' : 'Insurance',
              icon: FontAwesomeIcons.shieldHalved,
              children: [
                if (p.insuranceCompany != null)
                  _InfoRow(
                    label: isArabic ? 'شركة التأمين' : 'Insurance Company',
                    value: p.insuranceCompany!,
                  ),
                if (p.insurancePolicyNo != null)
                  _InfoRow(
                    label: isArabic ? 'رقم الوثيقة' : 'Policy No',
                    value: p.insurancePolicyNo!,
                  ),
              ],
            ),

          const SizedBox(height: AppSpacing.s24),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

// ─── Helper Widgets ───────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final dynamic icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary500.withAlpha(15),
                  borderRadius: BorderRadius.circular(AppRadius.r8),
                ),
                child: Center(
                  child: FaIcon(icon, size: 15, color: AppColors.primary500),
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.headingText,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedText,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.headingText,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
