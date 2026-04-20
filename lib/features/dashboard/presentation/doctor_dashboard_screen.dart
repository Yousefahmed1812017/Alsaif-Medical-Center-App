import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/user_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_empty_state.dart';
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

                  SectionHeader(
                    title: isArabic ? 'إجراءات سريعة' : 'Quick Actions',
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  QuickActionGrid(
                    actions: [
                      QuickActionTile(
                        icon: FontAwesomeIcons.calendarCheck,
                        label: isArabic ? 'الحجوزات' : 'Bookings',
                        color: AppColors.primary700,
                        bgColor: AppColors.primary100,
                        onTap: () => context.push('/booking'),
                      ),
                      QuickActionTile(
                        icon: FontAwesomeIcons.userInjured,
                        label: isArabic ? 'المرضى' : 'Patients',
                        color: AppColors.primary700,
                        bgColor: AppColors.primary100,
                        onTap: () => context.push('/patients'),
                      ),
                      QuickActionTile(
                        icon: FontAwesomeIcons.calendarXmark,
                        label: isArabic ? 'طلبات الإغلاق' : 'Close Requests',
                        color: AppColors.primary700,
                        bgColor: AppColors.primary100,
                        onTap: () => context.push('/close-time'),
                      ),
                      QuickActionTile(
                        icon: FontAwesomeIcons.listCheck,
                        label: isArabic ? 'المهام' : 'Tasks',
                        color: AppColors.primary700,
                        bgColor: AppColors.primary100,
                        onTap: () => context.push('/todo-tasks'),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.s32),

                  SectionHeader(
                    title: isArabic ? 'مواعيد اليوم' : "Today's Schedule",
                    actionLabel: isArabic ? 'عرض الكل' : 'See All',
                    onAction: () => context.push('/booking'),
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  AppEmptyState(
                    icon: FontAwesomeIcons.calendarXmark,
                    title: isArabic
                        ? 'لا توجد مواعيد اليوم'
                        : 'No Appointments Today',
                    message: isArabic
                        ? 'يمكنك إضافة موعد جديد عبر زر الحجز'
                        : 'You can add a new appointment via the booking button',
                    actionText: isArabic ? 'حجز موعد' : 'Book Appointment',
                    onActionPressed: () => context.push('/booking'),
                  ),

                  const SizedBox(height: AppSpacing.s32),

                  SectionHeader(
                    title: isArabic ? 'النشاط الأخير' : 'Recent Activity',
                    actionLabel: isArabic ? 'عرض الكل' : 'See All',
                    onAction: () {},
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  AppEmptyState(
                    icon: FontAwesomeIcons.clockRotateLeft,
                    title: isArabic
                        ? 'لا يوجد نشاط حديث'
                        : 'No Recent Activity',
                    message: isArabic
                        ? 'ستظهر هنا آخر الإجراءات والأنشطة المسجلة'
                        : 'Your latest actions and records will appear here',
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
        isArabic: isArabic,
        onTap: (index) {
          if (index == 4) {
            context.push('/profile');
            return;
          }
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
        color: AppColors.primary100,
        borderRadius: BorderRadius.circular(AppRadius.r20),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary500.withAlpha(20),
              borderRadius: BorderRadius.circular(AppRadius.r12),
            ),
            child: const Center(
              child: FaIcon(
                FontAwesomeIcons.hospital,
                size: 18,
                color: AppColors.primary500,
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
                      color: AppColors.primary900,
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
              color: AppColors.primary500,
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
              color: AppColors.primary100,
              borderRadius: BorderRadius.circular(AppRadius.r12),
            ),
            child: Column(
              children: [
                Text(
                  time.split(' - ').first,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary900,
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
