import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../main.dart';
import '../../../core/services/storage_service.dart';

// ─── Palette ────────────────────────────────────────────────
const Color kLsBlue50  = Color(0xFFEFF3FF);
const Color kLsBlue200 = Color(0xFFBDD7E7);
const Color kLsBlue400 = Color(0xFF6BAED6);
const Color kLsBlue500 = Color(0xFF3182BD);
const Color kLsBlue700 = Color(0xFF08519C);
const Color kLsWhite   = Color(0xFFFFFFFF);
const Color kLsMuted   = Color(0xFF8E9BAE);
const Color kLsBody    = Color(0xFF3A4356);

// ════════════════════════════════════════════════════════════
//  LANGUAGE SELECTION SCREEN
// ════════════════════════════════════════════════════════════
class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      LanguageSelectionScreenState();
}

class LanguageSelectionScreenState extends State<LanguageSelectionScreen>
    with SingleTickerProviderStateMixin {
  String selectedCode = 'ar';

  late AnimationController fadeCtrl;
  late Animation<double> fadeAnim;
  late Animation<Offset> slideAnim;

  @override
  void initState() {
    super.initState();
    selectedCode = StorageService.selectedLanguage ?? 'ar';

    fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    fadeAnim = CurvedAnimation(parent: fadeCtrl, curve: Curves.easeOut);
    slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: fadeCtrl, curve: Curves.easeOut));
    fadeCtrl.forward();
  }

  @override
  void dispose() {
    fadeCtrl.dispose();
    super.dispose();
  }

  void selectLanguage(String code) {
    setState(() => selectedCode = code);
    appLocaleNotifier.value = Locale(code);
  }

  Future<void> onContinue() async {
    await StorageService.setSelectedLanguage(selectedCode);
    if (!mounted) return;
    // Go to onboarding if not done yet, otherwise user-type
    if (!StorageService.isOnboardingCompleted) {
      context.go('/onboarding');
    } else {
      context.go('/user-type');
    }
  }

  bool get isAr => selectedCode == 'ar';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: kLsWhite,
        body: SafeArea(
          child: FadeTransition(
            opacity: fadeAnim,
            child: SlideTransition(
              position: slideAnim,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 52),

                    // ── App logo / icon ──────────────────────
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: kLsBlue700,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: kLsBlue700.withValues(alpha: 0.28),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.local_hospital_rounded,
                          color: kLsWhite,
                          size: 36,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── App name ────────────────────────────
                    Text(
                      isAr ? 'مجمع السيف الطبي' : 'Alsaif Medical Center',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kLsMuted,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Title ───────────────────────────────
                    Text(
                      isAr ? 'اختر اللغة' : 'Choose your language',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: kLsBlue700,
                        height: 1.25,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ── Subtitle ────────────────────────────
                    Text(
                      isAr
                          ? 'اختر لغتك المفضلة لمتابعة التطبيق'
                          : 'Select your preferred language to continue',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: kLsMuted,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 52),

                    // ── Language cards grid ──────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: LangCard(
                            flag: '🇸🇦',
                            nameTop: 'العربية',
                            nameBottom: 'Arabic',
                            code: 'ar',
                            isSelected: selectedCode == 'ar',
                            onTap: () => selectLanguage('ar'),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: LangCard(
                            flag: '🇺🇸',
                            nameTop: 'English',
                            nameBottom: 'الإنجليزية',
                            code: 'en',
                            isSelected: selectedCode == 'en',
                            onTap: () => selectLanguage('en'),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // ── Continue button ──────────────────────
                    ContinueButton(
                      label: isAr ? 'متابعة' : 'Continue',
                      onTap: onContinue,
                    ),
                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  LANGUAGE CARD  (hexagon flag + name)
// ════════════════════════════════════════════════════════════
class LangCard extends StatefulWidget {
  const LangCard({
    super.key,
    required this.flag,
    required this.nameTop,
    required this.nameBottom,
    required this.code,
    required this.isSelected,
    required this.onTap,
  });

  final String flag;
  final String nameTop;
  final String nameBottom;
  final String code;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<LangCard> createState() => LangCardState();
}

class LangCardState extends State<LangCard>
    with SingleTickerProviderStateMixin {
  late AnimationController scaleCtrl;
  late Animation<double> scaleAnim;

  @override
  void initState() {
    super.initState();
    scaleCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 150),
        lowerBound: 0.94,
        upperBound: 1.0,
        value: 1.0);
    scaleAnim = scaleCtrl;
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
      scale: scaleAnim,
      child: GestureDetector(
        onTap: handleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 12),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? kLsBlue700.withValues(alpha: 0.06)
                : kLsWhite,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color:
                  widget.isSelected ? kLsBlue700 : kLsBlue200,
              width: widget.isSelected ? 2.0 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isSelected
                    ? kLsBlue700.withValues(alpha: 0.12)
                    : kLsBlue200.withValues(alpha: 0.30),
                blurRadius: widget.isSelected ? 20 : 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Hexagonal flag container
              HexFlagWidget(
                flag: widget.flag,
                isSelected: widget.isSelected,
              ),
              const SizedBox(height: 18),

              // Primary language name
              Text(
                widget.nameTop,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: widget.isSelected ? kLsBlue700 : kLsBody,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),

              // Secondary name
              Text(
                widget.nameBottom,
                style: TextStyle(
                  fontSize: 12,
                  color: widget.isSelected ? kLsBlue500 : kLsMuted,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 14),

              // Selection indicator dot
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: widget.isSelected ? 24 : 10,
                height: 6,
                decoration: BoxDecoration(
                  color: widget.isSelected ? kLsBlue700 : kLsBlue200,
                  borderRadius: BorderRadius.circular(3),
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
//  HEXAGONAL FLAG WIDGET
// ════════════════════════════════════════════════════════════
class HexFlagWidget extends StatelessWidget {
  const HexFlagWidget(
      {super.key, required this.flag, required this.isSelected});

  final String flag;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Hexagon background
          CustomPaint(
            size: const Size(80, 80),
            painter: HexPainter(
              color: isSelected
                  ? kLsBlue700.withValues(alpha: 0.10)
                  : kLsBlue50,
              borderColor: isSelected ? kLsBlue700 : kLsBlue200,
              borderWidth: isSelected ? 2.0 : 1.2,
            ),
          ),
          // Flag emoji
          Text(
            flag,
            style: const TextStyle(fontSize: 34),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  HEXAGON PAINTER
// ════════════════════════════════════════════════════════════
class HexPainter extends CustomPainter {
  const HexPainter({
    required this.color,
    required this.borderColor,
    required this.borderWidth,
  });

  final Color color;
  final Color borderColor;
  final double borderWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width / 2 - borderWidth;

    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 30) * (3.14159265 / 180);
      final x = cx + r * _cos(angle);
      final y = cy + r * _sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Fill
    canvas.drawPath(path, Paint()..color = color);

    // Border
    canvas.drawPath(
      path,
      Paint()
        ..color = borderColor
        ..strokeWidth = borderWidth
        ..style = PaintingStyle.stroke,
    );
  }

  double _cos(double angle) {
    // Use dart:math via import above
    return _mathCos(angle);
  }

  double _sin(double angle) {
    return _mathSin(angle);
  }

  // Simple trig (avoids dart:math import in painter)
  static double _mathCos(double x) {
    // Taylor series approximation — good enough for 6 angles
    double result = 0;
    double term = 1;
    double xSq = x * x;
    result += term;
    term *= -xSq / 2;
    result += term;
    term *= -xSq / 12;
    result += term;
    term *= -xSq / 30;
    result += term;
    term *= -xSq / 56;
    result += term;
    return result;
  }

  static double _mathSin(double x) {
    double result = 0;
    double term = x;
    double xSq = x * x;
    result += term;
    term *= -xSq / 6;
    result += term;
    term *= -xSq / 20;
    result += term;
    term *= -xSq / 42;
    result += term;
    term *= -xSq / 72;
    result += term;
    return result;
  }

  @override
  bool shouldRepaint(HexPainter old) =>
      old.color != color ||
      old.borderColor != borderColor ||
      old.borderWidth != borderWidth;
}

// ════════════════════════════════════════════════════════════
//  CONTINUE BUTTON
// ════════════════════════════════════════════════════════════
class ContinueButton extends StatefulWidget {
  const ContinueButton(
      {super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<ContinueButton> createState() => ContinueButtonState();
}

class ContinueButtonState extends State<ContinueButton>
    with SingleTickerProviderStateMixin {
  late AnimationController pressCtrl;

  @override
  void initState() {
    super.initState();
    pressCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 120),
        lowerBound: 0.96,
        upperBound: 1.0,
        value: 1.0);
  }

  @override
  void dispose() {
    pressCtrl.dispose();
    super.dispose();
  }

  void handleTap() {
    pressCtrl.reverse().then((_) => pressCtrl.forward());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: pressCtrl,
      child: GestureDetector(
        onTap: handleTap,
        child: Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [kLsBlue500, kLsBlue700],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: kLsBlue700.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: const TextStyle(
                color: kLsWhite,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
