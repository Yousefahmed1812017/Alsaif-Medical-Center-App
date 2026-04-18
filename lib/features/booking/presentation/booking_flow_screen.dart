import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/clinic_model.dart';
import '../../../core/models/doctor_model.dart';
import '../../../core/models/patient_model.dart';
import '../../../core/models/time_slot_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_app_bar.dart';
import 'widgets/booking_summary.dart';
import 'widgets/clinic_picker.dart';
import 'widgets/doctor_picker.dart';
import 'widgets/patient_picker_sheet.dart';
import 'widgets/schedule_and_time_picker.dart';

/// Multi-step booking flow.
///
/// • Employee / Admin → Full flow (Clinic → Doctor → Calendar → Time → Patient → Confirm)
/// • Doctor            → Skips to Calendar (uses own schedule)
class BookingFlowScreen extends StatefulWidget {
  const BookingFlowScreen({super.key});

  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  // ─── Flow Index ───────────────────────────────────────────────────────
  // 0: Clinic  1: Doctor  2: Calendar  3: Time Slots  4: Patient  5: Summary
  int _currentStep = 0;

  // ─── Selected Data ────────────────────────────────────────────────────
  ClinicModel? _selectedClinic;
  DoctorModel? _selectedDoctor;
  DateTime? _selectedDate;
  TimeSlotModel? _selectedSlot;
  PatientModel? _selectedPatient;

  // ─── Role Check ───────────────────────────────────────────────────────
  bool get _isDoctor =>
      AuthService.currentUser?.userType.toUpperCase() == 'DOCTOR';

  int get _totalSteps => _isDoctor ? 4 : 6;

  @override
  void initState() {
    super.initState();
    if (_isDoctor) {
      // Skip clinic + doctor steps → start at calendar (step index 0 for doctor)
      _currentStep = 0; // Will be mapped to Calendar
    }
  }

  /// Maps the internal step index to the actual content based on role.
  int get _effectiveStep {
    if (_isDoctor) {
      // Doctor steps: Calendar(0) → TimeSlots(1) → Patient(2) → Summary(3)
      return _currentStep + 2; // offset by 2 to align with full flow indices
    }
    return _currentStep;
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      context.pop();
    }
  }

  // ─── Step Labels ──────────────────────────────────────────────────────
  List<_StepInfo> _getSteps(bool isArabic) {
    final allSteps = [
      _StepInfo(
        icon: FontAwesomeIcons.hospital,
        labelAr: 'العيادة',
        labelEn: 'Clinic',
      ),
      _StepInfo(
        icon: FontAwesomeIcons.userDoctor,
        labelAr: 'الطبيب',
        labelEn: 'Doctor',
      ),
      _StepInfo(
        icon: FontAwesomeIcons.calendarDays,
        labelAr: 'الموعد',
        labelEn: 'Schedule',
      ),
      _StepInfo(
        icon: FontAwesomeIcons.userInjured,
        labelAr: 'المريض',
        labelEn: 'Patient',
      ),
      _StepInfo(
        icon: FontAwesomeIcons.clipboardCheck,
        labelAr: 'التأكيد',
        labelEn: 'Confirm',
      ),
    ];

    if (_isDoctor) {
      // Skip Clinic + Doctor
      return allSteps.sublist(2);
    }
    return allSteps;
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final user = AuthService.currentUser!;
    final steps = _getSteps(isArabic);

    return PopScope(
      canPop: _currentStep == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _previousStep();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppAppBar(
          title: isArabic ? 'حجز موعد' : 'Book Appointment',
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (_currentStep > 0) {
                _previousStep();
              } else {
                context.pop();
              }
            },
          ),
        ),
        body: Column(
          children: [
            // ── Step Indicator ─────────────────────────────────────────
            _StepIndicator(
              steps: steps,
              currentStep: _currentStep,
              isArabic: isArabic,
            ),

            // ── Step Content ───────────────────────────────────────────
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildStepContent(isArabic, user),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(bool isArabic, dynamic user) {
    switch (_effectiveStep) {
      case 0:
        return ClinicPicker(
          key: const ValueKey('clinic'),
          isArabic: isArabic,
          onClinicSelected: (clinic) {
            setState(() => _selectedClinic = clinic);
            _nextStep();
          },
        );
      case 1:
        return DoctorPicker(
          key: const ValueKey('doctor'),
          isArabic: isArabic,
          clinicId: _selectedClinic?.clinicId,
          onDoctorSelected: (doctor) {
            setState(() => _selectedDoctor = doctor);
            _nextStep();
          },
        );
      case 2:
        final docId = _isDoctor ? user.userId : _selectedDoctor!.docId;
        return ScheduleAndTimePicker(
          key: ValueKey('schedule_$docId'),
          isArabic: isArabic,
          doctorId: docId,
          onSelectionComplete: (date, slot) {
            setState(() {
              _selectedDate = date;
              _selectedSlot = slot;
            });
            _nextStep();
          },
        );
      case 3:
        return PatientPickerSheet(
          key: const ValueKey('patient'),
          isArabic: isArabic,
          onPatientSelected: (patient) {
            setState(() => _selectedPatient = patient);
            _nextStep();
          },
          onBack: _previousStep,
        );
      case 4:
        return BookingSummary(
          key: const ValueKey('summary'),
          isArabic: isArabic,
          clinic: _selectedClinic,
          doctor: _selectedDoctor,
          selectedDate: _selectedDate!,
          selectedSlot: _selectedSlot!,
          patient: _selectedPatient!,
          isDoctor: _isDoctor,
          onConfirm: _submitBooking,
          onBack: _previousStep,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  // ─── Submit ───────────────────────────────────────────────────────────
  Future<void> _submitBooking(String notes) async {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final user = AuthService.currentUser!;

    final docId = _isDoctor ? user.userId : _selectedDoctor!.docId;
    String rawClinic = _isDoctor
        ? (user.clinicCode?.toString() ?? '0')
        : (_selectedClinic?.clinicId ?? '0');
    if (rawClinic != '0' && !rawClinic.contains('.')) {
      rawClinic = '$rawClinic.00';
    }
    final clinicId = rawClinic;

    try {
      await ApiService.createAppointment(
        docId: docId,
        clinicId: clinicId,
        patientId: int.tryParse(_selectedPatient!.patientCode ?? '0') ?? 0,
        reDate: _formatDate(_selectedDate!),
        reTime: _selectedSlot!.time,
        notes: notes,
        createdBy: user.displayName(),
        createdByUserId: user.userId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic ? 'تم حجز الموعد بنجاح ✓' : 'Appointment booked successfully ✓',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.r12),
          ),
        ),
      );

      context.pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.r12),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.r12),
          ),
        ),
      );
    }
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

