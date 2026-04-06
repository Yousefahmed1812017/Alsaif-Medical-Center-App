import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/user_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_app_bar.dart';
import '../../../core/widgets/app_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoggingOut = false;

  void _onLogout() async {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.r16)),
        title: Row(
          children: [
            FaIcon(FontAwesomeIcons.rightFromBracket, size: 20, color: AppColors.error),
            const SizedBox(width: AppSpacing.s12),
            Text(isArabic ? 'تسجيل الخروج' : 'Logout'),
          ],
        ),
        content: Text(
          isArabic
              ? 'هل أنت متأكد من تسجيل الخروج؟'
              : 'Are you sure you want to logout?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(isArabic ? 'خروج' : 'Logout'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoggingOut = true);
    await AuthService.logout();

    if (!mounted) return;
    // Navigate to user-type selection and clear navigation stack
    context.go('/user-type');
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final user = AuthService.currentUser;

    return Scaffold(
      appBar: AppAppBar(
        title: isArabic ? 'الملف الشخصي' : 'Profile',
      ),
      body: user == null
          ? Center(
              child: Text(
                isArabic ? 'لا توجد بيانات مستخدم' : 'No user data available',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.mutedText,
                    ),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // ─── Profile Header ────────────────────────────────
                  _ProfileHeader(user: user, isArabic: isArabic),

                  const SizedBox(height: AppSpacing.s8),

                  // ─── Info Sections ─────────────────────────────────
                  _SectionCard(
                    title: isArabic ? 'المعلومات الشخصية' : 'Personal Information',
                    icon: FontAwesomeIcons.user,
                    children: [
                      _InfoRow(
                        icon: FontAwesomeIcons.idCard,
                        label: isArabic ? 'رقم المستخدم' : 'User ID',
                        value: '${user.userId}',
                      ),
                      if (user.nameEnglish != null)
                        _InfoRow(
                          icon: FontAwesomeIcons.signature,
                          label: isArabic ? 'الاسم (إنجليزي)' : 'Name (English)',
                          value: user.nameEnglish!,
                        ),
                      if (user.nameArabic != null && user.nameArabic!.isNotEmpty)
                        _InfoRow(
                          icon: FontAwesomeIcons.signature,
                          label: isArabic ? 'الاسم (عربي)' : 'Name (Arabic)',
                          value: user.nameArabic!,
                        ),
                    ],
                  ),

                  _SectionCard(
                    title: isArabic ? 'معلومات الاتصال' : 'Contact Information',
                    icon: FontAwesomeIcons.addressBook,
                    children: [
                      if (user.email != null)
                        _InfoRow(
                          icon: FontAwesomeIcons.envelope,
                          label: isArabic ? 'البريد الإلكتروني' : 'Email',
                          value: user.email!,
                        ),
                      if (user.phone != null)
                        _InfoRow(
                          icon: FontAwesomeIcons.phone,
                          label: isArabic ? 'رقم الجوال' : 'Phone',
                          value: user.phone!,
                        ),
                    ],
                  ),

                  _SectionCard(
                    title: isArabic ? 'معلومات الوظيفة' : 'Job Information',
                    icon: FontAwesomeIcons.briefcase,
                    children: [
                      _InfoRow(
                        icon: FontAwesomeIcons.userTag,
                        label: isArabic ? 'نوع المستخدم' : 'User Type',
                        value: user.userType,
                        valueColor: _getUserTypeColor(user.userType),
                      ),
                      if (user.roleName != null)
                        _InfoRow(
                          icon: FontAwesomeIcons.idBadge,
                          label: isArabic ? 'الدور' : 'Role',
                          value: user.roleName!,
                        ),
                      if (user.clinicNameEnglish != null || user.clinicNameArabic != null)
                        _InfoRow(
                          icon: FontAwesomeIcons.hospital,
                          label: isArabic ? 'العيادة' : 'Clinic',
                          value: isArabic
                              ? (user.clinicNameArabic ?? user.clinicNameEnglish!)
                              : user.clinicNameEnglish!,
                        ),
                      if (user.specialtyNameEnglish != null || user.specialtyNameArabic != null)
                        _InfoRow(
                          icon: FontAwesomeIcons.stethoscope,
                          label: isArabic ? 'التخصص' : 'Specialty',
                          value: isArabic
                              ? (user.specialtyNameArabic ?? user.specialtyNameEnglish!)
                              : user.specialtyNameEnglish!,
                        ),
                    ],
                  ),

                  // ─── Logout Button ─────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s24,
                      vertical: AppSpacing.s32,
                    ),
                    child: AppButton(
                      text: isArabic ? 'تسجيل الخروج' : 'Logout',
                      onPressed: _onLogout,
                      isLoading: _isLoggingOut,
                      icon: FontAwesomeIcons.rightFromBracket,
                      type: AppButtonType.secondary,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.s24),
                ],
              ),
            ),
    );
  }

  Color _getUserTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'ADMIN':
        return AppColors.error;
      case 'DOCTOR':
        return AppColors.success;
      case 'EMPLOYEE':
        return AppColors.info;
      default:
        return AppColors.primary500;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user, required this.isArabic});

  final UserModel user;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final displayName = user.displayName(preferArabic: isArabic);

    // Pick an icon based on user type
    dynamic avatarIcon;
    switch (user.userType.toUpperCase()) {
      case 'DOCTOR':
        avatarIcon = FontAwesomeIcons.userDoctor;
        break;
      case 'ADMIN':
        avatarIcon = FontAwesomeIcons.userGear;
        break;
      default:
        avatarIcon = FontAwesomeIcons.userTie;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s24,
        vertical: AppSpacing.s32,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary500.withAlpha(35),
            AppColors.primary500.withAlpha(8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary400,
                  AppColors.primary600,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary500.withAlpha(60),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: FaIcon(avatarIcon, size: 36, color: Colors.white),
            ),
          ),
          const SizedBox(height: AppSpacing.s16),

          // Name
          Text(
            displayName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingText,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s8),

          // Role badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary500.withAlpha(25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary300.withAlpha(80)),
            ),
            child: Text(
              user.roleName ?? user.userType,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.primary600,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

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
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s8,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s20,
              AppSpacing.s16,
              AppSpacing.s20,
              AppSpacing.s4,
            ),
            child: Row(
              children: [
                FaIcon(icon, size: 16, color: AppColors.primary500),
                const SizedBox(width: AppSpacing.s8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary600,
                        letterSpacing: 0.3,
                      ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),

          // Items
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final dynamic icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s20,
        vertical: AppSpacing.s12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadius.r8),
            ),
            child: Center(
              child: FaIcon(icon, size: 15, color: AppColors.mutedText),
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
                        color: AppColors.mutedText,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: valueColor ?? AppColors.headingText,
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
