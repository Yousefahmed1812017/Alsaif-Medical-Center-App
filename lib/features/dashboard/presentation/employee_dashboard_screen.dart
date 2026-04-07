import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/user_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import 'widgets/activity_tile.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/quick_action_grid.dart';
import 'widgets/section_header.dart';
import 'widgets/stat_card.dart';

/// Dashboard for Employee / Call Center users.
class EmployeeDashboardScreen extends StatelessWidget {
  const EmployeeDashboardScreen({super.key, required this.user});

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
                  // ── Stats Row ────────────────────────────────────
                  SectionHeader(
                    title: isArabic ? 'نظرة عامة' : 'Overview',
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          icon: FontAwesomeIcons.phoneVolume,
                          value: '24',
                          label: isArabic ? 'مكالمات اليوم' : "Today's Calls",
                          iconColor: AppColors.primary500,
                          iconBgColor: AppColors.primary50,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: StatCard(
                          icon: FontAwesomeIcons.calendarCheck,
                          value: '8',
                          label: isArabic ? 'مواعيد معلقة' : 'Pending Appts',
                          iconColor: AppColors.warning,
                          iconBgColor: AppColors.warningSoft,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: StatCard(
                          icon: FontAwesomeIcons.userGroup,
                          value: '156',
                          label: isArabic ? 'مرضى نشطون' : 'Active Patients',
                          iconColor: AppColors.success,
                          iconBgColor: AppColors.successSoft,
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
                        icon: FontAwesomeIcons.magnifyingGlass,
                        label: isArabic ? 'بحث مريض' : 'Search Patient',
                        color: AppColors.primary500,
                        onTap: () => context.push('/patients'),
                      ),
                      QuickActionTile(
                        icon: FontAwesomeIcons.calendarPlus,
                        label: isArabic ? 'موعد جديد' : 'New Appointment',
                        color: AppColors.success,
                        onTap: () {},
                      ),
                      QuickActionTile(
                        icon: FontAwesomeIcons.headset,
                        label: isArabic ? 'سجل المكالمات' : 'Call Log',
                        color: AppColors.info,
                        onTap: () {},
                      ),
                      QuickActionTile(
                        icon: FontAwesomeIcons.clipboardQuestion,
                        label: isArabic ? 'استفسارات' : 'Inquiries',
                        color: AppColors.warning,
                        onTap: () {},
                      ),
                    ],
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
                    icon: FontAwesomeIcons.calendarCheck,
                    title: isArabic ? 'تم حجز موعد' : 'Appointment Booked',
                    subtitle: isArabic
                        ? 'المريض أحمد - د. خالد - أسنان'
                        : 'Patient Ahmed - Dr. Khalid - Dental',
                    time: isArabic ? 'منذ 5 دقائق' : '5 min ago',
                    iconColor: AppColors.success,
                    iconBgColor: AppColors.successSoft,
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  ActivityTile(
                    icon: FontAwesomeIcons.phone,
                    title: isArabic ? 'مكالمة واردة' : 'Incoming Call',
                    subtitle: isArabic
                        ? 'استفسار عن مواعيد الباطنية'
                        : 'Inquiry about Internal Medicine',
                    time: isArabic ? 'منذ 15 دقيقة' : '15 min ago',
                    iconColor: AppColors.info,
                    iconBgColor: AppColors.infoSoft,
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  ActivityTile(
                    icon: FontAwesomeIcons.xmark,
                    title: isArabic ? 'موعد ملغي' : 'Appointment Cancelled',
                    subtitle: isArabic
                        ? 'المريضة سارة - إلغاء بطلب شخصي'
                        : 'Patient Sara - Personal request',
                    time: isArabic ? 'منذ 30 دقيقة' : '30 min ago',
                    iconColor: AppColors.error,
                    iconBgColor: AppColors.errorSoft,
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  ActivityTile(
                    icon: FontAwesomeIcons.userPlus,
                    title: isArabic ? 'مريض جديد مسجل' : 'New Patient Registered',
                    subtitle: isArabic
                        ? 'يوسف محمد - تسجيل عبر الهاتف'
                        : 'Youssef Mohamed - Phone registration',
                    time: isArabic ? 'منذ ساعة' : '1 hr ago',
                    iconColor: AppColors.primary500,
                    iconBgColor: AppColors.primary50,
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
