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
                  child: Column(
                    children: [
                      Text(
                        isArabic ? 'مرحباً بعودتك' : 'Welcome Back',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: AppColors.primary600,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      Text(
                        isArabic
                            ? 'يرجى إدخال بياناتك للمتابعة'
                            : 'Please enter your details to continue',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.mutedText,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
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
                  color: AppColors.primary50,
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
                  unselectedLabelColor: AppColors.primary600,
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
          'assets/images/logo.png',
          fit: BoxFit.contain,
          errorBuilder: (ctx, err, stack) => const FaIcon(
            FontAwesomeIcons.hospital,
            color: AppColors.primary500,
            size: 52,
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
class CustomInputField extends StatefulWidget {
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
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isFocused ? AppColors.primary500 : AppColors.divider,
          width: _isFocused ? 1.6 : 1.0,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: AppColors.primary500.withAlpha(30),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(5),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText,
        cursorColor: AppColors.primary500,
        style: const TextStyle(
          fontSize: 15,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(
            color: AppColors.mutedText,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          // Icon on leading side — in RTL this renders on the RIGHT.
          prefixIcon: Padding(
            padding: const EdgeInsetsDirectional.only(
              start: 16,
              end: 12,
            ),
            child: FaIcon(
              widget.icon,
              size: 18,
              color: _isFocused
                  ? AppColors.primary500
                  : AppColors.textSecondary,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 44,
            minHeight: 44,
          ),
          suffixIcon: widget.suffixIcon,
          // Gap between icon and text + vertical breathing room
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
        ),
      ),
    );
  }
}
