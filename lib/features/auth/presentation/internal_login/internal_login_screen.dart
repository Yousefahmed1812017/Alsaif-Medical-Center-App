import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class InternalLoginScreen extends StatefulWidget {
  const InternalLoginScreen({super.key});

  @override
  State<InternalLoginScreen> createState() => _InternalLoginScreenState();
}

class _InternalLoginScreenState extends State<InternalLoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await AuthService.login(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      // Navigate using the real userType from the API (employee, doctor, admin)
      context.push('/internal-otp/${user.roleKey}');
    } on ApiException catch (e) {
      if (!mounted) return;
      final isArabic = Localizations.localeOf(context).languageCode == 'ar';
      setState(() {
        _isLoading = false;
        _errorMessage = isArabic
            ? 'فشل تسجيل الدخول: ${e.message}'
            : 'Login failed: ${e.message}';
      });
    } catch (e) {
      if (!mounted) return;
      final isArabic = Localizations.localeOf(context).languageCode == 'ar';
      setState(() {
        _isLoading = false;
        _errorMessage = isArabic
            ? 'حدث خطأ في الاتصال. يرجى المحاولة مرة أخرى.'
            : 'Connection error. Please try again.';
      });
    }
  }

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
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
                const SizedBox(height: AppSpacing.s32),
                Text(
                  isArabic ? 'تسجيل الدخول' : 'Login',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary900,
                        fontWeight: FontWeight.w800,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.s48),

                // Email / Username
                AppTextField(
                  controller: _usernameController,
                  labelText: isArabic ? 'البريد الإلكتروني' : 'Email',
                  hintText: isArabic ? 'أدخل البريد الإلكتروني' : 'Enter your email',
                  prefixIcon: FontAwesomeIcons.envelope,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      value == null || value.isEmpty ? (isArabic ? 'مطلوب' : 'Required') : null,
                ),
                const SizedBox(height: AppSpacing.s24),

                // Password
                AppTextField(
                  controller: _passwordController,
                  labelText: isArabic ? 'كلمة المرور' : 'Password',
                  hintText: '••••••••',
                  prefixIcon: FontAwesomeIcons.lock,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _onLogin(),
                  validator: (value) =>
                      value == null || value.isEmpty ? (isArabic ? 'مطلوب' : 'Required') : null,
                  suffixIcon: IconButton(
                    icon: FaIcon(
                      _obscurePassword ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
                      size: 20,
                      color: AppColors.mutedText,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                Align(
                  alignment: isArabic ? Alignment.centerLeft : Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Navigate to forgot password screen
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      isArabic ? 'هل نسيت كلمة السر؟' : 'Forgot Password?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary700,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ),

                // Error message
                if (_errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.s16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s16,
                      vertical: AppSpacing.s12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.error.withAlpha(80)),
                    ),
                    child: Row(
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.circleExclamation,
                          size: 18,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: AppSpacing.s12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.error,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.s48),

                // Submit Button
                AppButton(
                  text: isArabic ? 'تسجيل الدخول' : 'Login',
                  onPressed: _onLogin,
                  isLoading: _isLoading,
                ),

                const SizedBox(height: AppSpacing.s48),
                
                // Powered by footer
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Powered by Win System',
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
      ),
    );
  }
}
