import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/models/time_slot_model.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_loading_state.dart';
import '../../../../core/widgets/app_error_state.dart';

/// Step 4 — pick a time slot for the selected date.
class TimeSlotsGrid extends StatefulWidget {
  const TimeSlotsGrid({
    super.key,
    required this.isArabic,
    required this.doctorId,
    required this.selectedDate,
    required this.onSlotSelected,
    required this.onBack,
  });

  final bool isArabic;
  final int doctorId;
  final DateTime selectedDate;
  final ValueChanged<TimeSlotModel> onSlotSelected;
  final VoidCallback onBack;

  @override
  State<TimeSlotsGrid> createState() => _TimeSlotsGridState();
}

class _TimeSlotsGridState extends State<TimeSlotsGrid> {
  List<TimeSlotModel> _slots = [];
  bool _isLoading = true;
  String? _error;
  int _totalSlots = 0;
  int _availableSlots = 0;
  int _reservedSlots = 0;

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _loadSlots() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.getDoctorTimeSlots(
        doctorId: widget.doctorId,
        appointmentDate: _formatDate(widget.selectedDate),
      );

      final slotsData = response['slots'] as List<dynamic>? ?? [];
      final summary = response['summary'] as Map<String, dynamic>?;

      setState(() {
        _slots = slotsData
            .map((e) => TimeSlotModel.fromJson(e as Map<String, dynamic>))
            .toList();
        _totalSlots = summary?['totalSlots'] as int? ?? _slots.length;
        _availableSlots = summary?['availableSlots'] as int? ?? 0;
        _reservedSlots = summary?['reservedSlots'] as int? ?? 0;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary500.withAlpha(20),
                  borderRadius: BorderRadius.circular(AppRadius.r12),
                ),
                child: const Center(
                  child: FaIcon(FontAwesomeIcons.clock,
                      size: 18, color: AppColors.primary500),
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isArabic ? 'اختر الوقت' : 'Select Time',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.headingText,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(widget.selectedDate),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primary500,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.s16),

          // Summary Bar
          if (!_isLoading && _error == null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s16,
                vertical: AppSpacing.s12,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(AppRadius.r12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SummaryChip(
                    value: '$_totalSlots',
                    label: widget.isArabic ? 'الكل' : 'Total',
                    color: AppColors.bodyText,
                  ),
                  _SummaryChip(
                    value: '$_availableSlots',
                    label: widget.isArabic ? 'متاح' : 'Available',
                    color: AppColors.success,
                  ),
                  _SummaryChip(
                    value: '$_reservedSlots',
                    label: widget.isArabic ? 'محجوز' : 'Reserved',
                    color: AppColors.error,
                  ),
                ],
              ),
            ),

          const SizedBox(height: AppSpacing.s16),

          // Slots Grid
          Expanded(
            child: _isLoading
                ? AppLoadingState(
                    message: widget.isArabic
                        ? 'جاري تحميل المواعيد...'
                        : 'Loading time slots...',
                  )
                : _error != null
                    ? AppErrorState(
                        title: widget.isArabic ? 'خطأ' : 'Error',
                        message: _error!,
                        onRetry: _loadSlots,
                      )
                    : _slots.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(FontAwesomeIcons.clock,
                                    size: 40,
                                    color: AppColors.mutedText.withAlpha(80)),
                                const SizedBox(height: AppSpacing.s12),
                                Text(
                                  widget.isArabic
                                      ? 'لا يوجد مواعيد متاحة'
                                      : 'No time slots available',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: AppColors.mutedText),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: AppSpacing.s12,
                              mainAxisSpacing: AppSpacing.s12,
                              childAspectRatio: 2.2,
                            ),
                            itemCount: _slots.length,
                            itemBuilder: (context, index) {
                              final slot = _slots[index];
                              return _TimeSlotChip(
                                slot: slot,
                                isArabic: widget.isArabic,
                                onTap: slot.isAvailable
                                    ? () => widget.onSlotSelected(slot)
                                    : null,
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

// ─── Summary Chip ──────────────────────────────────────────────────────────

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 11,
                color: AppColors.mutedText,
              ),
        ),
      ],
    );
  }
}

// ─── Time Slot Chip ────────────────────────────────────────────────────────

class _TimeSlotChip extends StatelessWidget {
  const _TimeSlotChip({
    required this.slot,
    required this.isArabic,
    this.onTap,
  });

  final TimeSlotModel slot;
  final bool isArabic;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isAvailable = slot.isAvailable;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.r12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isAvailable
                ? AppColors.primary500.withAlpha(15)
                : AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(AppRadius.r12),
            border: Border.all(
              color: isAvailable
                  ? AppColors.primary500.withAlpha(60)
                  : AppColors.border,
              width: isAvailable ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  slot.displayTime(isArabic: isArabic),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight:
                            isAvailable ? FontWeight.w700 : FontWeight.w500,
                        color: isAvailable
                            ? AppColors.primary500
                            : AppColors.mutedText,
                        fontSize: 12,
                        decoration: !isAvailable
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? AppColors.success
                            : AppColors.error.withAlpha(150),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isAvailable
                          ? (isArabic ? 'متاح' : 'Open')
                          : (isArabic ? 'محجوز' : 'Booked'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 9,
                            color: isAvailable
                                ? AppColors.success
                                : AppColors.mutedText,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
