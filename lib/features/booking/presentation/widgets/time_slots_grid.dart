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
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: _crossAxisCount(context),
                              crossAxisSpacing: AppSpacing.s10,
                              mainAxisSpacing: AppSpacing.s10,
                              childAspectRatio: 1.1,
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

  /// Dynamic grid columns based on screen width
  int _crossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 600) return 5;
    if (width >= 400) return 4;
    return 3;
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

  /// Splits "09:00 AM" → ("09:00", "AM") or Arabic equivalent
  (String, String) _splitTime(bool isArabic) {
    final raw = isArabic ? slot.time12hrAr : slot.time12hr;
    final parts = raw.trim().split(' ');
    if (parts.length >= 2) {
      return (parts[0], parts.sublist(1).join(' '));
    }
    return (raw, '');
  }

  @override
  Widget build(BuildContext context) {
    final isAvailable = slot.isAvailable;
    final (timeStr, period) = _splitTime(isArabic);

    // Colors
    final Color bg = isAvailable
        ? AppColors.primary100
        : const Color(0xFFF1F5F9);
    final Color border = isAvailable
        ? AppColors.primary500
        : AppColors.border;
    final Color timeColor = isAvailable
        ? AppColors.primary900
        : AppColors.mutedText;
    final Color periodColor = isAvailable
        ? AppColors.primary500
        : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: border,
            width: isAvailable ? 1.5 : 1.0,
          ),
          boxShadow: isAvailable
              ? [
                  BoxShadow(
                    color: AppColors.primary500.withAlpha(20),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Time number
            Text(
              timeStr,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: timeColor,
                decoration: !isAvailable
                    ? TextDecoration.lineThrough
                    : null,
                decorationColor: AppColors.mutedText,
              ),
            ),
            const SizedBox(height: 3),
            // AM / PM label
            Text(
              period,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: periodColor,
              ),
            ),
            const SizedBox(height: 4),
            // Status dot
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isAvailable
                        ? AppColors.primary500
                        : AppColors.mutedText,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 3),
                Text(
                  isAvailable
                      ? (isArabic ? 'متاح' : 'Open')
                      : (isArabic ? 'محجوز' : 'Taken'),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: isAvailable
                        ? AppColors.primary500
                        : AppColors.mutedText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
