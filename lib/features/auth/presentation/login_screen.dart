import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_app_bar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _nationalIdController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _nationalIdController.dispose();
    super.dispose();
  }

  void _onLogin() {
    // Navigate to OTP directly in mock mode
    context.push('/otp');
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppAppBar(
          title: isArabic ? 'تسجيل الدخول' : 'Sign In',
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Custom TabBar
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.border, width: 1),
                  ),
                ),
                child: TabBar(
                  tabs: [
                    Tab(text: isArabic ? 'رقم الجوال' : 'Phone Number'),
                    Tab(text: isArabic ? 'رقم الهوية' : 'National ID'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    // Phone Number Tab
                    _LoginTabContent(
                      isArabic: isArabic,
                      controller: _phoneController,
                      hintText: isArabic ? '05xxxxxxxx' : '05xxxxxxxx',
                      labelText: isArabic ? 'رقم الجوال' : 'Phone Number',
                      keyboardType: TextInputType.phone,
                      icon: FontAwesomeIcons.phone,
                      onContinue: _onLogin,
                    ),
                    // National ID Tab
                    _LoginTabContent(
                      isArabic: isArabic,
                      controller: _nationalIdController,
                      hintText: isArabic ? 'أدخل رقم الهوية المكون من 10 أرقام' : 'Enter 10-digit National ID',
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
      padding: const EdgeInsets.all(AppSpacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s16),
          Text(
            isArabic
                ? 'مرحباً بعودتك!'
                : 'Welcome back!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.headingText,
                ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            isArabic
                ? 'يرجى إدخال بياناتك للمتابعة.'
                : 'Please enter your details to proceed.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.mutedText,
                ),
          ),
          const SizedBox(height: AppSpacing.s48),
          AppTextField(
            controller: controller,
            hintText: hintText,
            labelText: labelText,
            prefixIcon: icon,
            keyboardType: keyboardType,
          ),
          const SizedBox(height: AppSpacing.s48),
          AppButton(
            text: isArabic ? 'متابعة' : 'Continue',
            onPressed: onContinue,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }
}
