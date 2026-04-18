import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../main.dart';
import '../../../core/services/storage_service.dart';

// ─── Medical blue palette ────────────────────────────────────
const Color kOb50  = Color(0xFFEFF3FF);
const Color kOb200 = Color(0xFFBDD7E7);
const Color kOb400 = Color(0xFF6BAED6);
const Color kOb500 = Color(0xFF3182BD);
const Color kOb700 = Color(0xFF08519C);
const Color kObWhite   = Color(0xFFFFFFFF);
const Color kObBody    = Color(0xFF3A4356);
const Color kObMuted   = Color(0xFF8E9BAE);
const Color kObGreen   = Color(0xFF22C55E);
const Color kObSkin    = Color(0xFFFFD6B0);
const Color kObHair    = Color(0xFF5D4037);
const Color kObDark    = Color(0xFF3A4356);
const Color kObRed     = Color(0xFFEF4444);

// ─── Data model ─────────────────────────────────────────────
class OnboardingModel {
  final String titleEn;
  final String titleAr;
  final String subtitleEn;
  final String subtitleAr;
  final Widget Function() buildIllustration;

  const OnboardingModel({
    required this.titleEn,
    required this.titleAr,
    required this.subtitleEn,
    required this.subtitleAr,
    required this.buildIllustration,
  });
}

final List<OnboardingModel> kOnboardingSlides = [
  OnboardingModel(
    titleEn: 'Book your appointment\neasily',
    titleAr: 'احجز موعدك\nبسهولة',
    subtitleEn: 'At Alsaif Medical Center',
    subtitleAr: 'في مجمع السيف الطبي',
    buildIllustration: BookingIllustrationWidget.new,
  ),
  OnboardingModel(
    titleEn: 'Manage your appointments\neasily',
    titleAr: 'تابع حجوزاتك\nبكل سهولة',
    subtitleEn: 'And stay organized',
    subtitleAr: 'ونظّم مواعيدك بدقة',
    buildIllustration: ScheduleIllustrationWidget.new,
  ),
  OnboardingModel(
    titleEn: 'All your medical services\nin one place',
    titleAr: 'كل خدماتك الطبية\nفي مكان واحد',
    subtitleEn: 'Eye Care · Dental · Dermatology',
    subtitleAr: 'عيون - أسنان - جلدية',
    buildIllustration: ServicesIllustrationWidget.new,
  ),
];