// ─── Step Info ──────────────────────────────────────────────────────────────

class _StepInfo {
  final dynamic icon;
  final String labelAr;
  final String labelEn;

  const _StepInfo({
    required this.icon,
    required this.labelAr,
    required this.labelEn,
  });

  String label(bool isArabic) => isArabic ? labelAr : labelEn;
}

// ─── Step Indicator ─────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.steps,
    required this.currentStep,
    required this.isArabic,
  });

  final List<_StepInfo> steps;
  final int currentStep;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(steps.length, (index) {
            final isCompleted = index < currentStep;
            final isCurrent = index == currentStep;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Step circle + label
                _StepDot(
                  step: steps[index],
                  isCompleted: isCompleted,
                  isCurrent: isCurrent,
                  isArabic: isArabic,
                  index: index,
                ),
                // Connector line
                if (index < steps.length - 1)
                  Container(
                    width: 24,
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.primary500
                          : AppColors.border,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.step,
    required this.isCompleted,
    required this.isCurrent,
    required this.isArabic,
    required this.index,
  });

  final _StepInfo step;
  final bool isCompleted;
  final bool isCurrent;
  final bool isArabic;
  final int index;

  @override
  Widget build(BuildContext context) {
    final color = isCompleted || isCurrent
        ? AppColors.primary500
        : AppColors.mutedText;
    final bgColor = isCurrent
        ? AppColors.primary500.withAlpha(25)
        : isCompleted
            ? AppColors.primary500.withAlpha(15)
            : Colors.transparent;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: isCurrent ? AppColors.primary500 : color.withAlpha(60),
              width: isCurrent ? 2 : 1,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const FaIcon(FontAwesomeIcons.check,
                    size: 13, color: AppColors.primary500)
                : FaIcon(step.icon, size: 13, color: color),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          step.label(isArabic),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 10,
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                color: isCurrent ? AppColors.primary500 : AppColors.mutedText,
              ),
        ),
      ],
    );
  }
}
