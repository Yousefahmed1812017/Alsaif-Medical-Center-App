import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/models/clinic_model.dart';
import '../../../../core/models/doctor_model.dart';
import '../../../../core/models/patient_model.dart';
import '../../../../core/models/time_slot_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

/// Step 6 — summary and confirmation before creating the appointment.
class BookingSummary extends StatefulWidget {
  const BookingSummary({
    super.key,
    required this.isArabic,
    this.clinic,
    this.doctor,
    required this.selectedDate,
    required this.selectedSlot,
    required this.patient,
    required this.isDoctor,
    required this.onConfirm,
    required this.onBack,
  });

  final bool isArabic;
  final ClinicModel? clinic;
  final DoctorModel? doctor;
  final DateTime selectedDate;
  final TimeSlotModel selectedSlot;
  final PatientModel patient;
  final bool isDoctor;
  final Future<void> Function(String notes) onConfirm;
  final VoidCallback onBack;

  @override
  State<BookingSummary> createState() => _BookingSummaryState();
}

class _BookingSummaryState extends State<BookingSummary> {
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _handleConfirm() async {
    setState(() => _isSubmitting = true);
    await widget.onConfirm(_notesController.text.trim());
    if (mounted) setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final patientName = widget.isArabic
        ? (widget.patient.patientName ?? widget.patient.patientNameEn ?? '')
        : (widget.patient.patientNameEn ?? widget.patient.patientName ?? '');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.success.withAlpha(20),
                  borderRadius: BorderRadius.circular(AppRadius.r12),
                ),
                child: const Center(
                  child: FaIcon(FontAwesomeIcons.clipboardCheck,
                      size: 18, color: AppColors.success),
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isArabic ? 'تأكيد الحجز' : 'Confirm Booking',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.headingText,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.isArabic
                          ? 'راجع التفاصيل قبل التأكيد'
                          : 'Review the details before confirming',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.mutedText,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.s24),

          // Summary Card
          Container(
            padding: const EdgeInsets.all(AppSpacing.s20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.r16),
              border: Border.all(color: AppColors.border.withAlpha(120)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary500.withAlpha(8),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Clinic
                if (!widget.isDoctor && widget.clinic != null)
                  _SummaryRow(
                    icon: FontAwesomeIcons.hospital,
                    label: widget.isArabic ? 'العيادة' : 'Clinic',
                    value: widget.clinic!.displayName(isArabic: widget.isArabic),
                  ),

                if (!widget.isDoctor && widget.clinic != null)
                  const Divider(height: 24, color: AppColors.divider),

                // Doctor
                if (!widget.isDoctor && widget.doctor != null)
                  _SummaryRow(
                    icon: FontAwesomeIcons.userDoctor,
                    label: widget.isArabic ? 'الطبيب' : 'Doctor',
                    value: widget.doctor!.displayName(isArabic: widget.isArabic),
                  ),

                if (!widget.isDoctor && widget.doctor != null)
                  const Divider(height: 24, color: AppColors.divider),

                // Date
                _SummaryRow(
                  icon: FontAwesomeIcons.calendarDay,
                  label: widget.isArabic ? 'التاريخ' : 'Date',
                  value: _formatDate(widget.selectedDate),
                ),

                const Divider(height: 24, color: AppColors.divider),

                // Time
                _SummaryRow(
                  icon: FontAwesomeIcons.clock,
                  label: widget.isArabic ? 'الوقت' : 'Time',
                  value: widget.selectedSlot.displayTime(isArabic: widget.isArabic),
                ),

                const Divider(height: 24, color: AppColors.divider),

                // Patient
                _SummaryRow(
                  icon: FontAwesomeIcons.userInjured,
                  label: widget.isArabic ? 'المريض' : 'Patient',
                  value: patientName,
                ),

                _SummaryRow(
                  icon: FontAwesomeIcons.fileLines,
                  label: widget.isArabic ? 'رقم الملف' : 'MR#',
                  value: widget.patient.patientCode ?? '—',
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.s24),

          // Notes
          Text(
            widget.isArabic ? 'ملاحظات (اختياري)' : 'Notes (optional)',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.headingText,
                ),
          ),
          const SizedBox(height: AppSpacing.s8),
          AppTextField(
            controller: _notesController,
            hintText: widget.isArabic
                ? 'أضف ملاحظات للحجز...'
                : 'Add notes for the appointment...',
            maxLines: 3,
            minLines: 3,
            textInputAction: TextInputAction.done,
          ),

          const SizedBox(height: AppSpacing.s32),

          // Confirm Button
          AppButton(
            text: widget.isArabic ? 'تأكيد الحجز' : 'Confirm Booking',
            onPressed: _handleConfirm,
            isLoading: _isSubmitting,
            icon: FontAwesomeIcons.check,
          ),

          const SizedBox(height: AppSpacing.s12),

          // Back Button
          TextButton.icon(
            onPressed: widget.onBack,
            icon: FaIcon(
              widget.isArabic
                  ? FontAwesomeIcons.arrowRight
                  : FontAwesomeIcons.arrowLeft,
              size: 14,
              color: AppColors.mutedText,
            ),
            label: Text(
              widget.isArabic ? 'رجوع' : 'Go Back',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.mutedText,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),

          const SizedBox(height: AppSpacing.s24),
        ],
      ),
    );
  }
}

// ─── Summary Row ───────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final dynamic icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          FaIcon(icon, size: 15, color: AppColors.primary500),
          const SizedBox(width: AppSpacing.s12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedText,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.headingText,
                  ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