// ════════════════════════════════════════════════════════════
//  MAIN ONBOARDING SCREEN
// ════════════════════════════════════════════════════════════
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController pageCtrl = PageController();
  int currentIdx = 0;

  late AnimationController fadeCtrl;
  late AnimationController slideCtrl;
  late Animation<double> fadeAnim;
  late Animation<Offset> slideAnim;

  bool get isArabic => appLocaleNotifier.value.languageCode == 'ar';

  @override
  void initState() {
    super.initState();
    fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    slideCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    fadeAnim = CurvedAnimation(parent: fadeCtrl, curve: Curves.easeOut);
    slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: slideCtrl, curve: Curves.easeOut));
    runEntryAnimation();
  }

  void runEntryAnimation() {
    fadeCtrl.forward(from: 0);
    slideCtrl.forward(from: 0);
  }

  @override
  void dispose() {
    pageCtrl.dispose();
    fadeCtrl.dispose();
    slideCtrl.dispose();
    super.dispose();
  }

  void onPageChanged(int index) {
    setState(() => currentIdx = index);
    runEntryAnimation();
  }

  void onNext() {
    if (currentIdx < kOnboardingSlides.length - 1) {
      pageCtrl.nextPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      finish();
    }
  }

  void onSkip() => finish();

  Future<void> finish() async {
    await StorageService.setOnboardingCompleted();
    if (!mounted) return;
    context.go('/language-selection');
  }

  void toggleLanguage() {
    final next = isArabic ? 'en' : 'ar';
    appLocaleNotifier.value = Locale(next);
    StorageService.setSelectedLanguage(next);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final slide = kOnboardingSlides[currentIdx];
    final isAr = isArabic;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: kObWhite,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF3F8FD),
                Color(0xFFE0EDF9),
                Color(0xFFF3F8FD),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Page view (illustrations fill top ~55%)
              PageView.builder(
                controller: pageCtrl,
                onPageChanged: onPageChanged,
                itemCount: kOnboardingSlides.length,
                itemBuilder: (ctx, i) => _AnimatedIllustrationWrapper(
                  key: ValueKey('illustration_$i'),
                  child: kOnboardingSlides[i].buildIllustration(),
                ),
              ),
              // Top bar: logo + language toggle + skip
              SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          LanguageToggleButton(
                              isArabic: isAr, onTap: toggleLanguage),
                          if (currentIdx < kOnboardingSlides.length - 1)
                            TextButton(
                              onPressed: onSkip,
                              style: TextButton.styleFrom(
                                foregroundColor: kObMuted,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                              ),
                              child: Text(isAr ? 'تخطي' : 'Skip',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      FadeTransition(
                        opacity: fadeAnim,
                        child: const _OnboardingLogo(),
                      ),
                    ],
                  ),
                ),
              ),
              // Bottom panel
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: BottomPanelWidget(
                  slide: slide,
                  isAr: isAr,
                  currentIndex: currentIdx,
                  totalSlides: kOnboardingSlides.length,
                  fadeAnimation: fadeAnim,
                  slideAnimation: slideAnim,
                  onNext: onNext,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  ANIMATED LOGO HEADER
// ════════════════════════════════════════════════════════════
class _OnboardingLogo extends StatelessWidget {
  const _OnboardingLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: kObWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: kOb500.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Image.asset(
        'assets/images/logo.png',
        fit: BoxFit.contain,
        errorBuilder: (ctx, err, stack) => const FaIcon(
          FontAwesomeIcons.hospital,
          color: kOb500,
          size: 32,
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  ILLUSTRATION ENTRY ANIMATION WRAPPER
// ════════════════════════════════════════════════════════════
class _AnimatedIllustrationWrapper extends StatefulWidget {
  const _AnimatedIllustrationWrapper({super.key, required this.child});
  final Widget child;

  @override
  State<_AnimatedIllustrationWrapper> createState() =>
      _AnimatedIllustrationWrapperState();
}

class _AnimatedIllustrationWrapperState
    extends State<_AnimatedIllustrationWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController ctrl;
  late Animation<double> fade;
  late Animation<Offset> slide;

  @override
  void initState() {
    super.initState();
    ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    fade = CurvedAnimation(parent: ctrl, curve: Curves.easeOut);
    slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: ctrl, curve: Curves.easeOutCubic));
    ctrl.forward();
  }

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: widget.child),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  BOTTOM PANEL
// ════════════════════════════════════════════════════════════
class BottomPanelWidget extends StatelessWidget {
  const BottomPanelWidget({
    super.key,
    required this.slide,
    required this.isAr,
    required this.currentIndex,
    required this.totalSlides,
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.onNext,
  });

  final OnboardingModel slide;
  final bool isAr;
  final int currentIndex;
  final int totalSlides;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final isLast = currentIndex == totalSlides - 1;
    return Container(
      decoration: BoxDecoration(
        color: kObWhite,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: kOb500.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(32, 28, 32, 44),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(
              position: slideAnimation,
              child: Text(
                isAr ? slide.titleAr : slide.titleEn,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: kOb700,
                  height: 1.35,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Subtitle
          FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(
              position: slideAnimation,
              child: Text(
                isAr ? slide.subtitleAr : slide.subtitleEn,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: kObMuted,
                  height: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          // Indicators + Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: List.generate(
                  totalSlides,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.only(right: 7),
                    width: currentIndex == i ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: currentIndex == i ? kOb500 : kOb200,
                    ),
                  ),
                ),
              ),
              NavButtonWidget(isLast: isLast, isAr: isAr, onTap: onNext),
            ],
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  NAV BUTTON
// ════════════════════════════════════════════════════════════
class NavButtonWidget extends StatefulWidget {
  const NavButtonWidget({
    super.key,
    required this.isLast,
    required this.isAr,
    required this.onTap,
  });

  final bool isLast;
  final bool isAr;
  final VoidCallback onTap;

  @override
  State<NavButtonWidget> createState() => NavButtonWidgetState();
}

class NavButtonWidgetState extends State<NavButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController scaleCtrl;

  @override
  void initState() {
    super.initState();
    scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.92,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    scaleCtrl.dispose();
    super.dispose();
  }

  void handleTap() {
    scaleCtrl.reverse().then((_) => scaleCtrl.forward());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scaleCtrl,
      child: GestureDetector(
        onTap: handleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: widget.isLast ? 140 : 56,
          height: 56,
          decoration: BoxDecoration(
            color: kOb700,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: kOb700.withValues(alpha: 0.30),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: widget.isLast
                ? Text(
                    widget.isAr ? 'ابدأ الآن' : 'Get Started',
                    style: const TextStyle(
                        color: kObWhite,
                        fontSize: 15,
                        fontWeight: FontWeight.w700),
                  )
                : Icon(
                    widget.isAr
                        ? Icons.arrow_back_rounded
                        : Icons.arrow_forward_rounded,
                    color: kObWhite,
                    size: 24,
                  ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  LANGUAGE TOGGLE
// ════════════════════════════════════════════════════════════
class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton(
      {super.key, required this.isArabic, required this.onTap});

  final bool isArabic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: kOb50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kOb200, width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌐', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              isArabic ? 'English' : 'عربي',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: kOb700),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  ILLUSTRATION 1 — BOOKING
// ════════════════════════════════════════════════════════════
class BookingIllustrationWidget extends StatefulWidget {
  const BookingIllustrationWidget({super.key});

  @override
  State<BookingIllustrationWidget> createState() =>
      BookingIllustrationState();
}

class BookingIllustrationState extends State<BookingIllustrationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController floatCtrl;
  late Animation<double> floatAnim;

  @override
  void initState() {
    super.initState();
    floatCtrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))
          ..repeat(reverse: true);
    floatAnim = Tween<double>(begin: -8, end: 8)
        .animate(CurvedAnimation(parent: floatCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final ih = size.height * 0.54;

    return SizedBox(
      height: ih,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
              child: CustomPaint(painter: GeoBgPainter(color: kOb50))),
          // Soft blob
          Positioned(
            top: ih * 0.06,
            left: size.width * 0.5 - 100,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kOb500.withValues(alpha: 0.10),
              ),
            ),
          ),
          // Calendar card
          AnimatedBuilder(
            animation: floatAnim,
            builder: (ctx, child) => Positioned(
              top: ih * 0.12 + floatAnim.value * 0.5,
              left: size.width * 0.06,
              child: child!,
            ),
            child: const CalendarCardWidget(),
          ),
          // Doctor figure
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: floatAnim,
              builder: (ctx, child) => Transform.translate(
                offset: Offset(0, floatAnim.value * 0.4),
                child: child,
              ),
              child: const Center(child: DoctorFigureWidget()),
            ),
          ),
          // Time badge
          AnimatedBuilder(
            animation: floatAnim,
            builder: (ctx, child) => Positioned(
              top: ih * 0.20 - floatAnim.value * 0.6,
              right: size.width * 0.06,
              child: child!,
            ),
            child: const FloatingBadgeWidget(
              icon: Icons.access_time_rounded,
              label: '10:30 AM',
              color: kOb400,
            ),
          ),
          // Confirmed badge
          AnimatedBuilder(
            animation: floatAnim,
            builder: (ctx, child) => Positioned(
              top: ih * 0.52 + floatAnim.value * 0.3,
              right: size.width * 0.08,
              child: child!,
            ),
            child: const FloatingBadgeWidget(
              icon: Icons.check_circle_outline_rounded,
              label: 'Confirmed',
              color: kObGreen,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  ILLUSTRATION 2 — SCHEDULE
// ════════════════════════════════════════════════════════════
class ScheduleIllustrationWidget extends StatefulWidget {
  const ScheduleIllustrationWidget({super.key});

  @override
  State<ScheduleIllustrationWidget> createState() =>
      ScheduleIllustrationState();
}

class ScheduleIllustrationState extends State<ScheduleIllustrationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController floatCtrl;
  late Animation<double> floatAnim;

  @override
  void initState() {
    super.initState();
    floatCtrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))
          ..repeat(reverse: true);
    floatAnim = Tween<double>(begin: -7, end: 7)
        .animate(CurvedAnimation(parent: floatCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final ih = size.height * 0.54;

    return SizedBox(
      height: ih,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
              child: CustomPaint(painter: GeoBgPainter(color: kOb200))),
          // Arch
          Positioned(
            bottom: 0,
            left: size.width * 0.15,
            right: size.width * 0.15,
            child: Container(
              height: ih * 0.45,
              decoration: BoxDecoration(
                color: kOb400.withValues(alpha: 0.18),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(999)),
              ),
            ),
          ),
          // Schedule board
          AnimatedBuilder(
            animation: floatAnim,
            builder: (ctx, child) => Positioned(
              top: ih * 0.10 + floatAnim.value * 0.4,
              left: size.width * 0.04,
              child: child!,
            ),
            child: const ScheduleBoardWidget(),
          ),
          // Doctor with clipboard
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: floatAnim,
              builder: (ctx, child) => Transform.translate(
                offset: Offset(0, floatAnim.value * 0.35),
                child: child,
              ),
              child: const Center(child: DoctorClipboardWidget()),
            ),
          ),
          // Next appointment badge
          AnimatedBuilder(
            animation: floatAnim,
            builder: (ctx, child) => Positioned(
              top: ih * 0.18 - floatAnim.value * 0.5,
              right: size.width * 0.06,
              child: child!,
            ),
            child: const FloatingBadgeWidget(
              icon: Icons.calendar_month_rounded,
              label: 'Thu, 10 Apr',
              color: kOb500,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  ILLUSTRATION 3 — SERVICES
// ════════════════════════════════════════════════════════════
class ServicesIllustrationWidget extends StatefulWidget {
  const ServicesIllustrationWidget({super.key});

  @override
  State<ServicesIllustrationWidget> createState() =>
      ServicesIllustrationState();
}

class ServicesIllustrationState extends State<ServicesIllustrationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController floatCtrl;
  late Animation<double> floatAnim;

  @override
  void initState() {
    super.initState();
    floatCtrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))
          ..repeat(reverse: true);
    floatAnim = Tween<double>(begin: -6, end: 6)
        .animate(CurvedAnimation(parent: floatCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final ih = size.height * 0.54;
    final isAr = appLocaleNotifier.value.languageCode == 'ar';

    return SizedBox(
      height: ih,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
              child: CustomPaint(
                  painter:
                      GeoBgPainter(color: kOb700.withValues(alpha: 0.07)))),
          // Blob
          Positioned(
            top: ih * 0.04,
            left: size.width * 0.5 - 110,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kOb500.withValues(alpha: 0.12),
              ),
            ),
          ),
          // Medical cross
          Positioned(
            top: ih * 0.14,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: floatAnim,
              builder: (ctx, child) => Transform.translate(
                offset: Offset(0, floatAnim.value * 0.3),
                child: child,
              ),
              child: const Center(child: MedicalCrossWidget()),
            ),
          ),
          // Eye care card
          AnimatedBuilder(
            animation: floatAnim,
            builder: (ctx, child) => Positioned(
              top: ih * 0.38 + floatAnim.value * 0.5,
              left: size.width * 0.04,
              child: child!,
            ),
            child: SpecialtyCardWidget(
              icon: Icons.remove_red_eye_outlined,
              label: isAr ? 'عيون' : 'Eye Care',
              color: kOb400,
            ),
          ),
          // Dental card
          AnimatedBuilder(
            animation: floatAnim,
            builder: (ctx, child) => Positioned(
              top: ih * 0.26 - floatAnim.value * 0.4,
              left: size.width * 0.33,
              child: child!,
            ),
            child: SpecialtyCardWidget(
              icon: Icons.medical_services_outlined,
              label: isAr ? 'أسنان' : 'Dental',
              color: kObGreen,
            ),
          ),
          // Dermatology card
          AnimatedBuilder(
            animation: floatAnim,
            builder: (ctx, child) => Positioned(
              top: ih * 0.38 + floatAnim.value * 0.5,
              right: size.width * 0.04,
              child: child!,
            ),
            child: SpecialtyCardWidget(
              icon: Icons.spa_outlined,
              label: isAr ? 'جلدية' : 'Dermatology',
              color: kOb500,
            ),
          ),
          // Clinic building
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: floatAnim,
              builder: (ctx, child) => Transform.translate(
                offset: Offset(0, floatAnim.value * 0.3),
                child: child,
              ),
              child: const Center(child: ClinicBuildingWidget()),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  REUSABLE WIDGETS
// ════════════════════════════════════════════════════════════

class DoctorFigureWidget extends StatelessWidget {
  const DoctorFigureWidget({super.key});
  @override
  Widget build(BuildContext context) =>
      const SizedBox(width: 180, height: 260, child: CustomPaint(painter: DoctorPainter()));
}

class DoctorClipboardWidget extends StatelessWidget {
  const DoctorClipboardWidget({super.key});
  @override
  Widget build(BuildContext context) =>
      const SizedBox(width: 170, height: 250, child: CustomPaint(painter: DoctorClipboardPainter()));
}

class MedicalCrossWidget extends StatelessWidget {
  const MedicalCrossWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration:
          BoxDecoration(color: kOb500, borderRadius: BorderRadius.circular(20)),
      child: const Icon(Icons.add_rounded, color: kObWhite, size: 54),
    );
  }
}

class ClinicBuildingWidget extends StatelessWidget {
  const ClinicBuildingWidget({super.key});
  @override
  Widget build(BuildContext context) =>
      const SizedBox(width: 200, height: 180, child: CustomPaint(painter: ClinicBuildingPainter()));
}

class CalendarCardWidget extends StatelessWidget {
  const CalendarCardWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: kObWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: kOb500.withValues(alpha: 0.15),
              blurRadius: 18,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 28,
            decoration: BoxDecoration(
                color: kOb500, borderRadius: BorderRadius.circular(8)),
            child: const Center(
              child: Text('April 2025',
                  style: TextStyle(
                      color: kObWhite, fontSize: 10, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 8),
          const CalendarGridWidget(),
        ],
      ),
    );
  }
}

