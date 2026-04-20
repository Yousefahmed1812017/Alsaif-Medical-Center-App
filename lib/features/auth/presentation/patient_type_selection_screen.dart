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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 1),
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

              Row(
                children: [
                  Expanded(
                    child: _PatientTypeCard(
                      imagePath: 'assets/images/patientIn.png',
                      title: isArabic ? 'مريض حالي' : 'Existing Patient',
                      onTap: () => context.push('/login'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s16),
                  Expanded(
                    child: _PatientTypeCard(
                      imagePath: 'assets/images/patientOut.png',
                      title: isArabic ? 'مريض جديد' : 'New Patient',
                      onTap: () => context.push('/new-patient'),
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

class _PatientTypeCard extends StatelessWidget {
  const _PatientTypeCard({
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
