import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/api_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_app_bar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';

/// Form to create a new Close Time request.
/// • ClinicId + DocId auto-filled from the logged-in doctor.
/// • FullDay toggle: "Y" → disable time fields, "N" → require them.
class CreateCloseTimeScreen extends StatefulWidget {
  const CreateCloseTimeScreen({super.key});

  @override
  State<CreateCloseTimeScreen> createState() => _CreateCloseTimeScreenState();
}

class _CreateCloseTimeScreenState extends State<CreateCloseTimeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isFullDay = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // ─── Date Picker ─────────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppColors.primary500,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // ─── Time Picker ─────────────────────────────────────────────────────
  Future<void> _pickTime({required bool isStart}) async {
    final initial = isStart
        ? (_startTime ?? const TimeOfDay(hour: 9, minute: 0))
        : (_endTime ?? const TimeOfDay(hour: 17, minute: 0));

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary500,
                ),
          ),
          child: child!,
        ),
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ─── Submit ──────────────────────────────────────────────────────────
  Future<void> _submit() async {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final user = AuthService.currentUser;
    if (user == null) return;

    if (_selectedDate == null) {
      _showSnackBar(isArabic ? 'يرجى اختيار التاريخ' : 'Please select a date');
      return;
    }

    if (!_isFullDay && (_startTime == null || _endTime == null)) {
      _showSnackBar(isArabic ? 'يرجى تحديد وقت البداية والنهاية' : 'Please select start and end time');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await ApiService.createCloseTimeRequest(
        clinicId: user.clinicCode ?? 0,
        docId: user.userId,
        startTime: _isFullDay ? '' : _formatTime(_startTime!),
        endTime: _isFullDay ? '' : _formatTime(_endTime!),
        closeTimeDate: _formatDate(_selectedDate!),
        fullDay: _isFullDay ? 'Y' : 'N',
        notes: _notesController.text.trim(),
        createdUserId: user.userId,
        createdUserBy: user.email ?? '',
      );

      if (!mounted) return;
      _showSnackBar(
        isArabic ? 'تم إرسال الطلب بنجاح ✓' : 'Request submitted successfully ✓',
        isError: false,
      );
      context.pop(true); // pop with success result
    } on ApiException catch (e) {
      _showSnackBar(e.message);
    } catch (e) {
      _showSnackBar(e.toString());
    }

    if (mounted) setState(() => _isSubmitting = false);
  }

  void _showSnackBar(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.r12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppAppBar(
        title: isArabic ? 'طلب إغلاق موعد' : 'Close Time Request',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Date Picker ────────────────────────────────────────
              _SectionLabel(label: isArabic ? 'تاريخ الإغلاق *' : 'Close Date *'),
              const SizedBox(height: AppSpacing.s8),
              _DatePickerField(
                value: _selectedDate != null ? _formatDate(_selectedDate!) : null,
                hint: isArabic ? 'اختر التاريخ' : 'Select date',
                onTap: _pickDate,
              ),

              const SizedBox(height: AppSpacing.s24),

              // ── Full Day Toggle ────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s16,
                  vertical: AppSpacing.s4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.r12),
                  border: Border.all(color: AppColors.border),
                ),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    isArabic ? 'إغلاق اليوم بالكامل' : 'Full Day Closure',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  subtitle: Text(
                    isArabic
                        ? 'سيتم إغلاق جميع المواعيد في هذا اليوم'
                        : 'All appointments will be closed on this day',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedText,
                        ),
                  ),
                  value: _isFullDay,
                  activeThumbColor: AppColors.primary500,
                  onChanged: (v) => setState(() => _isFullDay = v),
                ),
              ),

              const SizedBox(height: AppSpacing.s24),

              // ── Time Range ─────────────────────────────────────────
              _SectionLabel(
                label: isArabic ? 'وقت الإغلاق' : 'Close Time Range',
                dimmed: _isFullDay,
              ),
              const SizedBox(height: AppSpacing.s8),
              Row(
                children: [
                  Expanded(
                    child: _TimePickerField(
                      value: _startTime != null ? _formatTime(_startTime!) : null,
                      hint: isArabic ? 'من' : 'From',
                      onTap: _isFullDay ? null : () => _pickTime(isStart: true),
                      isDisabled: _isFullDay,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.s12),
                    child: FaIcon(FontAwesomeIcons.arrowRight, size: 14, color: AppColors.mutedText),
                  ),
                  Expanded(
                    child: _TimePickerField(
                      value: _endTime != null ? _formatTime(_endTime!) : null,
                      hint: isArabic ? 'إلى' : 'To',
                      onTap: _isFullDay ? null : () => _pickTime(isStart: false),
                      isDisabled: _isFullDay,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.s24),

              // ── Notes ──────────────────────────────────────────────
              _SectionLabel(label: isArabic ? 'ملاحظات' : 'Notes'),
              const SizedBox(height: AppSpacing.s8),
              AppTextField(
                controller: _notesController,
                hintText: isArabic ? 'أدخل سبب الإغلاق...' : 'Enter closure reason...',
                maxLines: 3,
                minLines: 3,
                textInputAction: TextInputAction.done,
              ),

              const SizedBox(height: AppSpacing.s40),

              // ── Submit ─────────────────────────────────────────────
              AppButton(
                text: isArabic ? 'إرسال الطلب' : 'Submit Request',
                onPressed: _submit,
                isLoading: _isSubmitting,
                icon: FontAwesomeIcons.paperPlane,
              ),

              const SizedBox(height: AppSpacing.s24),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Helper Widgets ───────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, this.dimmed = false});
  final String label;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: dimmed ? AppColors.mutedText : AppColors.headingText,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({this.value, required this.hint, required this.onTap});
  final String? value;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const FaIcon(FontAwesomeIcons.calendarDay, size: 18, color: AppColors.primary500),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Text(
                value ?? hint,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: value != null ? AppColors.headingText : AppColors.mutedText,
                      fontWeight: value != null ? FontWeight.w600 : FontWeight.w400,
                    ),
              ),
            ),
            const FaIcon(FontAwesomeIcons.chevronDown, size: 14, color: AppColors.mutedText),
          ],
        ),
      ),
    );
  }
}

class _TimePickerField extends StatelessWidget {
  const _TimePickerField({
    this.value,
    required this.hint,
    this.onTap,
    this.isDisabled = false,
  });
  final String? value;
  final String hint;
  final VoidCallback? onTap;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isDisabled ? 0.45 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s16),
          decoration: BoxDecoration(
            color: isDisabled ? AppColors.surfaceAlt : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.r12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              FaIcon(FontAwesomeIcons.clock, size: 16, color: isDisabled ? AppColors.mutedText : AppColors.primary500),
              const SizedBox(width: AppSpacing.s8),
              Text(
                value ?? hint,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: value != null && !isDisabled ? AppColors.headingText : AppColors.mutedText,
                      fontWeight: value != null ? FontWeight.w600 : FontWeight.w400,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