class CalendarGridWidget extends StatelessWidget {
  const CalendarGridWidget({super.key});
  static const List<int> highlighted = [9, 14, 21];
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 3,
      runSpacing: 3,
      children: List.generate(28, (i) {
        final day = i + 1;
        final hl = highlighted.contains(day);
        return Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hl ? kOb500 : kOb50,
          ),
          child: Center(
            child: Text(
              '$day',
              style: TextStyle(
                fontSize: 7,
                color: hl ? kObWhite : kObBody,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class FloatingBadgeWidget extends StatelessWidget {
  const FloatingBadgeWidget(
      {super.key, required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: kObWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.20),
              blurRadius: 14,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

class ScheduleBoardWidget extends StatelessWidget {
  const ScheduleBoardWidget({super.key});
  @override
  Widget build(BuildContext context) {
    final slots = [
      {'time': '08:00', 'name': 'Ahmed K.', 'color': kOb400},
      {'time': '10:30', 'name': 'Sara M.', 'color': kObGreen},
      {'time': '12:00', 'name': 'Omar H.', 'color': kOb200},
    ];
    return Container(
      width: 116,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: kObWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: kOb500.withValues(alpha: 0.14),
              blurRadius: 18,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: slots.map((s) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 32,
                  decoration: BoxDecoration(
                    color: s['color'] as Color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 7),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s['time'] as String,
                        style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: kOb700)),
                    Text(s['name'] as String,
                        style: const TextStyle(fontSize: 9, color: kObMuted)),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class SpecialtyCardWidget extends StatelessWidget {
  const SpecialtyCardWidget(
      {super.key, required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: kObWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.18),
              blurRadius: 16,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w700, color: kObBody)),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  CUSTOM PAINTERS
// ════════════════════════════════════════════════════════════

class GeoBgPainter extends CustomPainter {
  final Color color;
  const GeoBgPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.72)
      ..quadraticBezierTo(size.width / 2, size.height * 0.95, 0, size.height * 0.72)
      ..close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(GeoBgPainter old) => old.color != color;
}

class DoctorPainter extends CustomPainter {
  const DoctorPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.98), width: w * 0.7, height: 10),
      Paint()..color = kOb200.withValues(alpha: 0.35),
    );

    // Legs
    final legPaint = Paint()..color = kObDark;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*0.30, h*0.80, w*0.14, h*0.20), const Radius.circular(6)), legPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*0.56, h*0.80, w*0.14, h*0.20), const Radius.circular(6)), legPaint);

