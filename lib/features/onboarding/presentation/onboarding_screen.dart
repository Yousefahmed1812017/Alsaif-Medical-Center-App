import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';

class OnboardingSlide {
  final dynamic icon;
  final String titleEn;
  final String titleAr;
  final String descriptionEn;
  final String descriptionAr;

  const OnboardingSlide({
    required this.icon,
    required this.titleEn,
    required this.titleAr,
    required this.descriptionEn,
    required this.descriptionAr,
  });
}

const List<OnboardingSlide> _slides = [
  OnboardingSlide(
    icon: FontAwesomeIcons.heartPulse,
    titleEn: 'Your Health, Our Priority',
    titleAr: 'صحتك هي أولويتنا',
    descriptionEn: 'Experience seamless medical care with top professionals in a calm, modern environment.',
    descriptionAr: 'استمتع برعاية طبية متكاملة مع أفضل الخبراء في بيئة عصرية هادئة.',
  ),
  OnboardingSlide(
    icon: FontAwesomeIcons.userDoctor,
    titleEn: 'Expert Care',
    titleAr: 'عناية خبيرة',
    descriptionEn: 'Connect with specialized doctors and schedule your appointments easily.',
    descriptionAr: 'تواصل مع أطباء متخصصين وحدد مواعيدك بكل سهولة.',
  ),
  OnboardingSlide(
    icon: FontAwesomeIcons.fileMedical,
    titleEn: 'Access Medical Records',
    titleAr: 'اطلع على سجلاتك',
    descriptionEn: 'View your prescriptions, test results, and visit history securely anytime.',
    descriptionAr: 'اطلع على وصفاتك الطبية، نتائج الفحوصات وتاريخ زياراتك بأمان في أي وقت.',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onSkipOrContinue() async {
    await StorageService.setOnboardingCompleted();
    if (!mounted) return;
    context.go('/language-selection');
  }

  void _onNext() {
    if (_currentIndex < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine language based on current context if we had a language chosen,
    // but at onboarding it might be default. We'll show English by default or dynamic.
    // To truly reflect the mock logic properly without full localizations setup:
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
                child: TextButton(
                  onPressed: _onSkipOrContinue,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.mutedText,
                  ),
                  child: Text(isArabic ? 'تخطي' : 'Skip'),
                ),
              ),
            ),
            // Slider
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.s32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Illustration Placeholder
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: AppColors.primary500.withAlpha(18),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary500.withAlpha(40),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: FaIcon(
                              slide.icon,
                              size: 72,
                              color: AppColors.primary500,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s48),
                        Text(
                          isArabic ? slide.titleAr : slide.titleEn,
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.s16),
                        Text(
                          isArabic ? slide.descriptionAr : slide.descriptionEn,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.mutedText,
                                height: 1.5,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Bottom Controls
            Padding(
              padding: const EdgeInsets.all(AppSpacing.s32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page Indicators
                  Row(
                    children: List.generate(
                      _slides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsetsDirectional.only(end: 8),
                        height: 8,
                        width: _currentIndex == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == index ? AppColors.primary500 : AppColors.divider,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  // Next / Continue Button
                  AppButton(
                    isFullWidth: false,
                    text: _currentIndex == _slides.length - 1
                        ? (isArabic ? 'ابدأ الأن' : 'Get Started')
                        : (isArabic ? 'التالي' : 'Next'),
                    onPressed: _currentIndex == _slides.length - 1 ? _onSkipOrContinue : _onNext,
                    icon: _currentIndex == _slides.length - 1
                        ? (isArabic ? FontAwesomeIcons.arrowLeft : FontAwesomeIcons.arrowRight)
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
