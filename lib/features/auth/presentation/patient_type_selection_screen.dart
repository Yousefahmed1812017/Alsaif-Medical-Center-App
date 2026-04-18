import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';

class PatientTypeSelectionScreen extends StatelessWidget {
  const PatientTypeSelectionScreen({super.key});

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
              // Logo or Header Graphic
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: MediaQuery.of(context).size.width * 0.8,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return FaIcon(
                      FontAwesomeIcons.hospital,
                      size: 64,
                      color: AppColors.primary500,
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.s32),
              Text(
                isArabic ? 'أهلاً بك في مجمع السيف الطبي' : 'Welcome to Alsaif Medical',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s12),
              Text(
                isArabic
                    ? 'كيف يمكننا مساعدتك اليوم؟'
                    : 'How can we help you today?',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.mutedText,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s48),

              // Existing Patient Card
              _PatientTypeCard(
                icon: FontAwesomeIcons.userCheck,
                title: isArabic ? 'مريض حالي' : 'Existing Patient',
                description: isArabic
                    ? 'تسجيل الدخول للاطلاع على ملفك الطبي والمواعيد.'
                    : 'Log in to view your medical records and appointments.',
                onTap: () => context.push('/login'),
              ),
              const SizedBox(height: AppSpacing.s16),

              // New Patient Card
              _PatientTypeCard(
                icon: FontAwesomeIcons.userPlus,
                title: isArabic ? 'مريض جديد' : 'New Patient',
                description: isArabic
                    ? 'إنشاء ملف رقمي جديد وفتح سجل طبي.'
                    : 'Create a new digital profile and medical record.',
                onTap: () => context.push('/new-patient'),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _PatientTypeCard extends StatelessWidget {
  const _PatientTypeCard({
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
          FaIcon(
            Directionality.of(context) == TextDirection.rtl
                ? FontAwesomeIcons.chevronLeft
                : FontAwesomeIcons.chevronRight,
            size: 16,
            color: AppColors.border,
          ),
        ],
      ),
    );
  }
}