    // Body / coat
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*0.20, h*0.38, w*0.60, h*0.46), const Radius.circular(10)), Paint()..color = kOb50);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*0.22, h*0.36, w*0.56, h*0.45), const Radius.circular(10)), Paint()..color = kObWhite);

    // Lapels
    final lapelPaint = Paint()..color = kOb50;
    canvas.drawPath(Path()..moveTo(w*0.50, h*0.36)..lineTo(w*0.22, h*0.50)..lineTo(w*0.38, h*0.36)..close(), lapelPaint);
    canvas.drawPath(Path()..moveTo(w*0.50, h*0.36)..lineTo(w*0.78, h*0.50)..lineTo(w*0.62, h*0.36)..close(), lapelPaint);

    // Stethoscope
    final stetPaint = Paint()..color = kOb400..strokeWidth = 3.5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    canvas.drawPath(Path()..moveTo(w*0.38, h*0.48)..quadraticBezierTo(w*0.30, h*0.60, w*0.42, h*0.68)..quadraticBezierTo(w*0.50, h*0.74, w*0.58, h*0.65), stetPaint);
    canvas.drawCircle(Offset(w*0.58, h*0.65), 5, Paint()..color = kOb500);

    // Left arm
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*0.06, h*0.38, w*0.17, h*0.32), const Radius.circular(8)), Paint()..color = kOb50);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*0.08, h*0.36, w*0.16, h*0.32), const Radius.circular(8)), Paint()..color = kObWhite);
    // Right arm
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*0.76, h*0.38, w*0.17, h*0.32), const Radius.circular(8)), Paint()..color = kOb50);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*0.76, h*0.36, w*0.16, h*0.32), const Radius.circular(8)), Paint()..color = kObWhite);

    // Hands
    final skinPaint = Paint()..color = kObSkin;
    canvas.drawCircle(Offset(w*0.15, h*0.67), 9, skinPaint);
    canvas.drawCircle(Offset(w*0.84, h*0.67), 9, skinPaint);

    // Neck + head
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*0.42, h*0.22, w*0.16, h*0.16), const Radius.circular(6)), skinPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(w*0.50, h*0.14), width: w*0.36, height: h*0.22), skinPaint);

    // Hair
    canvas.drawOval(Rect.fromCenter(center: Offset(w*0.50, h*0.085), width: w*0.36, height: h*0.12), Paint()..color = kObHair);

    // Eyes
    canvas.drawCircle(Offset(w*0.43, h*0.145), 3, Paint()..color = kOb700);
    canvas.drawCircle(Offset(w*0.57, h*0.145), 3, Paint()..color = kOb700);

    // Smile
    canvas.drawArc(
      Rect.fromCenter(center: Offset(w*0.50, h*0.175), width: 20, height: 10),
      0.3, math.pi - 0.6, false,
      Paint()..color = kObRed..strokeWidth = 1.5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round,
    );

    // Pocket + cross badge
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*0.54, h*0.46, w*0.14, w*0.10), const Radius.circular(4)), Paint()..color = kOb50);
    canvas.drawRect(Rect.fromCenter(center: Offset(w*0.61, h*0.51), width: 8, height: 2.5), Paint()..color = kObRed);
    canvas.drawRect(Rect.fromCenter(center: Offset(w*0.61, h*0.51), width: 2.5, height: 8), Paint()..color = kObRed);
  }
  @override
  bool shouldRepaint(DoctorPainter old) => false;
}

