import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../main.dart';
import '../../../core/services/storage_service.dart';

// ─── Colors ──────────────────────────────────────────────────
const Color kObWhite = Color(0xFFFFFFFF);
const Color kObBody = Color(0xFF3A4356);
const Color kObMuted = Color(0xFF8E9BAE);
const Color kObPrimary = Color(0xFF3182BD);

// ─── Data Model ──────────────────────────────────────────────
class OnboardingModel {
  final String titleEn;
  final String titleAr;
  final String subtitleEn;
  final String subtitleAr;
  final String imagePath;

  const OnboardingModel({
    required this.titleEn,
    required this.titleAr,
    required this.subtitleEn,
    required this.subtitleAr,
    required this.imagePath,
  });
}

final List<OnboardingModel> kOnboardingSlides = [
  const OnboardingModel(
    titleEn: 'Book your appointment\neasily',
    titleAr: 'احجز موعدك\nبسهولة',
    subtitleEn: 'At Alsaif Medical Center',
    subtitleAr: 'في مجمع السيف الطبي',
    imagePath: 'assets/images/Onboarding1.png',
  ),
  const OnboardingModel(
    titleEn: 'Manage your appointments\neasily',
    titleAr: 'تابع حجوزاتك\nبكل سهولة',
    subtitleEn: 'And stay organized',
    subtitleAr: 'ونظّم مواعيدك بدقة',
    imagePath: 'assets/images/Onboarding2.png',
  ),
  const OnboardingModel(
    titleEn: 'All your medical services\nin one place',
    titleAr: 'كل خدماتك الطبية\nفي مكان واحد',
    subtitleEn: 'Eye Care · Dental · Dermatology',
    subtitleAr: 'عيون · أسنان · جلدية',
    imagePath: 'assets/images/Onboarding3.png',
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

  late AnimationController screenFadeCtrl;
  late Animation<double> screenFadeAnim;

  bool get isArabic => appLocaleNotifier.value.languageCode == 'ar';

  @override
  void initState() {
    super.initState();
    // Screen fade-in
    screenFadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    screenFadeAnim =
        CurvedAnimation(parent: screenFadeCtrl, curve: Curves.easeInOut);

    screenFadeCtrl.forward();
  }

  @override
  void dispose() {
    pageCtrl.dispose();
    screenFadeCtrl.dispose();
    super.dispose();
  }

  void onPageChanged(int index) {
    setState(() => currentIdx = index);
  }

  void onNext() {
    if (currentIdx < kOnboardingSlides.length - 1) {
      pageCtrl.nextPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      finish();
    }
  }

  void onPrevious() {
    if (currentIdx > 0) {
      pageCtrl.previousPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }

  void onSkip() => finish();

  Future<void> finish() async {
    await StorageService.setOnboardingCompleted();
    if (!mounted) return;
    context.go('/user-type');
  }

  @override
  Widget build(BuildContext context) {
    final isAr = isArabic;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: kObWhite,
        body: FadeTransition(
          opacity: screenFadeAnim,
          child: Stack(
            children: [
              // Animated Wave Background at the bottom
              const Positioned.fill(
                child: AnimatedWaveBackground(),
              ),

              // Main Content
              SafeArea(
                child: Column(
                  children: [
                    // Top Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _LanguageFlagIndicator(isArabic: isAr),
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
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600)),
                            ),
                        ],
                      ),
                    ),

                    // Floating Image & Text Carousel
                    Expanded(
                      child: PageView.builder(
                        controller: pageCtrl,
                        onPageChanged: onPageChanged,
                        itemCount: kOnboardingSlides.length,
                        itemBuilder: (ctx, i) {
                          return _OnboardingPage(
                            slide: kOnboardingSlides[i],
                            isAr: isAr,
                            isActive: i == currentIdx,
                          );
                        },
                      ),
                    ),

                    // Bottom Navigation Panel
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                      child: SlideUpTransition(
                        delay: 400,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Previous Button or empty space
                            currentIdx > 0
                                ? NavButton(
                                    label: isAr ? 'السابق' : 'Previous',
                                    icon: isAr
                                        ? Icons.arrow_forward_rounded
                                        : Icons.arrow_back_rounded,
                                    isPrimary: false,
                                    onTap: onPrevious,
                                  )
                                : const SizedBox(width: 100), // Placeholder to keep center alignment

                            // Page Indicators
                            Row(
                              children: List.generate(
                                kOnboardingSlides.length,
                                (i) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: currentIdx == i ? 24 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: currentIdx == i
                                        ? kObPrimary
                                        : kObMuted.withValues(alpha: 0.3),
                                  ),
                                ),
                              ),
                            ),

                            // Next / Get Started Button
                            NavButton(
                              label: currentIdx == kOnboardingSlides.length - 1
                                  ? (isAr ? 'ابدأ' : 'Start')
                                  : (isAr ? 'التالي' : 'Next'),
                              icon: currentIdx == kOnboardingSlides.length - 1
                                  ? Icons.check_circle_outline_rounded
                                  : (isAr
                                      ? Icons.arrow_back_rounded
                                      : Icons.arrow_forward_rounded),
                              isPrimary: true,
                              onTap: onNext,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
//  ONBOARDING PAGE CONTENT (Floating Image + Slide up text)
// ════════════════════════════════════════════════════════════
class _OnboardingPage extends StatelessWidget {
  final OnboardingModel slide;
  final bool isAr;
  final bool isActive;

  const _OnboardingPage({
    required this.slide,
    required this.isAr,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    // Only animate if it's the active page
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Floating Avatar Image
          Expanded(
            flex: 6,
            child: FloatingImageWidget(
              imagePath: slide.imagePath,
              isActive: isActive,
            ),
          ),
          const SizedBox(height: 32),
          // Title (Slide Up)
          Expanded(
            flex: 4,
            child: SlideUpTransition(
              delay: isActive ? 100 : 0,
              child: Column(
                children: [
                  Text(
                    isAr ? slide.titleAr : slide.titleEn,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: kObBody,
                      height: 1.3,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Subtitle
                  Text(
                    isAr ? slide.subtitleAr : slide.subtitleEn,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: kObMuted,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  FLOATING IMAGE WIDGET
// ════════════════════════════════════════════════════════════
class FloatingImageWidget extends StatefulWidget {
  final String imagePath;
  final bool isActive;

  const FloatingImageWidget({
    super.key,
    required this.imagePath,
    required this.isActive,
  });

  @override
  State<FloatingImageWidget> createState() => _FloatingImageWidgetState();
}

class _FloatingImageWidgetState extends State<FloatingImageWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant FloatingImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.repeat(reverse: true);
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Slow up/down motion
        final dy = 12.0 * math.sin(_controller.value * math.pi);
        return Transform.translate(
          offset: Offset(0, dy),
          child: child,
        );
      },
      child: Center(
        child: Image.asset(
          widget.imagePath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.broken_image_rounded, size: 48, color: kObMuted),
                const SizedBox(height: 8),
                Text('Image not found: \n${widget.imagePath}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10, color: kObMuted),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  SLIDE UP TRANSITION WRAPPER
// ════════════════════════════════════════════════════════════
class SlideUpTransition extends StatefulWidget {
  final Widget child;
  final int delay; // in milliseconds

  const SlideUpTransition({super.key, required this.child, this.delay = 0});

  @override
  State<SlideUpTransition> createState() => _SlideUpTransitionState();
}

class _SlideUpTransitionState extends State<SlideUpTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    if (widget.delay > 0) {
      Future.delayed(Duration(milliseconds: widget.delay), () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant SlideUpTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the widget updates (e.g. page changed), re-trigger animation
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: widget.child,
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  ANIMATED WAVE BACKGROUND
// ════════════════════════════════════════════════════════════
class AnimatedWaveBackground extends StatefulWidget {
  const AnimatedWaveBackground({super.key});

  @override
  State<AnimatedWaveBackground> createState() => _AnimatedWaveBackgroundState();
}

class _AnimatedWaveBackgroundState extends State<AnimatedWaveBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: WavePainter(_controller.value),
        );
      },
    );
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;

  WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    // Soft gradient colors: light blue -> soft green
    final gradient1 = LinearGradient(
      colors: [
        const Color(0xFFE3F2FD).withValues(alpha: 0.6), // Light Blue
        const Color(0xFFE8F5E9).withValues(alpha: 0.5), // Soft Green
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final gradient2 = LinearGradient(
      colors: [
        const Color(0xFFBBDEFB).withValues(alpha: 0.5),
        const Color(0xFFC8E6C9).withValues(alpha: 0.4),
      ],
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
    );

    final paint1 = Paint()
      ..shader = gradient1.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final paint2 = Paint()
      ..shader = gradient2.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path1 = Path();
    final path2 = Path();

    path1.moveTo(0, size.height);
    path2.moveTo(0, size.height);

    // Draw waves at the bottom (starts at 65% of screen height)
    final baseHeight = size.height * 0.65;

    for (double i = 0; i <= size.width; i++) {
      path1.lineTo(
        i,
        baseHeight +
            math.sin((i / size.width * 2 * math.pi) + (animationValue * 2 * math.pi)) *
                20,
      );
      path2.lineTo(
        i,
        baseHeight +
            20 +
            math.cos((i / size.width * 2 * math.pi) + (animationValue * 2 * math.pi)) *
                25,
      );
    }

    path1.lineTo(size.width, size.height);
    path2.lineTo(size.width, size.height);

    canvas.drawPath(path2, paint2);
    canvas.drawPath(path1, paint1);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => true;
}

// ════════════════════════════════════════════════════════════
//  NAVIGATION BUTTON
// ════════════════════════════════════════════════════════════
class NavButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const NavButton({
    super.key,
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  State<NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<NavButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleCtrl;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.9,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    _scaleCtrl.reverse().then((_) => _scaleCtrl.forward());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleCtrl,
      child: GestureDetector(
        onTap: _handleTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isPrimary ? kObPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            boxShadow: widget.isPrimary
                ? [
                    BoxShadow(
                      color: kObPrimary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 20,
                color: widget.isPrimary ? kObWhite : kObBody,
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: widget.isPrimary ? kObWhite : kObBody,
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
//  LANGUAGE FLAG INDICATOR
// ════════════════════════════════════════════════════════════
class _LanguageFlagIndicator extends StatelessWidget {
  const _LanguageFlagIndicator({required this.isArabic});

  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: kObWhite.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kObMuted.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isArabic ? '🇸🇦' : '🇺🇸',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 6),
          Text(
            isArabic ? 'العربية' : 'English',
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kObBody),
          ),
        ],
      ),
    );
  }
}
