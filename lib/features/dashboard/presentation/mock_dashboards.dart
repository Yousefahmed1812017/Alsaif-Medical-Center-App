import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_app_bar.dart';
import '../../../core/widgets/app_empty_state.dart';

class MockInternalDashboardScreen extends StatelessWidget {
  final String role;
  
  const MockInternalDashboardScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final user = AuthService.currentUser;

    // Icon based on actual userType
    dynamic roleIcon = FontAwesomeIcons.userTie;
    if (role == 'admin') {
      roleIcon = FontAwesomeIcons.userGear;
    } else if (role == 'doctor') {
      roleIcon = FontAwesomeIcons.userDoctor;
    }

    // Display name from the API
    final displayName = user?.displayName(preferArabic: isArabic) ?? role.toUpperCase();
    final roleName = user?.roleName ?? role.toUpperCase();

    // Extra info for doctors
    final clinicInfo = user?.clinicNameEnglish != null
        ? (isArabic ? user?.clinicNameArabic ?? user?.clinicNameEnglish : user?.clinicNameEnglish)
        : null;

    return Scaffold(
      appBar: AppAppBar(
        title: isArabic ? 'لوحة التحكم' : 'Dashboard',
        showBackButton: false,
      ),
      body: Column(
        children: [
          // Welcome header with user info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.s24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary500.withAlpha(30),
                  AppColors.primary500.withAlpha(10),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primary500.withAlpha(40),
                      child: FaIcon(roleIcon, size: 24, color: AppColors.primary500),
                    ),
                    const SizedBox(width: AppSpacing.s16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic ? 'مرحباً 👋' : 'Welcome 👋',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.mutedText,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            displayName,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.headingText,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s12),
                // Role badge
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(
                      icon: FontAwesomeIcons.idBadge,
                      label: roleName,
                    ),
                    if (clinicInfo != null)
                      _InfoChip(
                        icon: FontAwesomeIcons.hospitalUser,
                        label: clinicInfo,
                      ),
                    if (user?.email != null)
                      _InfoChip(
                        icon: FontAwesomeIcons.envelope,
                        label: user!.email!,
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Placeholder content
          Expanded(
            child: AppEmptyState(
              icon: FontAwesomeIcons.chartLine,
              title: isArabic ? 'قيد التطوير' : 'Coming Soon',
              message: isArabic
                  ? 'سيتم ربط البيانات والتقارير هنا قريباً.'
                  : 'Reports and data will be connected here soon.',
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final dynamic icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 13, color: AppColors.primary500),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.headingText,
                    fontWeight: FontWeight.w500,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
