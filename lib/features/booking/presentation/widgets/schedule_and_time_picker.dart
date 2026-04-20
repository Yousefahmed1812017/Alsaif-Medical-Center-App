import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/time_slot_model.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loading_state.dart';
import '../../../../core/widgets/app_error_state.dart';

class ScheduleAndTimePicker extends StatefulWidget {
  const ScheduleAndTimePicker({
    super.key,
    required this.isArabic,
    required this.doctorId,
    required this.onSelectionComplete,
  });

  final bool isArabic;
  final int doctorId;
  final void Function(DateTime date, TimeSlotModel slot) onSelectionComplete;

  @override
  State<ScheduleAndTimePicker> createState() => _ScheduleAndTimePickerState();
}

class _ScheduleAndTimePickerState extends State<ScheduleAndTimePicker> {
  DateTime? _selectedDate;
  TimeSlotModel? _selectedSlot;

  List<TimeSlotModel> _slots = [];
  bool _isLoadingSlots = false;
  String? _error;

  late DateTime _activeMonth;
  late List<DateTime> _availableMonths;
  late List<DateTime> _monthDates;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _activeMonth = DateTime(now.year, now.month);
    
    // Generate next 6 months for selection
    _availableMonths = List.generate(6, (index) {
      return DateTime(now.year, now.month + index);
    });

