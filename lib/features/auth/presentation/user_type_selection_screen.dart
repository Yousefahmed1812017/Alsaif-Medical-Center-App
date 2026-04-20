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

              Row(
                children: [
                  Expanded(
                    child: _AccountTypeCard(
                      imagePath: 'assets/images/Patient.png',
                      title: isArabic ? 'مريض' : 'Patient',
                      onTap: () => context.push('/patient-type'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s16),
                  Expanded(
                    child: _AccountTypeCard(
                      imagePath: 'assets/images/doctor.png',
                      title: isArabic ? 'موظف' : 'Staff',
                      onTap: () => context.push('/internal-login'),
                    ),
                  ),
                ],
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
    required this.imagePath,
    required this.title,
    required this.onTap,
  });

  final String imagePath;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      color: AppColors.primary100.withAlpha(60), // Soft blue background for the square
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            height: 150, // Larger image
            fit: BoxFit.contain,
          ),
          const SizedBox(height: AppSpacing.s16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingText,
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