class DoctorClipboardPainter extends CustomPainter {
  const DoctorClipboardPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final skinPaint = Paint()..color = kObSkin;
    final coatPaint = Paint()..color = kObWhite;

    // Shadow
    canvas.drawOval(Rect.fromCenter(center: Offset(w*0.5, h*0.98), width: w*0.65, height: 9), Paint()..color = kOb200.withValues(alpha: 0.30));

    // Legs
    final darkPaint = Paint()..color = kObDark;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*0.30, h*0.80, w*0.14, h*0.20), const Radius.circular(6)), darkPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*0.56, h*0.80, w*0.14, h*0.20), const Radius.circular(6)), darkPaint);

    // Body
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*0.22, h*0.36, w*0.56, h*0.46), const Radius.circular(10)), coatPaint);

    // Clipboard
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*0.04, h*0.40, w*0.22, h*0.30), const Radius.circular(8)), Paint()..color = const Color(0xFFF0F3F8));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*0.12, h*0.37, w*0.06, h*0.06), const Radius.circular(3)), Paint()..color = kOb400);
    for (int i = 0; i < 4; i++) {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*0.07, h*(0.46 + i*0.055), w*(i == 1 ? 0.10 : 0.16), 2.5), const Radius.circular(1)), Paint()..color = kOb200);
    }
    // Checkmark
    final checkPath = Path()..moveTo(w*0.07, h*0.665)..lineTo(w*0.10, h*0.690)..lineTo(w*0.155, h*0.648);
    canvas.drawPath(checkPath, Paint()..color = kObGreen..strokeWidth = 2..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);

    // Left arm
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*0.04, h*0.36, w*0.20, h*0.32), const Radius.circular(8)), Paint()..color = kOb50);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*0.05, h*0.34, w*0.18, h*0.32), const Radius.circular(8)), coatPaint);
    // Right arm
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*0.77, h*0.38, w*0.16, h*0.28), const Radius.circular(8)), coatPaint);
    canvas.drawCircle(Offset(w*0.85, h*0.66), 8, skinPaint);

    // Neck + head
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*0.42, h*0.22, w*0.16, h*0.16), const Radius.circular(6)), skinPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(w*0.50, h*0.14), width: w*0.36, height: h*0.22), skinPaint);

    // Hair (green for variety)
    canvas.drawOval(Rect.fromCenter(center: Offset(w*0.50, h*0.085), width: w*0.36, height: h*0.12), Paint()..color = const Color(0xFF4A6741));

    // Eyes
    canvas.drawCircle(Offset(w*0.43, h*0.145), 3, Paint()..color = kOb700);
    canvas.drawCircle(Offset(w*0.57, h*0.145), 3, Paint()..color = kOb700);

    // Stethoscope
    canvas.drawPath(Path()..moveTo(w*0.42, h*0.46)..quadraticBezierTo(w*0.62, h*0.55, w*0.65, h*0.65),
        Paint()..color = kOb400..strokeWidth = 3..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
    canvas.drawCircle(Offset(w*0.65, h*0.65), 5, Paint()..color = kOb500);
  }
  @override
  bool shouldRepaint(DoctorClipboardPainter old) => false;
}