    _generateDatesForMonth(_activeMonth);
    // Default to today
    _onDateSelected(now);
  }

  void _generateDatesForMonth(DateTime month) {
    final now = DateTime.now();
    final isCurrentMonth = month.year == now.year && month.month == now.month;
    
    // Start from today if it's the current month, else start from day 1
    final startDay = isCurrentMonth ? now.day : 1;
    final totalDaysInMonth = DateTime(month.year, month.month + 1, 0).day;

    _monthDates = List.generate(
      totalDaysInMonth - startDay + 1,
      (index) => DateTime(month.year, month.month, startDay + index),
    );
  }

  String _formatDateForApi(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _onDateSelected(DateTime date) async {
    setState(() {
      _selectedDate = date;
      _selectedSlot = null;
      _isLoadingSlots = true;
      _error = null;
      _slots = [];
    });

    try {
      final response = await ApiService.getDoctorTimeSlots(
        doctorId: widget.doctorId,
        appointmentDate: _formatDateForApi(date),
      );

      final slotsData = response['slots'] as List<dynamic>? ?? [];

      if (!mounted) return;
      setState(() {
        _slots = slotsData
            .map((e) => TimeSlotModel.fromJson(e as Map<String, dynamic>))
            .toList();
        _isLoadingSlots = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _isLoadingSlots = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoadingSlots = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.s24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Schedules (Dates) ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
                  child: Text(
                    widget.isArabic ? 'المواعيد المتاحة' : 'Schedules',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.headingText,
                        ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),

                // ── Months Scroll ──
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
                    itemCount: _availableMonths.length,
                    itemBuilder: (context, index) {
                      final m = _availableMonths[index];
                      final isSelected = m.year == _activeMonth.year && m.month == _activeMonth.month;
                      final monthNameEn = DateFormat('MMMM yyyy', 'en_US').format(m);
                      final monthNameAr = DateFormat('MMMM yyyy', 'ar_SA').format(m);
                      final monthName = widget.isArabic ? monthNameAr : monthNameEn;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _activeMonth = m;
                            _generateDatesForMonth(m);
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary500.withAlpha(20) : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.primary500.withAlpha(80) : AppColors.border,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              monthName,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? AppColors.primary500 : AppColors.mutedText,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // ── Days Scroll ──
                SizedBox(
                  height: 85,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
                    itemCount: _monthDates.length,
                    itemBuilder: (context, index) {
                      final date = _monthDates[index];
                      // Also reset the scroll to the start or keep it based on controller...
                      // for simplicity we just render them
                      final isSelected = _selectedDate?.year == date.year &&
                          _selectedDate?.month == date.month &&
                          _selectedDate?.day == date.day;

                      return _DateChip(
                        date: date,
                        isSelected: isSelected,
                        isArabic: widget.isArabic,
                        onTap: () => _onDateSelected(date),
                      );
                    },
                  ),
                ),

                const SizedBox(height: AppSpacing.s32),

                // ── Choose Time ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
                  child: Text(
                    widget.isArabic ? 'اختر الوقت' : 'Choose time',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.headingText,
                        ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),

                if (_isLoadingSlots)
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.s24),
                    child: AppLoadingState(
                      message: widget.isArabic
                          ? 'جاري البحث عن أوقات...'
                          : 'Loading times...',
                    ),
                  )
                else if (_error != null)
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.s24),
                    child: AppErrorState(
                      title: widget.isArabic ? 'خطأ' : 'Error',
                      message: _error!,
                      onRetry: () => _onDateSelected(_selectedDate!),
                    ),
                  )
                else if (_slots.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.s24),
                    child: Center(
                      child: Text(
                        widget.isArabic
                            ? 'عفواً، لا توجد مواعيد في هذا اليوم.'
                            : 'No times available on this date.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.mutedText,
                            ),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s20),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: AppSpacing.s10,
                        mainAxisSpacing: AppSpacing.s10,
                        childAspectRatio: 3.0,
                      ),
                      itemCount: _slots.length,
                      itemBuilder: (context, index) {
                        final slot = _slots[index];
                        final isSelected =
                            _selectedSlot?.time == slot.time;
                        return _TimeChip(
                          slot: slot,
                          isSelected: isSelected,
                          isArabic: widget.isArabic,
                          onTap: slot.isAvailable
                              ? () {
                                  setState(
                                      () => _selectedSlot = slot);
                                }
                              : null,
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),

        // ── Continue Button ──
        Container(
          padding: const EdgeInsets.all(AppSpacing.s24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(color: AppColors.border),
            ),
          ),
          child: AppButton(
            text: widget.isArabic ? 'متابعة' : 'Continue',
            onPressed: () {
              if (_selectedDate != null && _selectedSlot != null) {
                widget.onSelectionComplete(_selectedDate!, _selectedSlot!);
              }
            },
            isDisabled: _selectedDate == null || _selectedSlot == null,
            isFullWidth: true,
          ),
        ),
      ],
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.date,
    required this.isSelected,
    required this.isArabic,
    required this.onTap,
  });

  final DateTime date;
  final bool isSelected;
  final bool isArabic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // English abbreviated day "Sat", "Sun", etc.
    final dayStrEn = DateFormat('E', 'en_US').format(date);
    // Arabic full day, we can substring or use native "E" representation.
    final dayStrAr = DateFormat('E', 'ar_SA').format(date);
    final dayStr = isArabic ? dayStrAr : dayStrEn;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: AppSpacing.s12),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00155C) : Colors.white, // Custom dark blue from UI screenshot
          borderRadius: BorderRadius.circular(AppRadius.r16),
          border: Border.all(
            color: isSelected ? const Color(0xFF00155C) : AppColors.border,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF00155C).withAlpha(40),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayStr,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.headingText,
                  ),
            ),
            const SizedBox(height: 8.0),
            Text(
              '${date.day}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : AppColors.headingText,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.slot,
    required this.isSelected,
    required this.isArabic,
    required this.onTap,
  });

  final TimeSlotModel slot;
  final bool isSelected;
  final bool isArabic;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isAvailable = slot.isAvailable;

    // Style matching the admin panel screenshot
    const Color navyBlue = Color(0xFF00155C);

    final Color bgColor = isSelected
        ? navyBlue
        : isAvailable
            ? Colors.white
            : const Color(0xFFF5F5F5);

    final Color textColor = isSelected
        ? Colors.white
        : isAvailable
            ? AppColors.headingText
            : AppColors.mutedText;

    final Color borderColor = isSelected
        ? navyBlue
        : isAvailable
            ? AppColors.border
            : AppColors.border;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadius.r12),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: navyBlue.withAlpha(60),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            slot.displayTime(isArabic: isArabic),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: textColor,
                  decoration: !isAvailable
                      ? TextDecoration.lineThrough
                      : null,
                  decorationColor: AppColors.mutedText,
                ),
          ),
        ),
      ),
    );
  }
}
