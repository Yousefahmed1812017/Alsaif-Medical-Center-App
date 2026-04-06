import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/widgets/app_button.dart';

class InternalOtpVerificationScreen extends StatefulWidget {
  final String role;
  const InternalOtpVerificationScreen({super.key, required this.role});

  @override
  State<InternalOtpVerificationScreen> createState() => _InternalOtpVerificationScreenState();
}

class _InternalOtpVerificationScreenState extends State<InternalOtpVerificationScreen> {
  final _pinController = TextEditingController();
  final int _resendTimeout = 60;
  int _secondsRemaining = 0;
  Timer? _timer;
  bool _isLoading = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() => _secondsRemaining = _resendTimeout);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  void _onResendOtp() {
    _startTimer();
    setState(() => _errorText = null);
  }

  void _onVerify() async {
    if (_pinController.text.length != 6) {
      setState(() => _errorText = 'Enter 6 digits');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    await Future.delayed(const Duration(seconds: 1)); // Mock Network
    
    if (!mounted) return;
    setState(() => _isLoading = false);
    
    // Navigate to role-based dashboard safely
    context.go('/internal-dashboard/${widget.role}');
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 64,
      textStyle: Theme.of(context).textTheme.headlineMedium,
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.r12),
        border: Border.all(color: AppColors.border),
      ),
    );

    return Scaffold(
      appBar: AppAppBar(
        title: isArabic ? 'التحقق بخطوتين' : '2-Step Verification',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.s16),
              const Center(
                child: FaIcon(
                  FontAwesomeIcons.mobileScreenButton,
                  size: 64,
                  color: AppColors.primary500,
                ),
              ),
              const SizedBox(height: AppSpacing.s32),
              Text(
                isArabic ? 'رمز التحقق للموظفين' : 'Staff Verification',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                isArabic
                    ? 'تم إرسال رمز أمان إلى رقم جوالك المسجل بالنظام.'
                    : 'A security code was sent to your registered staff phone number.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.mutedText,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s48),
              
              Directionality(
                textDirection: TextDirection.ltr,
                child: Center(
                  child: Pinput(
                    length: 6,
                    controller: _pinController,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration?.copyWith(
                        border: Border.all(color: AppColors.primary500),
                      ),
                    ),
                    errorPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration?.copyWith(
                        border: Border.all(color: AppColors.error),
                      ),
                    ),
                    pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                    showCursor: true,
                    onCompleted: (pin) => _onVerify(),
                  ),
                ),
              ),

              if (_errorText != null) ...[
                const SizedBox(height: AppSpacing.s12),
                Text(
                  _errorText!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.error,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
              
              const SizedBox(height: AppSpacing.s48),
              AppButton(
                text: isArabic ? 'تأكيد الرمز' : 'Confirm Code',
                onPressed: _onVerify,
                isLoading: _isLoading,
                isFullWidth: true,
              ),
              const SizedBox(height: AppSpacing.s24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isArabic ? 'لم يصلك الرمز؟ ' : 'Didn\'t receive it? ',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.mutedText,
                        ),
                  ),
                  if (_secondsRemaining > 0)
                    Text(
                      '00:${_secondsRemaining.toString().padLeft(2, '0')}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.headingText,
                            fontWeight: FontWeight.bold,
                          ),
                    )
                  else
                    InkWell(
                      onTap: _isLoading ? null : _onResendOtp,
                      child: Text(
                        isArabic ? 'إعادة الإرسال' : 'Resend',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppColors.primary500,
                            ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
