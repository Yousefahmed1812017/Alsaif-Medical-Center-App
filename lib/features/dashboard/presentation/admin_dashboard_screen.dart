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

/// Dashboard for Admin users — system overview, management actions.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key, required this.user});

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
                  // ── System Health Banner ──────────────────────────
                  _SystemHealthBanner(isArabic: isArabic),
                  const SizedBox(height: AppSpacing.s24),

                  // ── Stats Grid (2x2) ─────────────────────────────
                  SectionHeader(
                    title: isArabic ? 'إحصائيات النظام' : 'System Stats',
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          icon: FontAwesomeIcons.userGroup,
                          value: '42',
                          label: isArabic ? 'إجمالي الموظفين' : 'Total Staff',
                          iconColor: AppColors.primary500,
                          iconBgColor: AppColors.primary50,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: StatCard(
                          icon: FontAwesomeIcons.userDoctor,
                          value: '18',
                          label: isArabic ? 'أطباء نشطون' : 'Active Doctors',
                          iconColor: AppColors.success,
                          iconBgColor: AppColors.successSoft,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          icon: FontAwesomeIcons.calendarCheck,
                          value: '87',
                          label: isArabic ? 'مواعيد اليوم' : "Today's Appts",
                          iconColor: AppColors.info,
                          iconBgColor: AppColors.infoSoft,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: StatCard(
                          icon: FontAwesomeIcons.hospital,
                          value: '6',
                          label: isArabic ? 'العيادات' : 'Clinics',
                          iconColor: const Color(0xFF8B5CF6),
                          iconBgColor: const Color(0xFFF3EEFF),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.s32),

                  // ── Quick Actions ─────────────────────────────────
                  SectionHeader(
                    title: isArabic ? 'الإدارة' : 'Management',
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  QuickActionGrid(
                    actions: [
                      QuickActionTile(
                        icon: FontAwesomeIcons.usersGear,
                        label: isArabic ? 'إدارة الموظفين' : 'Staff Mgmt',
                        color: AppColors.primary500,
                        onTap: () {},
                      ),
                      QuickActionTile(
                        icon: FontAwesomeIcons.chartPie,
                        label: isArabic ? 'التقارير' : 'Reports',
                        color: AppColors.success,
                        onTap: () {},
                      ),
                      QuickActionTile(
                        icon: FontAwesomeIcons.hospital,
                        label: isArabic ? 'العيادات' : 'Clinics',
                        color: const Color(0xFF8B5CF6),
                        onTap: () {},
                      ),
                      QuickActionTile(
                        icon: FontAwesomeIcons.gear,
                        label: isArabic ? 'الإعدادات' : 'Settings',
                        color: AppColors.mutedText,
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.s12),

                  // Second row of actions
                  QuickActionGrid(
                    actions: [
                      QuickActionTile(
                        icon: FontAwesomeIcons.userPlus,
                        label: isArabic ? 'إضافة مستخدم' : 'Add User',
                        color: AppColors.info,
                        onTap: () {},
                      ),
                      QuickActionTile(
                        icon: FontAwesomeIcons.calendarDays,
                        label: isArabic ? 'جدول المواعيد' : 'Schedules',
                        color: AppColors.warning,
                        onTap: () {},
                      ),
                      QuickActionTile(
                        icon: FontAwesomeIcons.bell,
                        label: isArabic ? 'الإشعارات' : 'Notifications',
                        color: AppColors.error,
                        onTap: () {},
                      ),
                      QuickActionTile(
                        icon: FontAwesomeIcons.fileInvoiceDollar,
                        label: isArabic ? 'المالية' : 'Finance',
                        color: const Color(0xFF0EA5E9),
                        onTap: () {},
                      ),
                      QuickActionTile(
                        icon: FontAwesomeIcons.listCheck,
                        label: isArabic ? 'المهام' : 'Tasks',
                        color: const Color(0xFF8B5CF6),
                        onTap: () => context.push('/todo-tasks'),
                      ),
                      QuickActionTile(
                        icon: FontAwesomeIcons.calendarPlus,
                        label: isArabic ? 'حجز موعد' : 'Book Appt',
                        color: AppColors.success,
                        onTap: () => context.push('/booking'),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.s32),

                  // ── Recent Activity ───────────────────────────────
                  SectionHeader(
                    title: isArabic ? 'سجل النظام' : 'System Log',
                    actionLabel: isArabic ? 'عرض الكل' : 'See All',
                    onAction: () {},
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  ActivityTile(
                    icon: FontAwesomeIcons.userPlus,
                    title: isArabic ? 'موظف جديد مضاف' : 'New Staff Added',
                    subtitle: isArabic
                        ? 'تم إضافة سارة العلي - مركز الاتصال'
                        : 'Sara Al-Ali added - Call Center',
                    time: isArabic ? 'منذ 2 ساعة' : '2 hrs ago',
                    iconColor: AppColors.success,
                    iconBgColor: AppColors.successSoft,
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  ActivityTile(
                    icon: FontAwesomeIcons.shieldHalved,
                    title: isArabic ? 'تحديث صلاحيات' : 'Permissions Updated',
                    subtitle: isArabic
                        ? 'تم تغيير دور خالد إلى مشرف'
                        : 'Khalid role changed to Supervisor',
                    time: isArabic ? 'منذ 3 ساعات' : '3 hrs ago',
                    iconColor: AppColors.warning,
                    iconBgColor: AppColors.warningSoft,
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  ActivityTile(
                    icon: FontAwesomeIcons.server,
                    title: isArabic ? 'نسخة احتياطية' : 'System Backup',
                    subtitle: isArabic
                        ? 'تم إنشاء نسخة احتياطية تلقائية بنجاح'
                        : 'Automatic backup completed successfully',
                    time: isArabic ? 'منذ 5 ساعات' : '5 hrs ago',
                    iconColor: AppColors.info,
                    iconBgColor: AppColors.infoSoft,
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

// ─── Admin-specific widgets ───────────────────────────────────────────────

class _SystemHealthBanner extends StatelessWidget {
  const _SystemHealthBanner({required this.isArabic});

  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.success,
            AppColors.success.withAlpha(180),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.r16),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withAlpha(40),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(35),
              borderRadius: BorderRadius.circular(AppRadius.r12),
            ),
            child: const Center(
              child: FaIcon(FontAwesomeIcons.heartPulse, size: 20, color: Colors.white),
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? 'حالة النظام' : 'System Health',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  isArabic
                      ? 'جميع الأنظمة تعمل بشكل طبيعي'
                      : 'All systems operational',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withAlpha(200),
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(35),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '99.9%',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
