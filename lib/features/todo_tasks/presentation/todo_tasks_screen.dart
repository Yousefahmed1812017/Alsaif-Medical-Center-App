import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/task_type_model.dart';
import '../../../core/models/todo_task_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_app_bar.dart';

/// Main task list screen with two tabs:
/// 1. "My Requests" — tasks the current user created (ReceivedBy = me)
/// 2. "Assigned to Me" — tasks assigned to the current user (TaskRequiredBy = me)
class TodoTasksScreen extends StatefulWidget {
  const TodoTasksScreen({super.key});

  @override
  State<TodoTasksScreen> createState() => _TodoTasksScreenState();
}

class _TodoTasksScreenState extends State<TodoTasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<ToDoTaskModel> _myRequests = [];
  List<ToDoTaskModel> _assignedToMe = [];
  List<TaskTypeModel> _taskTypes = [];

  bool _isLoadingMyRequests = true;
  bool _isLoadingAssigned = true;
  String? _errorMyRequests;
  String? _errorAssigned;

  // Search / Filter state
  final _searchController = TextEditingController();
  String? _filterStatus;
  String? _filterPriority;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {}); // refresh badges
      }
    });
    _loadTaskTypes();
    _loadMyRequests();
    _loadAssignedToMe();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTaskTypes() async {
    try {
      final response = await ApiService.getTaskTypes();
      final dataList = response['data'] as List<dynamic>;
      _taskTypes = dataList
          .map((e) => TaskTypeModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {}
  }

  Future<void> _loadMyRequests() async {
    final user = AuthService.currentUser;
    if (user == null) return;

    setState(() {
      _isLoadingMyRequests = true;
      _errorMyRequests = null;
    });

    try {
      final searchText = _searchController.text.trim();
      final response = await ApiService.getToDoTasks(
        receivedBy: user.userId,
        patientName: searchText.isNotEmpty ? searchText : null,
        status: _filterStatus,
        priority: _filterPriority,
      );
      final dataList = response['data'] as List<dynamic>;
      _myRequests = dataList
          .map((e) => ToDoTaskModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      _errorMyRequests = e.message;
    } catch (e) {
      _errorMyRequests = e.toString();
    }

    if (mounted) setState(() => _isLoadingMyRequests = false);
  }

  Future<void> _loadAssignedToMe() async {
    final user = AuthService.currentUser;
    if (user == null) return;

    setState(() {
      _isLoadingAssigned = true;
      _errorAssigned = null;
    });

    try {
      final searchText = _searchController.text.trim();
      final response = await ApiService.getToDoTasks(
        taskRequiredBy: user.userId,
        patientName: searchText.isNotEmpty ? searchText : null,
        status: _filterStatus,
        priority: _filterPriority,
      );
      final dataList = response['data'] as List<dynamic>;
      _assignedToMe = dataList
          .map((e) => ToDoTaskModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      _errorAssigned = e.message;
    } catch (e) {
      _errorAssigned = e.toString();
    }

    if (mounted) setState(() => _isLoadingAssigned = false);
  }

  void _reloadAll() {
    _loadMyRequests();
    _loadAssignedToMe();
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
        title: isArabic ? 'المهام' : 'Tasks',
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push('/todo-tasks/create');
          if (result == true) _reloadAll();
        },
        tooltip: isArabic ? 'مهمة جديدة' : 'New Task',
        child: const FaIcon(FontAwesomeIcons.plus, size: 20),
      ),
      body: Column(
        children: [
          // ── Tabs ─────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary500,
              unselectedLabelColor: AppColors.mutedText,
              indicatorColor: AppColors.primary500,
              indicatorWeight: 3,
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              unselectedLabelStyle:
                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const FaIcon(FontAwesomeIcons.paperPlane, size: 14),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          isArabic ? 'مهام طلبتها' : 'My Requests',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!_isLoadingMyRequests && _myRequests.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        _CountBadge(count: _myRequests.length),
                      ],
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const FaIcon(FontAwesomeIcons.inbox, size: 14),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          isArabic ? 'مطلوبة مني' : 'Assigned to Me',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!_isLoadingAssigned && _assignedToMe.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        _CountBadge(count: _assignedToMe.length),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Search & Filters ──────────────────────────────────
          _SearchFilterBar(
            searchController: _searchController,
            filterStatus: _filterStatus,
            filterPriority: _filterPriority,
            isArabic: isArabic,
            onSearch: (_) => _reloadAll(),
            onStatusChanged: (v) {
              setState(() => _filterStatus = v);
              _reloadAll();
            },
            onPriorityChanged: (v) {
              setState(() => _filterPriority = v);
              _reloadAll();
            },
          ),

          // ── Tab Content ─────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: My Requests
                _TaskListContent(
                  isLoading: _isLoadingMyRequests,
                  error: _errorMyRequests,
                  tasks: _myRequests,
                  isArabic: isArabic,
                  emptyTitle: isArabic ? 'لا توجد مهام طلبتها' : 'No Requests',
                  emptyMessage: isArabic
                      ? 'اضغط + لإنشاء مهمة جديدة'
                      : 'Tap + to create a new task',
                  taskTypeLabel: _taskTypeLabel,
                  onRefresh: _loadMyRequests,
                  onRetry: _loadMyRequests,
                ),
                // Tab 2: Assigned to Me
                _TaskListContent(
                  isLoading: _isLoadingAssigned,
                  error: _errorAssigned,
                  tasks: _assignedToMe,
                  isArabic: isArabic,
                  emptyTitle: isArabic
                      ? 'لا توجد مهام مطلوبة منك'
                      : 'No Tasks Assigned',
                  emptyMessage: isArabic
                      ? 'ليس لديك مهام مطلوبة حالياً'
                      : 'You have no tasks assigned to you',
                  taskTypeLabel: _taskTypeLabel,
                  onRefresh: _loadAssignedToMe,
                  onRetry: _loadAssignedToMe,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ─── Count Badge ─────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary500.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.primary500,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ─── Task List Content (reused by both tabs) ─────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════

class _TaskListContent extends StatelessWidget {
  const _TaskListContent({
    required this.isLoading,
    required this.error,
    required this.tasks,
    required this.isArabic,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.taskTypeLabel,
    required this.onRefresh,
    required this.onRetry,
  });

  final bool isLoading;
  final String? error;
  final List<ToDoTaskModel> tasks;
  final bool isArabic;
  final String emptyTitle;
  final String emptyMessage;
  final String Function(String?, bool) taskTypeLabel;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(FontAwesomeIcons.circleExclamation,
                  size: 48, color: AppColors.error),
              const SizedBox(height: AppSpacing.s16),
              Text(
                error!,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: AppColors.error),
              ),
              const SizedBox(height: AppSpacing.s16),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const FaIcon(FontAwesomeIcons.arrowsRotate, size: 16),
                label: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(FontAwesomeIcons.clipboardList,
                size: 56, color: AppColors.mutedText.withAlpha(120)),
            const SizedBox(height: AppSpacing.s16),
            Text(
              emptyTitle,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: AppColors.mutedText),
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              emptyMessage,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.mutedText),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s16,
          AppSpacing.s8,
          AppSpacing.s16,
          AppSpacing.s48 * 2,
        ),
        itemCount: tasks.length,
        separatorBuilder: (context, i) =>
            const SizedBox(height: AppSpacing.s12),
        itemBuilder: (context, index) => _TaskCard(
          task: tasks[index],
          isArabic: isArabic,
          taskTypeLabel: taskTypeLabel(tasks[index].whatToDo, isArabic),
          onTap: () async {
            await context.push('/todo-tasks/detail/${tasks[index].taskId}');
            onRefresh();
          },
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ─── Search & Filter Bar ─────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════

class _SearchFilterBar extends StatelessWidget {
  const _SearchFilterBar({
    required this.searchController,
    required this.filterStatus,
    required this.filterPriority,
    required this.isArabic,
    required this.onSearch,
    required this.onStatusChanged,
    required this.onPriorityChanged,
  });

  final TextEditingController searchController;
  final String? filterStatus;
  final String? filterPriority;
  final bool isArabic;
  final ValueChanged<String> onSearch;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onPriorityChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.s16, AppSpacing.s12, AppSpacing.s16, AppSpacing.s8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          // Search field
          TextField(
            controller: searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: onSearch,
            decoration: InputDecoration(
              hintText: isArabic
                  ? 'بحث باسم المريض...'
                  : 'Search by patient name...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        searchController.clear();
                        onSearch('');
                      },
                    )
                  : null,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.r12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.r12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              filled: true,
              fillColor: AppColors.background,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),

          // Filter chips row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChipDropdown(
                  label: isArabic ? 'الحالة' : 'Status',
                  value: filterStatus,
                  icon: FontAwesomeIcons.circleCheck,
                  items: {
                    null: isArabic ? 'الكل' : 'All',
                    'Pending': isArabic ? 'قيد الانتظار' : 'Pending',
                    'In Progress': isArabic ? 'قيد التنفيذ' : 'In Progress',
                    'Done': isArabic ? 'مكتمل' : 'Done',
                  },
                  onChanged: onStatusChanged,
                ),
                const SizedBox(width: AppSpacing.s8),
                _FilterChipDropdown(
                  label: isArabic ? 'الأولوية' : 'Priority',
                  value: filterPriority,
                  icon: FontAwesomeIcons.flag,
                  items: {
                    null: isArabic ? 'الكل' : 'All',
                    'Normal': isArabic ? 'عادي' : 'Normal',
                    'High': isArabic ? 'مرتفع' : 'High',
                    'Urgent': isArabic ? 'عاجل' : 'Urgent',
                  },
                  onChanged: onPriorityChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ─── Filter Chip Dropdown ────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════

class _FilterChipDropdown extends StatelessWidget {
  const _FilterChipDropdown({
    required this.label,
    required this.value,
    required this.icon,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final dynamic icon;
  final Map<String?, String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final isActive = value != null;

    return PopupMenuButton<String?>(
      onSelected: onChanged,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.r12),
      ),
      itemBuilder: (context) => items.entries
          .map(
            (e) => PopupMenuItem<String?>(
              value: e.key,
              child: Row(
                children: [
                  if (value == e.key)
                    const FaIcon(FontAwesomeIcons.check,
                        size: 14, color: AppColors.primary500)
                  else
                    const SizedBox(width: 14),
                  const SizedBox(width: AppSpacing.s8),
                  Text(e.value),
                ],
              ),
            ),
          )
          .toList(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s12, vertical: AppSpacing.s8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary500.withAlpha(15)
              : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? AppColors.primary500.withAlpha(80)
                : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              icon,
              size: 12,
              color: isActive ? AppColors.primary500 : AppColors.mutedText,
            ),
            const SizedBox(width: 6),
            Text(
              isActive ? items[value]! : label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isActive ? AppColors.primary500 : AppColors.bodyText,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 12,
                  ),
            ),
            const SizedBox(width: 4),
            FaIcon(
              FontAwesomeIcons.chevronDown,
              size: 10,
              color: isActive ? AppColors.primary500 : AppColors.mutedText,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ─── Task Card ───────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.isArabic,
    required this.taskTypeLabel,
    required this.onTap,
  });

  final ToDoTaskModel task;
  final bool isArabic;
  final String taskTypeLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusLabel = isArabic ? task.statusLabelAr() : task.status;
    final priorityLabel = isArabic ? task.priorityLabelAr() : task.priority;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: patient name + priority badge ────────────
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primary500.withAlpha(15),
                    borderRadius: BorderRadius.circular(AppRadius.r12),
                  ),
                  child: const Center(
                    child: FaIcon(FontAwesomeIcons.listCheck,
                        size: 18, color: AppColors.primary500),
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.patientName(isArabic: isArabic),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                                  fontSize: 11,
                                ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

            const SizedBox(height: AppSpacing.s12),
            Divider(height: 1, color: AppColors.border.withAlpha(120)),
            const SizedBox(height: AppSpacing.s12),

            // ── Bottom row: task type, date, status ──────────────
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      FaIcon(FontAwesomeIcons.tag,
                          size: 12, color: AppColors.mutedText),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          taskTypeLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: AppColors.bodyText,
                                fontSize: 12,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (task.dateRequest != null) ...[
                  const SizedBox(width: AppSpacing.s8),
                  FaIcon(FontAwesomeIcons.clock,
                      size: 11, color: AppColors.mutedText),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(task.dateRequest!),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedText,
                          fontSize: 11,
                        ),
                  ),
                ],
                const SizedBox(width: AppSpacing.s12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: task.statusBgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: task.statusColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                  ),
                ),
              ],
            ),

            if (task.notes != null && task.notes!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.s8),
              Row(
                children: [
                  FaIcon(FontAwesomeIcons.noteSticky,
                      size: 11, color: AppColors.mutedText),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      task.notes!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.mutedText,
                            fontSize: 11,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }
}
