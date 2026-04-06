import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../main.dart'; // import appLocaleNotifier
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String? _selectedLanguageCode;

  @override
  void initState() {
    super.initState();
    _selectedLanguageCode = StorageService.selectedLanguage ?? 'en';
  }

  void _onLanguageSelected(String code) {
    setState(() {
      _selectedLanguageCode = code;
    });
    // Immediately update language purely for preview, before committing
    appLocaleNotifier.value = Locale(code);
  }

  void _onContinue() async {
    if (_selectedLanguageCode != null) {
      await StorageService.setSelectedLanguage(_selectedLanguageCode!);
      if (!mounted) return;
      context.go('/user-type');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = _selectedLanguageCode == 'ar';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.s48),
              // Header
              FaIcon(
                FontAwesomeIcons.globe,
                size: 64,
                color: AppColors.primary500,
              ),
              const SizedBox(height: AppSpacing.s32),
              Text(
                isArabic ? 'اختر اللغة' : 'Select Language',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s12),
              Text(
                isArabic
                    ? 'يرجى اختيار لغتك المفضلة للمتابعة.'
                    : 'Please select your preferred language to continue.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.mutedText,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s48),

              // Language Options
              _LanguageOptionCard(
                languageName: 'English',
                languageCode: 'en',
                isSelected: _selectedLanguageCode == 'en',
                onTap: () => _onLanguageSelected('en'),
              ),
              const SizedBox(height: AppSpacing.s16),
              _LanguageOptionCard(
                languageName: 'العربية',
                languageCode: 'ar',
                isSelected: _selectedLanguageCode == 'ar',
                onTap: () => _onLanguageSelected('ar'),
              ),

              const Spacer(),

              // Continue Action
              AppButton(
                text: isArabic ? 'متابعة' : 'Continue',
                onPressed: _onContinue,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageOptionCard extends StatelessWidget {
  const _LanguageOptionCard({
    required this.languageName,
    required this.languageCode,
    required this.isSelected,
    required this.onTap,
  });

  final String languageName;
  final String languageCode;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.r16),
          border: Border.all(
            color: isSelected ? AppColors.primary500 : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? AppColors.primary50 : AppColors.surface,
        ),
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              languageName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: isSelected ? AppColors.primary600 : AppColors.headingText,
                    fontSize: 20,
                  ),
            ),
            if (isSelected)
              const FaIcon(
                FontAwesomeIcons.circleCheck,
                color: AppColors.primary500,
                size: 24,
              )
            else
              const FaIcon(
                 FontAwesomeIcons.circle,
                 color: AppColors.border,
                 size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
