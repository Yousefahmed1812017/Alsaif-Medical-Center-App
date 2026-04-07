import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';

class UserTypeSelectionScreen extends StatelessWidget {
  const UserTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 1),
              Center(
                child: FaIcon(
                  FontAwesomeIcons.hospitalUser,
                  size: 64,
                  color: AppColors.primary500,
                ),
              ),
              const SizedBox(height: AppSpacing.s32),
              Text(
                isArabic ? 'نوع الحساب' : 'Account Type',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s12),
              Text(
                isArabic
                    ? 'الرجاء اختيار نوع حسابك للمتابعة.'
                    : 'Please select your account type to proceed.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.mutedText,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s48),

              // Patient Flow Option
              _AccountTypeCard(
                icon: FontAwesomeIcons.bedPulse,
                title: isArabic ? 'مريض' : 'Patient',
                description: isArabic
                    ? 'سجل دخولك كمريض لحجز ومتابعة المواعيد.'
                    : 'Log in as a patient to book and manage appointments.',
                onTap: () => context.push('/patient-type'),
              ),
              const SizedBox(height: AppSpacing.s16),

              // Internal User Flow Option
              _AccountTypeCard(
                icon: FontAwesomeIcons.userTie,
                title: isArabic ? 'متطوع / موظف أطباء' : 'Staff / Internal User',
                description: isArabic
                    ? 'تسجيل الدخول للكادر الطبي والموظفين والإدارة.'
                    : 'Login for medical staff, employees, and management.',
                onTap: () => context.push('/internal-login'),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountTypeCard extends StatelessWidget {
  const _AccountTypeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final dynamic icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.s24),
      child: Row(
        children: [
          FaIcon(
            icon,
            size: 32,
            color: AppColors.primary500,
          ),
          const SizedBox(width: AppSpacing.s20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.headingText,
                      ),
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.mutedText,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s16),
          Directionality.of(context) == TextDirection.rtl
              ? const FaIcon(
                  FontAwesomeIcons.chevronLeft,
                  size: 16,
                  color: AppColors.border,
                )
              : const FaIcon(
                  FontAwesomeIcons.chevronRight,
                  size: 16,
                  color: AppColors.border,
                ),
        ],
      ),
    );
  }
}
