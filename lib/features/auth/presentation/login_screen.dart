import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _nationalIdController = TextEditingController();

  late AnimationController _logoCtrl;
  late Animation<double> _logoFade;
  late Animation<Offset> _logoSlide;

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _logoFade = CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut);
    _logoSlide = Tween<Offset>(
      begin: const Offset(0, -0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut));
    _logoCtrl.forward();
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _phoneController.dispose();
    _nationalIdController.dispose();
    super.dispose();
  }

  void _onLogin() {
    // Navigate to OTP directly in mock mode — business logic unchanged
    context.push('/otp');
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const BackButton(),
        ),
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // ─── Animated Logo ─────────────────────────────────────
              FadeTransition(
                opacity: _logoFade,
                child: SlideTransition(
                  position: _logoSlide,
                  child: const _LogoHeader(),
                ),
              ),

              // ─── Welcome text ──────────────────────────────────────
              FadeTransition(
                opacity: _logoFade,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s24,
                  ),
                  child: Text(
                    isArabic ? 'تسجيل الدخول' : 'Login',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(
                          color: AppColors.primary900,
                          fontWeight: FontWeight.w800,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.s24),

              // ─── TabBar ────────────────────────────────────────────
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s24,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary100,
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(4),
                child: TabBar(
                  indicator: BoxDecoration(
                    color: AppColors.primary500,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary500.withAlpha(60),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.primary700,
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  dividerColor: Colors.transparent,
                  splashFactory: NoSplash.splashFactory,
                  tabs: [
                    Tab(text: isArabic ? 'رقم الجوال' : 'Phone Number'),
                    Tab(text: isArabic ? 'رقم الهوية' : 'National ID'),
                  ],
                ),
              ),

              // ─── Tab Content ───────────────────────────────────────
              Expanded(
                child: TabBarView(
                  children: [
                    _LoginTabContent(
                      isArabic: isArabic,
                      controller: _phoneController,
                      hintText: '05xxxxxxxx',
                      labelText: isArabic ? 'رقم الجوال' : 'Phone Number',
                      keyboardType: TextInputType.phone,
                      icon: FontAwesomeIcons.phone,
                      onContinue: _onLogin,
                    ),
                    _LoginTabContent(
                      isArabic: isArabic,
                      controller: _nationalIdController,
                      hintText: isArabic
                          ? 'أدخل رقم الهوية المكون من 10 أرقام'
                          : 'Enter 10-digit National ID',
                      labelText: isArabic ? 'رقم الهوية' : 'National ID',
                      keyboardType: TextInputType.number,
                      icon: FontAwesomeIcons.idCard,
                      onContinue: _onLogin,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              // Powered by footer
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Powered by',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.mutedText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    Image.asset(
                      'assets/images/LogoWinsystem.png',
                      height: 24,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  LOGO HEADER
// ════════════════════════════════════════════════════════════
class _LogoHeader extends StatelessWidget {
  const _LogoHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s24,
        AppSpacing.s32,
        AppSpacing.s24,
        AppSpacing.s20,
      ),
      child: Center(
        child: Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary500.withAlpha(40),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Image.asset(
            'assets/images/app_icon.png',
            fit: BoxFit.contain,
            errorBuilder: (ctx, err, stack) => const FaIcon(
              FontAwesomeIcons.hospital,
              color: AppColors.primary500,
              size: 52,
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  LOGIN TAB CONTENT
// ════════════════════════════════════════════════════════════
class _LoginTabContent extends StatelessWidget {
  const _LoginTabContent({
    required this.isArabic,
    required this.controller,
    required this.hintText,
    required this.labelText,
    required this.keyboardType,
    required this.icon,
    required this.onContinue,
  });

  final bool isArabic;
  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final TextInputType keyboardType;
  final dynamic icon;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s24,
        AppSpacing.s32,
        AppSpacing.s24,
        AppSpacing.s24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Field label
          Padding(
            padding: const EdgeInsets.only(
              bottom: AppSpacing.s8,
              left: AppSpacing.s4,
              right: AppSpacing.s4,
            ),
            child: Text(
              labelText,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
            ),
          ),

          // Field
          CustomInputField(
            controller: controller,
            hintText: hintText,
            icon: icon,
            keyboardType: keyboardType,
          ),

          const SizedBox(height: AppSpacing.s32),

          AppButton(
            text: isArabic ? 'متابعة' : 'Continue',
            onPressed: onContinue,
            isFullWidth: true,
          ),

          const SizedBox(height: AppSpacing.s16),

          // Footer help text
          Center(
            child: Text(
              isArabic
                  ? 'سنرسل لك رمز التحقق على جوالك'
                  : "We'll send you a verification code",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedText,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  CUSTOM INPUT FIELD  (icon on leading side / right in RTL)
// ════════════════════════════════════════════════════════════
class CustomInputField extends StatelessWidget {
  const CustomInputField({
    super.key,
    this.controller,
    required this.hintText,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
  });

  final TextEditingController? controller;
  final String hintText;
  final dynamic icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      cursorColor: AppColors.primary500,
      style: const TextStyle(
        fontSize: 15,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Padding(
          padding: const EdgeInsetsDirectional.only(start: 16, end: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(
                icon,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 48,
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
