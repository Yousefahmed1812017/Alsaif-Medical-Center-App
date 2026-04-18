import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/user_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import 'widgets/activity_tile.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/quick_action_grid.dart';
import 'widgets/section_header.dart';
import 'widgets/stat_card.dart';

/// Dashboard for Doctor users — shows schedule, patients, and clinic info.
class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({super.key, required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ─── Header ──────────────────────────────────────────────
          DashboardHeader(user: user, isArabic: isArabic),

          // ─── Scrollable Content ──────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.s20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Clinic / Specialty Banner ─────────────────────
                  if (user.clinicNameEnglish != null || user.specialtyNameEnglish != null)
                    _ClinicBanner(user: user, isArabic: isArabic),

                  if (user.clinicNameEnglish != null || user.specialtyNameEnglish != null)
                    const SizedBox(height: AppSpacing.s24),

                  // ── Stats Row ────────────────────────────────────
                  SectionHeader(
                    title: isArabic ? 'نظرة عامة' : 'Overview',
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          icon: FontAwesomeIcons.calendarDay,
                          value: '12',
                          label: isArabic ? 'مواعيد اليوم' : "Today's Appts",
                          iconColor: AppColors.primary500,
                          iconBgColor: AppColors.primary50,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: StatCard(
                          icon: FontAwesomeIcons.userInjured,
                          value: '480',
                          label: isArabic ? 'إجمالي المرضى' : 'Total Patients',
                          iconColor: AppColors.success,
                          iconBgColor: AppColors.successSoft,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: StatCard(
                          icon: FontAwesomeIcons.star,
                          value: '4.9',
                          label: isArabic ? 'التقييم' : 'Rating',
                          iconColor: AppColors.warning,
                          iconBgColor: AppColors.warningSoft,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.s32),

                  // ── Quick Actions ─────────────────────────────────
                  SectionHeader(
                    title: isArabic ? 'إجراءات سريعة' : 'Quick Actions',
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  QuickActionGrid(
                    actions: [
                      QuickActionTile(
                        icon: FontAwesomeIcons.calendarXmark,
                        label: isArabic ? 'إغلاق موعد' : 'Close Time',
                        color: AppColors.primary500,
                        onTap: () => context.push('/close-time'),
                      ),
                      QuickActionTile(
                        icon: FontAwesomeIcons.fileMedical,
                        label: isArabic ? 'سجلات المرضى' : 'Patient Records',
                        color: AppColors.success,
                        onTap: () => context.push('/patients'),
                      ),
                      QuickActionTile(
                        icon: FontAwesomeIcons.calendarPlus,
                        label: isArabic ? 'حجز موعد' : 'Book Appointment',
                        color: const Color(0xFF8B5CF6),
                        onTap: () => context.push('/booking'),
                      ),
                      QuickActionTile(
                        icon: FontAwesomeIcons.flask,
                        label: isArabic ? 'نتائج المختبر' : 'Lab Results',
                        color: AppColors.info,
                        onTap: () {},
                      ),
                      QuickActionTile(
                        icon: FontAwesomeIcons.listCheck,
                        label: isArabic ? 'المهام' : 'Tasks',
                        color: const Color(0xFF8B5CF6),
                        onTap: () => context.push('/todo-tasks'),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.s32),

                  // ── Today's Schedule ──────────────────────────────
                  SectionHeader(
                    title: isArabic ? 'مواعيد اليوم' : "Today's Schedule",
                    actionLabel: isArabic ? 'عرض الكل' : 'See All',
                    onAction: () {},
                  ),
                  const SizedBox(height: AppSpacing.s12),

                  _ScheduleCard(
                    patientName: isArabic ? 'أحمد محمد' : 'Ahmed Mohamed',
                    time: '09:00 - 09:30',
                    type: isArabic ? 'كشف أول' : 'First Visit',
                    statusColor: AppColors.success,
                    statusText: isArabic ? 'مؤكد' : 'Confirmed',
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  _ScheduleCard(
                    patientName: isArabic ? 'سارة العلي' : 'Sara Al-Ali',
                    time: '09:30 - 10:00',
                    type: isArabic ? 'متابعة' : 'Follow-up',
                    statusColor: AppColors.primary500,
                    statusText: isArabic ? 'قادم' : 'Upcoming',
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  _ScheduleCard(
                    patientName: isArabic ? 'خالد الرشيدي' : 'Khalid Al-Rashidi',
                    time: '10:00 - 10:30',
                    type: isArabic ? 'استشارة' : 'Consultation',
                    statusColor: AppColors.warning,
                    statusText: isArabic ? 'في الانتظار' : 'Waiting',
                  ),

                  const SizedBox(height: AppSpacing.s32),

                  // ── Recent Activity ───────────────────────────────
                  SectionHeader(
                    title: isArabic ? 'النشاط الأخير' : 'Recent Activity',
                    actionLabel: isArabic ? 'عرض الكل' : 'See All',
                    onAction: () {},
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  ActivityTile(
                    icon: FontAwesomeIcons.fileMedical,
                    title: isArabic ? 'تقرير مكتمل' : 'Report Completed',
                    subtitle: isArabic
                        ? 'تقرير المريض فيصل - جلدية'
                        : 'Patient Faisal report - Dermatology',
                    time: isArabic ? 'منذ 10 دقائق' : '10 min ago',
                    iconColor: AppColors.success,
                    iconBgColor: AppColors.successSoft,
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  ActivityTile(
                    icon: FontAwesomeIcons.prescription,
                    title: isArabic ? 'وصفة طبية صادرة' : 'Prescription Issued',
                    subtitle: isArabic
                        ? 'للمريضة نورة - علاج أكزيما'
                        : 'For patient Noura - Eczema treatment',
                    time: isArabic ? 'منذ 25 دقيقة' : '25 min ago',
                    iconColor: const Color(0xFF8B5CF6),
                    iconBgColor: const Color(0xFFF3EEFF),
                  ),

                  const SizedBox(height: AppSpacing.s24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Doctor-specific widgets ──────────────────────────────────────────────

class _ClinicBanner extends StatelessWidget {
  const _ClinicBanner({required this.user, required this.isArabic});

  final UserModel user;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final clinicName = isArabic
        ? (user.clinicNameArabic ?? user.clinicNameEnglish ?? '')
        : (user.clinicNameEnglish ?? '');
    final specialtyName = isArabic
        ? (user.specialtyNameArabic ?? user.specialtyNameEnglish ?? '')
        : (user.specialtyNameEnglish ?? '');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary500.withAlpha(15),
            AppColors.primary500.withAlpha(8),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.r16),
        border: Border.all(color: AppColors.primary200.withAlpha(80)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary100,
              borderRadius: BorderRadius.circular(AppRadius.r12),
            ),
            child: const Center(
              child: FaIcon(FontAwesomeIcons.hospital, size: 20, color: AppColors.primary500),
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (clinicName.isNotEmpty)
                  Text(
                    clinicName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary500,
                        ),
                  ),
                if (specialtyName.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    specialtyName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedText,
                        ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.successSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  isArabic ? 'متصل' : 'Online',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
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

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.patientName,
    required this.time,
    required this.type,
    required this.statusColor,
    required this.statusText,
  });

  final String patientName;
  final String time;
  final String type;
  final Color statusColor;
  final String statusText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r12),
        border: Border.all(color: AppColors.border.withAlpha(100)),
      ),
      child: Row(
        children: [
          // Time column
          Container(
            width: 54,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary500.withAlpha(12),
              borderRadius: BorderRadius.circular(AppRadius.r8),
            ),
            child: Column(
              children: [
                Text(
                  time.split(' - ').first,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary500,
                        fontSize: 12,
                      ),
                ),
                Text(
                  time.split(' - ').last,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedText,
                        fontSize: 10,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s12),

          // Patient info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patientName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.headingText,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  type,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedText,
                      ),
                ),
              ],
            ),
          ),

          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
