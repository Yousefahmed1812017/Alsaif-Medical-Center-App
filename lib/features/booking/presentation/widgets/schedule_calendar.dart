import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/models/doctor_schedule_model.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_loading_state.dart';
import '../../../../core/widgets/app_error_state.dart';

/// Step 3 — calendar view showing doctor availability per day.
class ScheduleCalendar extends StatefulWidget {
  const ScheduleCalendar({
    super.key,
    required this.isArabic,
    required this.docId,
    required this.onDateSelected,
  });

  final bool isArabic;
  final int docId;
  final ValueChanged<DateTime> onDateSelected;

  @override
  State<ScheduleCalendar> createState() => _ScheduleCalendarState();
}

class _ScheduleCalendarState extends State<ScheduleCalendar> {
  late DateTime _currentMonth;
  Map<String, DoctorScheduleModel> _scheduleMap = {};
  bool _isLoading = true;
  String? _error;
  bool _availableOnly = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
    _loadSchedule();
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _loadSchedule() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);

    try {
      final response = await ApiService.getDoctorSchedule(
        docId: widget.docId,
        fromDate: _formatDate(firstDay),
        toDate: _formatDate(lastDay),
        availableOnly: _availableOnly ? 'true' : 'false',
      );

      final data = response['data'] as List<dynamic>? ?? [];
      final map = <String, DoctorScheduleModel>{};
      for (final item in data) {
        final schedule =
            DoctorScheduleModel.fromJson(item as Map<String, dynamic>);
        map[schedule.date] = schedule;
      }

      setState(() {
        _scheduleMap = map;
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

  void _goToPreviousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
    _loadSchedule();
  }

  void _goToNextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
    _loadSchedule();
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
                  child: FaIcon(FontAwesomeIcons.calendarDays,
                      size: 18, color: AppColors.primary500),
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isArabic ? 'اختر التاريخ' : 'Select Date',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.headingText,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.isArabic
                          ? 'اختر يوم متاح من الجدول'
                          : 'Choose an available day from the schedule',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.mutedText,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.s16),

          // Available Only Toggle
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s12,
              vertical: AppSpacing.s4,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.r12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.isArabic ? 'الأيام المتاحة فقط' : 'Available days only',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Switch(
                  value: _availableOnly,
                  activeThumbColor: AppColors.primary500,
                  onChanged: (v) {
                    setState(() => _availableOnly = v);
                    _loadSchedule();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.s16),

          // Calendar
          Expanded(
            child: _isLoading
                ? AppLoadingState(
                    message: widget.isArabic
                        ? 'جاري تحميل الجدول...'
                        : 'Loading schedule...',
                  )
                : _error != null
                    ? AppErrorState(
                        title: widget.isArabic ? 'خطأ' : 'Error',
                        message: _error!,
                        onRetry: _loadSchedule,
                      )
                    : _buildCalendar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r16),
        border: Border.all(color: AppColors.border.withAlpha(120)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary500.withAlpha(6),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Month Navigation
          _MonthNavBar(
            currentMonth: _currentMonth,
            isArabic: widget.isArabic,
            onPrevious: _goToPreviousMonth,
            onNext: _goToNextMonth,
          ),

          const Divider(height: 1, color: AppColors.border),

          // Day Headers
          _WeekdayHeaders(isArabic: widget.isArabic),

          const Divider(height: 1, color: AppColors.divider),

          // Days Grid
          Expanded(
            child: _DaysGrid(
              currentMonth: _currentMonth,
              scheduleMap: _scheduleMap,
              isArabic: widget.isArabic,
              onDateSelected: widget.onDateSelected,
            ),
          ),

          // Legend
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendDot(
                  color: AppColors.primary500,
                  label: widget.isArabic ? 'متاح' : 'Available',
                ),
                const SizedBox(width: AppSpacing.s16),
                _LegendDot(
                  color: AppColors.mutedText.withAlpha(60),
                  label: widget.isArabic ? 'عطلة' : 'Weekend',
                ),
                const SizedBox(width: AppSpacing.s16),
                _LegendDot(
                  color: Colors.transparent,
                  borderColor: AppColors.border,
                  label: widget.isArabic ? 'بدون جدول' : 'No schedule',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Month Navigation Bar ──────────────────────────────────────────────────

class _MonthNavBar extends StatelessWidget {
  const _MonthNavBar({
    required this.currentMonth,
    required this.isArabic,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime currentMonth;
  final bool isArabic;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  String _monthName(int month) {
    const en = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    const ar = [
      '', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    return isArabic ? ar[month] : en[month];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: AppSpacing.s8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onPrevious,
            icon: FaIcon(
              isArabic
                  ? FontAwesomeIcons.chevronRight
                  : FontAwesomeIcons.chevronLeft,
              size: 16,
              color: AppColors.primary500,
            ),
          ),
          Text(
            '${_monthName(currentMonth.month)} ${currentMonth.year}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingText,
                ),
          ),
          IconButton(
            onPressed: onNext,
            icon: FaIcon(
              isArabic
                  ? FontAwesomeIcons.chevronLeft
                  : FontAwesomeIcons.chevronRight,
              size: 16,
              color: AppColors.primary500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Weekday Headers ───────────────────────────────────────────────────────

class _WeekdayHeaders extends StatelessWidget {
  const _WeekdayHeaders({required this.isArabic});
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final enDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final arDays = ['أحد', 'إثن', 'ثلا', 'أرب', 'خمي', 'جمع', 'سبت'];
    final days = isArabic ? arDays : enDays;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
      child: Row(
        children: days
            .map(
              (d) => Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.mutedText,
                          fontSize: 11,
                        ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ─── Days Grid ─────────────────────────────────────────────────────────────

class _DaysGrid extends StatelessWidget {
  const _DaysGrid({
    required this.currentMonth,
    required this.scheduleMap,
    required this.isArabic,
    required this.onDateSelected,
  });

  final DateTime currentMonth;
  final Map<String, DoctorScheduleModel> scheduleMap;
  final bool isArabic;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    final daysInMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7; // 0 = Sunday

    final cells = <Widget>[];

    // Empty cells for offset
    for (int i = 0; i < startWeekday; i++) {
      cells.add(const SizedBox());
    }

    // Day cells
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(currentMonth.year, currentMonth.month, day);
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final schedule = scheduleMap[dateStr];
      final today = DateTime.now();
      final isToday = date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
      final isPast = date.isBefore(DateTime(today.year, today.month, today.day));

      cells.add(
        _DayCell(
          day: day,
          schedule: schedule,
          isToday: isToday,
          isPast: isPast,
          onTap: () {
            if (schedule != null && schedule.isAvailable && !isPast) {
              onDateSelected(date);
            }
          },
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s8,
        vertical: AppSpacing.s4,
      ),
      childAspectRatio: 1,
      children: cells,
    );
  }
}

// ─── Day Cell ──────────────────────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.schedule,
    required this.isToday,
    required this.isPast,
    required this.onTap,
  });

  final int day;
  final DoctorScheduleModel? schedule;
  final bool isToday;
  final bool isPast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isWeekend = schedule?.isWeekend ?? false;
    final isAvailableHint = schedule != null && schedule!.isAvailable && !isPast;
    final isDisabled = isPast; // Only restrict clicks on past days

    Color bgColor;
    Color textColor;
    BoxBorder? border;

    if (isAvailableHint) {
      bgColor = AppColors.primary500.withAlpha(18);
      textColor = AppColors.primary500;
      border = Border.all(color: AppColors.primary500.withAlpha(60), width: 1.5);
    } else if (isWeekend) {
      bgColor = AppColors.error.withAlpha(10);
      textColor = AppColors.mutedText.withAlpha(120);
      border = null;
    } else if (isPast) {
      bgColor = Colors.transparent;
      textColor = AppColors.mutedText.withAlpha(80);
      border = null;
    } else {
      bgColor = Colors.transparent;
      textColor = AppColors.bodyText.withAlpha(100);
      border = null;
    }

    if (isToday) {
      border = Border.all(color: AppColors.primary500, width: 2);
    }

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadius.r8),
          border: border,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$day',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: isAvailableHint || isToday
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: textColor,
                      fontSize: 13,
                    ),
              ),
              if (isAvailableHint)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Legend Dot ─────────────────────────────────────────────────────────────

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
    this.borderColor,
  });

  final Color color;
  final String label;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: borderColor != null
                ? Border.all(color: borderColor!, width: 1.5)
                : null,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: AppColors.mutedText,
              ),
        ),
      ],
    );
  }
}
