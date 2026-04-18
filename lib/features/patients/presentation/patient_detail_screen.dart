import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/models/patient_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_app_bar.dart';
import '../../../core/widgets/app_button.dart';

class PatientDetailScreen extends StatefulWidget {
  const PatientDetailScreen({super.key, required this.patientCode});

  final String patientCode;

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen>
    with SingleTickerProviderStateMixin {
  PatientModel? _patient;
  bool _isLoading = true;
  String? _error;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.getPatients(
        patientCode: widget.patientCode,
      );
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
      appBar: AppAppBar(title: isArabic ? 'ملف المريض' : 'Patient File'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildError(isArabic)
          : _patient == null
          ? _buildNotFound(isArabic)
          : _buildContent(context, isArabic),
      bottomNavigationBar: _patient != null
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s24,
                  AppSpacing.s16,
                  AppSpacing.s24,
                  AppSpacing.s24,
                ),
                child: AppButton(
                  text: isArabic ? 'حجز موعد جديد' : 'Book New Appointment',
                  onPressed: () {},
                  icon: FontAwesomeIcons.calendarPlus,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildError(bool isArabic) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.circleExclamation,
              size: 48,
              color: AppColors.error,
            ),
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
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isArabic) {
    final p = _patient!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s20,
        AppSpacing.s24,
        AppSpacing.s20,
        AppSpacing.s16,
      ),
      child: Column(
        children: [
          _TopInfoCard(p: p, isArabic: isArabic),
          const SizedBox(height: AppSpacing.s24),

          Container(
            decoration: BoxDecoration(
              color: AppColors.softSurface,
              borderRadius: BorderRadius.circular(AppRadius.r20),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.r12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(6),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: AppColors.primaryGreen,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              unselectedLabelStyle: Theme.of(context).textTheme.bodySmall,
              tabs: [
                Tab(text: isArabic ? 'معلومات' : 'Info'),
                Tab(text: isArabic ? 'التأمين' : 'Insurance'),
                Tab(text: isArabic ? 'التاريخ' : 'History'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s24),

          SizedBox(
            height: 320,
            child: TabBarView(
              controller: _tabController,
              children: [
                _PersonalInfoTab(p: p, isArabic: isArabic),
                _InsuranceTab(p: p, isArabic: isArabic),
                _HistoryTab(isArabic: isArabic),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopInfoCard extends StatelessWidget {
  const _TopInfoCard({required this.p, required this.isArabic});

  final PatientModel p;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.r24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withAlpha(60),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
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

class _PersonalInfoTab extends StatelessWidget {
  const _PersonalInfoTab({required this.p, required this.isArabic});

  final PatientModel p;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          icon: FontAwesomeIcons.user,
          title: isArabic ? 'المعلومات الشخصية' : 'Personal Information',
        ),
        const SizedBox(height: AppSpacing.s12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.r20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(4),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              if (p.identityNo != null)
                _InfoRow(
                  icon: FontAwesomeIcons.idCard,
                  label: isArabic ? 'رقم الهوية' : 'Identity No',
                  value: p.identityNo!,
                ),
              if (p.gender != null)
                _InfoRow(
                  icon: FontAwesomeIcons.venusMars,
                  label: isArabic ? 'الجنس' : 'Gender',
                  value: p.gender!,
                ),
              if (p.birthDate != null)
                _InfoRow(
                  icon: FontAwesomeIcons.cakeCandles,
                  label: isArabic ? 'تاريخ الميلاد' : 'Birth Date',
                  value: p.birthDate!,
                ),
              if (p.nationality != null)
                _InfoRow(
                  icon: FontAwesomeIcons.flag,
                  label: isArabic ? 'الجنسية' : 'Nationality',
                  value: p.nationality!,
                ),
              if (p.bloodType != null)
                _InfoRow(
                  icon: FontAwesomeIcons.droplet,
                  label: isArabic ? 'فصيلة الدم' : 'Blood Type',
                  value: p.bloodType!,
                  isLast: true,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InsuranceTab extends StatelessWidget {
  const _InsuranceTab({required this.p, required this.isArabic});

  final PatientModel p;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          icon: FontAwesomeIcons.shieldHalved,
          title: isArabic ? 'التأمين' : 'Insurance',
        ),
        const SizedBox(height: AppSpacing.s12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.r20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(4),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              if (p.insuranceCompany != null)
                _InfoRow(
                  icon: FontAwesomeIcons.building,
                  label: isArabic ? 'شركة التأمين' : 'Insurance Company',
                  value: p.insuranceCompany!,
                ),
              if (p.insurancePolicyNo != null)
                _InfoRow(
                  icon: FontAwesomeIcons.hashtag,
                  label: isArabic ? 'رقم الوثيقة' : 'Policy No',
                  value: p.insurancePolicyNo!,
                  isLast: true,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab({required this.isArabic});

  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          icon: FontAwesomeIcons.clockRotateLeft,
          title: isArabic ? 'السجلات الطبية' : 'Medical Records',
        ),
        const SizedBox(height: AppSpacing.s12),
        _CheckListItem(
          title: isArabic ? 'كشف عام' : 'General Checkup',
          subtitle: isArabic ? '15 مارس 2025' : 'Mar 15, 2025',
          isCompleted: true,
        ),
        const SizedBox(height: AppSpacing.s8),
        _CheckListItem(
          title: isArabic ? 'تحليل دم' : 'Blood Test',
          subtitle: isArabic ? '10 مارس 2025' : 'Mar 10, 2025',
          isCompleted: true,
        ),
        const SizedBox(height: AppSpacing.s8),
        _CheckListItem(
          title: isArabic ? 'أشعة سينية' : 'X-Ray',
          subtitle: isArabic ? '5 مارس 2025' : 'Mar 5, 2025',
          isCompleted: false,
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final dynamic icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FaIcon(icon, size: 16, color: AppColors.primaryGreen),
        const SizedBox(width: AppSpacing.s8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final dynamic icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s20,
        vertical: AppSpacing.s16,
      ),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: AppColors.border.withAlpha(80),
                  width: 1,
                ),
              ),
        borderRadius: isLast
            ? const BorderRadius.vertical(
                bottom: Radius.circular(AppRadius.r20),
              )
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.softGreen,
              borderRadius: BorderRadius.circular(AppRadius.r8),
            ),
            child: Center(
              child: FaIcon(icon, size: 14, color: AppColors.primaryGreen),
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckListItem extends StatelessWidget {
  const _CheckListItem({
    required this.title,
    required this.subtitle,
    required this.isCompleted,
  });

  final String title;
  final String subtitle;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.softGreen : AppColors.softSurface,
              borderRadius: BorderRadius.circular(AppRadius.r8),
            ),
            child: Center(
              child: FaIcon(
                isCompleted
                    ? FontAwesomeIcons.circleCheck
                    : FontAwesomeIcons.circle,
                size: 16,
                color: isCompleted
                    ? AppColors.primaryGreen
                    : AppColors.mutedText,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          FaIcon(
            FontAwesomeIcons.chevronRight,
            size: 14,
            color: AppColors.mutedText,
          ),
        ],
      ),
    );
  }
}
