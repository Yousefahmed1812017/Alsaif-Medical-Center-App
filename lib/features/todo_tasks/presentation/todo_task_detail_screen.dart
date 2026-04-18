import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/models/task_type_model.dart';
import '../../../core/models/todo_task_detail_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_app_bar.dart';

/// Detail view for a single To-Do task.
class TodoTaskDetailScreen extends StatefulWidget {
  const TodoTaskDetailScreen({super.key, required this.taskId});

  final int taskId;

  @override
  State<TodoTaskDetailScreen> createState() => _TodoTaskDetailScreenState();
}

class _TodoTaskDetailScreenState extends State<TodoTaskDetailScreen> {
  ToDoTaskDetailModel? _task;
  List<TaskTypeModel> _taskTypes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load task types and task details in parallel
      final results = await Future.wait([
        ApiService.getTaskTypes(),
        ApiService.getToDoTaskDetails(taskId: widget.taskId),
      ]);

      // Task types
      final typesData = results[0]['data'] as List<dynamic>;
      _taskTypes = typesData
          .map((e) => TaskTypeModel.fromJson(e as Map<String, dynamic>))
          .toList();

      // Task details
      final taskData = results[1]['data'] as Map<String, dynamic>;
      _task = ToDoTaskDetailModel.fromJson(taskData);
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    }

    if (mounted) setState(() => _isLoading = false);
  }

  String _taskTypeLabel(String? whatToDoId, bool isArabic) {
    if (whatToDoId == null) return isArabic ? 'غير محدد' : 'Unknown';
    final id = int.tryParse(whatToDoId);
    if (id == null) return whatToDoId;
    final match = _taskTypes.where((t) => t.id == id);
    if (match.isEmpty) return whatToDoId;
    return match.first.displayName(isArabic: isArabic);
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppAppBar(
        title: isArabic ? 'تفاصيل المهمة' : 'Task Details',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError(isArabic)
              : _buildContent(context, isArabic),
    );
  }

  Widget _buildError(bool isArabic) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(FontAwesomeIcons.circleExclamation,
                size: 48, color: AppColors.error),
            const SizedBox(height: AppSpacing.s16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.s16),
            OutlinedButton.icon(
              onPressed: _loadAll,
              icon: const FaIcon(FontAwesomeIcons.arrowsRotate, size: 16),
              label: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isArabic) {
    final task = _task!;
    final priorityLabel = task.priorityLabel(isArabic: isArabic);
    final statusLabel = task.statusLabel(isArabic: isArabic);
    final sc = task.statusColor;
    final sbg = task.statusBgColor;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Status Banner ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(AppSpacing.s20),
            decoration: BoxDecoration(
              color: sbg,
              borderRadius: BorderRadius.circular(AppRadius.r16),
              border: Border.all(color: sc.withAlpha(60)),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: sc.withAlpha(30),
                    borderRadius: BorderRadius.circular(AppRadius.r12),
                  ),
                  child: Center(
                    child: FaIcon(
                      task.status.toLowerCase() == 'done'
                          ? FontAwesomeIcons.circleCheck
                          : task.status.toLowerCase() == 'in progress'
                              ? FontAwesomeIcons.spinner
                              : FontAwesomeIcons.hourglassHalf,
                      size: 20,
                      color: sc,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.s16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusLabel,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: sc,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isArabic
                            ? 'رقم المهمة: #${task.taskId}'
                            : 'Task #${task.taskId}',
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: sc.withAlpha(180),
                                ),
                      ),
                    ],
                  ),
                ),
                // Priority badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: task.priorityBgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    priorityLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: task.priorityColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.s24),

          // ── Patient Info Card ──────────────────────────────────
          Container(
            padding: const EdgeInsets.all(AppSpacing.s20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.r16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary500.withAlpha(15),
                        borderRadius: BorderRadius.circular(AppRadius.r8),
                      ),
                      child: const Center(
                        child: FaIcon(FontAwesomeIcons.userInjured,
                            size: 16, color: AppColors.primary500),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.patientName(isArabic: isArabic),
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.headingText,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${isArabic ? 'رقم الملف:' : 'MR#:'} ${task.patientNo}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.mutedText,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.s16),

          // ── Details Card ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(AppSpacing.s20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.r16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _DetailRow(
                  icon: FontAwesomeIcons.clipboardList,
                  label: isArabic ? 'نوع المهمة' : 'Task Type',
                  value: _taskTypeLabel(task.whatToDo, isArabic),
                ),
                const Divider(height: AppSpacing.s24),
                _DetailRow(
                  icon: FontAwesomeIcons.calendarDay,
                  label: isArabic ? 'تاريخ الطلب' : 'Request Date',
                  value: task.dateRequest ?? '--',
                ),
                const Divider(height: AppSpacing.s24),
                _DetailRow(
                  icon: FontAwesomeIcons.userCheck,
                  label: isArabic ? 'استلم بواسطة' : 'Received By',
                  value: task.receivedByName ?? '${task.receivedBy ?? '--'}',
                ),
                const Divider(height: AppSpacing.s24),
                _DetailRow(
                  icon: FontAwesomeIcons.userGear,
                  label: isArabic ? 'المطلوب من' : 'Required By',
                  value: task.taskRequiredByName ??
                      '${task.taskRequiredBy ?? '--'}',
                ),
                if (task.notes != null && task.notes!.isNotEmpty) ...[
                  const Divider(height: AppSpacing.s24),
                  _DetailRow(
                    icon: FontAwesomeIcons.noteSticky,
                    label: isArabic ? 'الملاحظات' : 'Notes',
                    value: task.notes!,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.s24),
        ],
      ),
    );
  }
}

// ─── Detail Row Widget ────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final dynamic icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(AppRadius.r8),
          ),
          child: Center(
            child: FaIcon(icon, size: 15, color: AppColors.mutedText),
          ),
        ),
        const SizedBox(width: AppSpacing.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.mutedText,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.headingText,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