class ClinicBuildingPainter extends CustomPainter {
  const ClinicBuildingPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Ground shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w*0.50, h*0.99), width: w*0.80, height: 12),
      Paint()..color = kOb200.withValues(alpha: 0.40),
    );

    // Building body
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*0.10, h*0.30, w*0.80, h*0.70), const Radius.circular(10)), Paint()..color = kOb50);

    // Roof
    canvas.drawPath(Path()..moveTo(w*0.06, h*0.33)..lineTo(w*0.50, h*0.05)..lineTo(w*0.94, h*0.33)..close(), Paint()..color = kOb500);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*0.10, h*0.30, w*0.80, h*0.04), const Radius.circular(4)), Paint()..color = kOb200);

    // Windows row 1
    final winPaint = Paint()..color = kOb400.withValues(alpha: 0.30);
    for (int i = 0; i < 3; i++) {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*(0.17 + i*0.25), h*0.40, w*0.16, h*0.16), const Radius.circular(6)), winPaint);
    }
    // Windows row 2
    for (int i = 0; i < 3; i++) {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*(0.17 + i*0.25), h*0.62, w*0.16, h*0.16), const Radius.circular(6)), winPaint);
    }

    // Door
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*0.38, h*0.70, w*0.24, h*0.30), const Radius.circular(8)), Paint()..color = kOb400.withValues(alpha: 0.20));
    canvas.drawArc(Rect.fromLTWH(w*0.38, h*0.62, w*0.24, w*0.24), math.pi, math.pi, false, Paint()..color = kOb400.withValues(alpha: 0.20));

    // Medical cross
    canvas.drawRect(Rect.fromCenter(center: Offset(w*0.50, h*0.19), width: 18, height: 5), Paint()..color = kObRed);
    canvas.drawRect(Rect.fromCenter(center: Offset(w*0.50, h*0.19), width: 5, height: 18), Paint()..color = kObRed);
  }
  @override
  bool shouldRepaint(ClinicBuildingPainter old) => false;
}
