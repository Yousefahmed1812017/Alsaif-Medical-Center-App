import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/user_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_fab.dart';
import 'widgets/activity_tile.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/quick_action_grid.dart';
import 'widgets/section_header.dart';
import 'widgets/stat_card.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key, required this.user});

  final UserModel user;

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: AppFab(onPressed: () {}),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Column(
        children: [
          DashboardHeader(user: widget.user, isArabic: isArabic),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s20,
                AppSpacing.s24,
                AppSpacing.s20,
                AppSpacing.s100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.user.clinicNameEnglish != null ||
                      widget.user.specialtyNameEnglish != null)
                    _ClinicBanner(user: widget.user, isArabic: isArabic),

                  if (widget.user.clinicNameEnglish != null ||
                      widget.user.specialtyNameEnglish != null)
                    const SizedBox(height: AppSpacing.s24),

                  SectionHeader(title: isArabic ? 'نظرة عامة' : 'Overview'),
                  const SizedBox(height: AppSpacing.s12),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          icon: FontAwesomeIcons.calendarDay,
                          value: '12',
                          label: isArabic ? 'مواعيد اليوم' : "Today's Appts",
                          iconColor: AppColors.accentBlue,
                          iconBgColor: AppColors.softBlue,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: StatCard(
                          icon: FontAwesomeIcons.userInjured,
                          value: '480',
                          label: isArabic ? 'إجمالي المرضى' : 'Total Patients',
                          iconColor: AppColors.primaryGreen,
                          iconBgColor: AppColors.softGreen,
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

                  SectionHeader(
                    title: isArabic ? 'إجراءات سريعة' : 'Quick Actions',
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  QuickActionGrid(
                    actions: [
                      QuickActionTile(
                        icon: FontAwesomeIcons.calendarXmark,
                        label: isArabic ? 'إغلاق موعد' : 'Close Time',
                        color: AppColors.accentBlue,
                        bgColor: AppColors.softBlue,
                        onTap: () => context.push('/close-time'),
                      ),
                      QuickActionTile(
                        icon: FontAwesomeIcons.fileMedical,
                        label: isArabic ? 'سجلات المرضى' : 'Patient Records',
                        color: AppColors.primaryGreen,
                        bgColor: AppColors.softGreen,
                        onTap: () => context.push('/patients'),
                      ),
                      QuickActionTile(
                        icon: FontAwesomeIcons.prescription,
                        label: isArabic ? 'كتابة وصفة' : 'Prescription',
                        color: const Color(0xFF8B5CF6),
                        bgColor: const Color(0xFFF3EEFF),
                        onTap: () {},
                      ),
                      QuickActionTile(
                        icon: FontAwesomeIcons.flask,
                        label: isArabic ? 'نتائج المختبر' : 'Lab Results',
                        color: AppColors.accentBlue,
                        bgColor: AppColors.softBlue,
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.s32),

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
                    statusColor: AppColors.primaryGreen,
                    statusText: isArabic ? 'مؤكد' : 'Confirmed',
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  _ScheduleCard(
                    patientName: isArabic ? 'سارة العلي' : 'Sara Al-Ali',
                    time: '09:30 - 10:00',
                    type: isArabic ? 'متابعة' : 'Follow-up',
                    statusColor: AppColors.accentBlue,
                    statusText: isArabic ? 'قادم' : 'Upcoming',
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  _ScheduleCard(
                    patientName: isArabic
                        ? 'خالد الرشيدي'
                        : 'Khalid Al-Rashidi',
                    time: '10:00 - 10:30',
                    type: isArabic ? 'استشارة' : 'Consultation',
                    statusColor: AppColors.warning,
                    statusText: isArabic ? 'في الانتظار' : 'Waiting',
                  ),

                  const SizedBox(height: AppSpacing.s32),

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
                    iconColor: AppColors.primaryGreen,
                    iconBgColor: AppColors.softGreen,
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
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}

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
        color: AppColors.softGreen,
        borderRadius: BorderRadius.circular(AppRadius.r20),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withAlpha(20),
              borderRadius: BorderRadius.circular(AppRadius.r12),
            ),
            child: const Center(
              child: FaIcon(
                FontAwesomeIcons.hospital,
                size: 18,
                color: AppColors.primaryGreen,
              ),
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
                      color: AppColors.greenDark,
                    ),
                  ),
                if (specialtyName.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    specialtyName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  isArabic ? 'متصل' : 'Online',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.white,
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
        borderRadius: BorderRadius.circular(AppRadius.r20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(4),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.softGreen,
              borderRadius: BorderRadius.circular(AppRadius.r12),
            ),
            child: Column(
              children: [
                Text(
                  time.split(' - ').first,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.greenDark,
                    fontSize: 12,
                  ),
                ),
                Text(
                  time.split(' - ').last,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patientName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  type,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(20),
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
