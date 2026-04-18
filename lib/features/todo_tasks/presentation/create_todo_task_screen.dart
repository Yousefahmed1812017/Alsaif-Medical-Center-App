import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/patient_model.dart';
import '../../../core/models/staff_user_model.dart';
import '../../../core/models/task_type_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_app_bar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';

/// Form screen to create a new To-Do task.
class CreateTodoTaskScreen extends StatefulWidget {
  const CreateTodoTaskScreen({super.key});

  @override
  State<CreateTodoTaskScreen> createState() => _CreateTodoTaskScreenState();
}

class _CreateTodoTaskScreenState extends State<CreateTodoTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  List<TaskTypeModel> _taskTypes = [];
  TaskTypeModel? _selectedTaskType;
  StaffUserModel? _selectedStaff;
  PatientModel? _selectedPatient;
  String _priority = 'Normal';
  bool _isSubmitting = false;
  bool _isLoadingTypes = true;

  @override
  void initState() {
    super.initState();
    _loadTaskTypes();
  }

  @override
  void dispose() {
    _notesController.dispose();
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

    if (mounted) setState(() => _isLoadingTypes = false);
  }

  Future<void> _openPatientPicker() async {
    final result = await showModalBottomSheet<PatientModel>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _PatientSearchSheet(),
    );

    if (result != null && mounted) {
      setState(() => _selectedPatient = result);
    }
  }

  Future<void> _openStaffPicker() async {
    final result = await showModalBottomSheet<StaffUserModel>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _StaffSearchSheet(),
    );

    if (result != null && mounted) {
      setState(() => _selectedStaff = result);
    }
  }

  Future<void> _submit() async {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final user = AuthService.currentUser;
    if (user == null) return;

    if (_selectedPatient == null) {
      _showSnackBar(
          isArabic ? 'يرجى اختيار المريض' : 'Please select a patient');
      return;
    }

    if (_selectedTaskType == null) {
      _showSnackBar(
          isArabic ? 'يرجى اختيار نوع المهمة' : 'Please select a task type');
      return;
    }

    if (_selectedStaff == null) {
      _showSnackBar(isArabic
          ? 'يرجى اختيار الموظف المطلوب'
          : 'Please select the assigned staff');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await ApiService.addToDoTask(
        patientNo: _selectedPatient!.patientCode ?? '',
        whatToDo: _selectedTaskType!.id,
        receivedBy: user.userId,
        taskRequiredBy: _selectedStaff!.userId,
        notes: _notesController.text.trim(),
        priority: _priority,
      );

      if (!mounted) return;
      _showSnackBar(
        isArabic ? 'تم إنشاء المهمة بنجاح ✓' : 'Task created successfully ✓',
        isError: false,
      );
      context.pop(true);
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
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.r12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppAppBar(
        title: isArabic ? 'إضافة مهمة' : 'New Task',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Patient Picker ──────────────────────────────────
              _SectionLabel(label: isArabic ? 'المريض *' : 'Patient *'),
              const SizedBox(height: AppSpacing.s8),
              GestureDetector(
                onTap: _openPatientPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s16, vertical: AppSpacing.s16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.r12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: _selectedPatient != null
                              ? AppColors.primary500.withAlpha(15)
                              : AppColors.surfaceAlt,
                          borderRadius:
                              BorderRadius.circular(AppRadius.r8),
                        ),
                        child: Center(
                          child: FaIcon(
                            FontAwesomeIcons.userInjured,
                            size: 16,
                            color: _selectedPatient != null
                                ? AppColors.primary500
                                : AppColors.mutedText,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: _selectedPatient != null
                            ? Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedPatient!.displayName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          color: AppColors.headingText,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${isArabic ? 'رقم الملف:' : 'MR#:'} ${_selectedPatient!.patientCode ?? '--'}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppColors.mutedText,
                                          fontSize: 11,
                                        ),
                                  ),
                                ],
                              )
                            : Text(
                                isArabic
                                    ? 'اختر المريض'
                                    : 'Select patient',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: AppColors.mutedText,
                                    ),
                              ),
                      ),
                      const FaIcon(FontAwesomeIcons.magnifyingGlass,
                          size: 14, color: AppColors.mutedText),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.s24),

              // ── Task Type Dropdown ──────────────────────────────
              _SectionLabel(
                  label: isArabic ? 'نوع المهمة *' : 'Task Type *'),
              const SizedBox(height: AppSpacing.s8),
              _isLoadingTypes
                  ? Container(
                      padding: const EdgeInsets.all(AppSpacing.s16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius:
                            BorderRadius.circular(AppRadius.r12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  : _DropdownField<TaskTypeModel>(
                      value: _selectedTaskType,
                      hint: isArabic
                          ? 'اختر نوع المهمة'
                          : 'Select task type',
                      icon: FontAwesomeIcons.clipboardList,
                      items: _taskTypes,
                      itemLabel: (t) =>
                          t.displayName(isArabic: isArabic),
                      onChanged: (v) =>
                          setState(() => _selectedTaskType = v),
                    ),

              const SizedBox(height: AppSpacing.s24),

              // ── Assigned Staff ─────────────────────────────────
              _SectionLabel(
                  label: isArabic
                      ? 'الموظف المطلوب *'
                      : 'Assigned To *'),
              const SizedBox(height: AppSpacing.s8),
              GestureDetector(
                onTap: _openStaffPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s16,
                      vertical: AppSpacing.s16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.r12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const FaIcon(FontAwesomeIcons.userDoctor,
                          size: 18, color: AppColors.primary500),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: Text(
                          _selectedStaff != null
                              ? '${_selectedStaff!.displayName(isArabic: isArabic)} (${_selectedStaff!.userId})'
                              : (isArabic
                                  ? 'اختر الموظف'
                                  : 'Select staff member'),
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                color: _selectedStaff != null
                                    ? AppColors.headingText
                                    : AppColors.mutedText,
                                fontWeight: _selectedStaff != null
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                        ),
                      ),
                      const FaIcon(FontAwesomeIcons.chevronDown,
                          size: 14, color: AppColors.mutedText),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.s24),

              // ── Priority Selector ──────────────────────────────
              _SectionLabel(
                  label: isArabic ? 'الأولوية' : 'Priority'),
              const SizedBox(height: AppSpacing.s8),
              _PrioritySelector(
                value: _priority,
                isArabic: isArabic,
                onChanged: (v) => setState(() => _priority = v),
              ),

              const SizedBox(height: AppSpacing.s24),

              // ── Notes ──────────────────────────────────────────
              _SectionLabel(label: isArabic ? 'ملاحظات' : 'Notes'),
              const SizedBox(height: AppSpacing.s8),
              AppTextField(
                controller: _notesController,
                hintText: isArabic
                    ? 'أدخل ملاحظاتك...'
                    : 'Enter your notes...',
                maxLines: 3,
                minLines: 3,
                textInputAction: TextInputAction.done,
              ),

              const SizedBox(height: AppSpacing.s40),

              // ── Submit ─────────────────────────────────────────
              AppButton(
                text: isArabic ? 'إنشاء المهمة' : 'Create Task',
                onPressed: _submit,
                isLoading: _isSubmitting,
                icon: FontAwesomeIcons.plus,
              ),

              const SizedBox(height: AppSpacing.s24),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ─── Helper Widgets ──────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppColors.headingText,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.value,
    required this.hint,
    required this.icon,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  final T? value;
  final String hint;
  final dynamic icon;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Row(
            children: [
              FaIcon(icon, size: 18, color: AppColors.primary500),
              const SizedBox(width: AppSpacing.s12),
              Text(
                hint,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.mutedText,
                    ),
              ),
            ],
          ),
          isExpanded: true,
          icon: const FaIcon(FontAwesomeIcons.chevronDown,
              size: 14, color: AppColors.mutedText),
          borderRadius: BorderRadius.circular(AppRadius.r12),
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Row(
                children: [
                  FaIcon(icon, size: 16, color: AppColors.primary500),
                  const SizedBox(width: AppSpacing.s12),
                  Flexible(
                    child: Text(
                      itemLabel(item),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ─── Priority Selector ───────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════

class _PrioritySelector extends StatelessWidget {
  const _PrioritySelector({
    required this.value,
    required this.isArabic,
    required this.onChanged,
  });

  final String value;
  final bool isArabic;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final priorities = [
      _PriorityOption(
        key: 'Normal',
        label: isArabic ? 'عادي' : 'Normal',
        color: AppColors.info,
        bgColor: AppColors.infoSoft,
        icon: Icons.remove,
      ),
      _PriorityOption(
        key: 'High',
        label: isArabic ? 'مرتفع' : 'High',
        color: AppColors.warning,
        bgColor: AppColors.warningSoft,
        icon: Icons.arrow_upward,
      ),
      _PriorityOption(
        key: 'Urgent',
        label: isArabic ? 'عاجل' : 'Urgent',
        color: AppColors.error,
        bgColor: AppColors.errorSoft,
        icon: Icons.warning_amber_rounded,
      ),
    ];

    return Row(
      children: priorities.map((p) {
        final isSelected = value == p.key;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: p.key == 'Normal' ? 0 : 4,
              right: p.key == 'Urgent' ? 0 : 4,
            ),
            child: GestureDetector(
              onTap: () => onChanged(p.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.s12),
                decoration: BoxDecoration(
                  color:
                      isSelected ? p.bgColor : AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppRadius.r12),
                  border: Border.all(
                    color: isSelected
                        ? p.color.withAlpha(120)
                        : AppColors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      p.icon,
                      size: 18,
                      color: isSelected
                          ? p.color
                          : AppColors.mutedText,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      p.label,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                            color: isSelected
                                ? p.color
                                : AppColors.bodyText,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            fontSize: 12,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PriorityOption {
  final String key;
  final String label;
  final Color color;
  final Color bgColor;
  final IconData icon;

  const _PriorityOption({
    required this.key,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.icon,
  });
}

// ═══════════════════════════════════════════════════════════════════════════
// ─── Patient Search Bottom Sheet ─────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════

class _PatientSearchSheet extends StatefulWidget {
  const _PatientSearchSheet();

  @override
  State<_PatientSearchSheet> createState() => _PatientSearchSheetState();
}

class _PatientSearchSheetState extends State<_PatientSearchSheet> {
  final _searchController = TextEditingController();
  List<PatientModel> _patients = [];
  bool _isLoading = false;
  String? _error;
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _hasSearched = true;
    });

    try {
      // Smart search: if numeric → patientCode, else → patientName
      final isNumeric = RegExp(r'^\d+$').hasMatch(query);

      final response = await ApiService.getPatients(
        patientCode: isNumeric ? query : null,
        patientName: isNumeric ? null : query,
      );
      final dataList = response['data'] as List<dynamic>;
      _patients = dataList
          .map((e) => PatientModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isArabic =
        Localizations.localeOf(context).languageCode == 'ar';

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s16),
                child: Text(
                  isArabic ? 'بحث عن مريض' : 'Search Patient',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.headingText,
                      ),
                ),
              ),
              const SizedBox(height: AppSpacing.s12),

              // Search field
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s16),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _search(),
                  decoration: InputDecoration(
                    hintText: isArabic
                        ? 'اسم المريض أو رقم الملف...'
                        : 'Patient name or MR#...',
                    prefixIcon:
                        const Icon(Icons.search, size: 20),
                    suffixIcon: IconButton(
                      icon: const FaIcon(
                          FontAwesomeIcons.magnifyingGlass,
                          size: 16),
                      onPressed: _search,
                    ),
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s16,
                            vertical: AppSpacing.s12),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppRadius.r12),
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s12),

              // Results
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator())
                    : _error != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(
                                  AppSpacing.s16),
                              child: Text(_error!,
                                  textAlign:
                                      TextAlign.center,
                                  style: TextStyle(
                                      color:
                                          AppColors.error)),
                            ),
                          )
                        : !_hasSearched
                            ? Center(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,
                                  children: [
                                    FaIcon(
                                        FontAwesomeIcons
                                            .magnifyingGlass,
                                        size: 40,
                                        color: AppColors
                                            .mutedText
                                            .withAlpha(
                                                100)),
                                    const SizedBox(
                                        height:
                                            AppSpacing.s12),
                                    Text(
                                      isArabic
                                          ? 'ابحث بالاسم أو رقم الملف'
                                          : 'Search by name or MR#',
                                      style: TextStyle(
                                          color: AppColors
                                              .mutedText),
                                    ),
                                  ],
                                ),
                              )
                            : _patients.isEmpty
                                ? Center(
                                    child: Text(
                                      isArabic
                                          ? 'لا توجد نتائج'
                                          : 'No results found',
                                      style: TextStyle(
                                          color: AppColors
                                              .mutedText),
                                    ),
                                  )
                                : ListView.separated(
                                    controller:
                                        scrollController,
                                    padding:
                                        const EdgeInsets
                                            .symmetric(
                                            horizontal:
                                                AppSpacing
                                                    .s16),
                                    itemCount:
                                        _patients.length,
                                    separatorBuilder:
                                        (context, i) =>
                                            Divider(
                                                height: 1,
                                                color: AppColors
                                                    .border),
                                    itemBuilder:
                                        (context, index) {
                                      final p =
                                          _patients[
                                              index];
                                      return ListTile(
                                        onTap: () =>
                                            Navigator.of(
                                                    context)
                                                .pop(p),
                                        leading:
                                            Container(
                                          width: 40,
                                          height: 40,
                                          decoration:
                                              BoxDecoration(
                                            color: AppColors
                                                .primary500
                                                .withAlpha(
                                                    15),
                                            borderRadius:
                                                BorderRadius
                                                    .circular(
                                                        AppRadius
                                                            .r8),
                                          ),
                                          child:
                                              const Center(
                                            child: FaIcon(
                                                FontAwesomeIcons
                                                    .userInjured,
                                                size: 16,
                                                color: AppColors
                                                    .primary500),
                                          ),
                                        ),
                                        title: Text(
                                          p.displayName,
                                          style: Theme.of(
                                                  context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontWeight:
                                                    FontWeight
                                                        .w600,
                                                color: AppColors
                                                    .headingText,
                                              ),
                                        ),
                                        subtitle: Text(
                                          '${isArabic ? 'رقم الملف:' : 'MR#:'} ${p.patientCode ?? '--'}${p.phone != null ? ' • ${p.phone}' : ''}',
                                          style: Theme.of(
                                                  context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppColors
                                                    .mutedText,
                                              ),
                                        ),
                                        trailing:
                                            const FaIcon(
                                          FontAwesomeIcons
                                              .chevronRight,
                                          size: 14,
                                          color: AppColors
                                              .mutedText,
                                        ),
                                      );
                                    },
                                  ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ─── Staff Search Bottom Sheet ───────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════

class _StaffSearchSheet extends StatefulWidget {
  const _StaffSearchSheet();

  @override
  State<_StaffSearchSheet> createState() => _StaffSearchSheetState();
}

class _StaffSearchSheetState extends State<_StaffSearchSheet> {
  final _searchController = TextEditingController();
  List<StaffUserModel> _users = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchUsers(); // load initial list
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final query = _searchController.text.trim();
      int? userId;
      String? phone;
      String? searchName;

      if (query.isNotEmpty) {
        final numVal = int.tryParse(query);
        if (numVal != null && query.length <= 6) {
          userId = numVal;
        } else if (RegExp(r'^[0-9+]+$').hasMatch(query) &&
            query.length >= 7) {
          phone = query;
        } else {
          searchName = query;
        }
      }

      final response = await ApiService.getUsers(
        userId: userId,
        phone: phone,
        searchName: searchName,
      );
      final dataList = response['data'] as List<dynamic>;
      _users = dataList
          .map((e) =>
              StaffUserModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isArabic =
        Localizations.localeOf(context).languageCode == 'ar';

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s16),
                child: Text(
                  isArabic
                      ? 'اختر الموظف'
                      : 'Select Staff Member',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.headingText,
                      ),
                ),
              ),
              const SizedBox(height: AppSpacing.s12),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s16),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _searchUsers(),
                  decoration: InputDecoration(
                    hintText: isArabic
                        ? 'بحث بالاسم أو الرقم أو الهاتف...'
                        : 'Search by name, ID, or phone...',
                    prefixIcon:
                        const Icon(Icons.search, size: 20),
                    suffixIcon: IconButton(
                      icon: const FaIcon(
                          FontAwesomeIcons.magnifyingGlass,
                          size: 16),
                      onPressed: _searchUsers,
                    ),
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s16,
                            vertical: AppSpacing.s12),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppRadius.r12),
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s12),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator())
                    : _error != null
                        ? Center(
                            child: Text(_error!,
                                style: TextStyle(
                                    color: AppColors.error)),
                          )
                        : _users.isEmpty
                            ? Center(
                                child: Text(
                                  isArabic
                                      ? 'لا توجد نتائج'
                                      : 'No results found',
                                  style: TextStyle(
                                      color:
                                          AppColors.mutedText),
                                ),
                              )
                            : ListView.separated(
                                controller:
                                    scrollController,
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                        horizontal:
                                            AppSpacing
                                                .s16),
                                itemCount:
                                    _users.length,
                                separatorBuilder:
                                    (context, i) =>
                                        Divider(
                                            height: 1,
                                            color: AppColors
                                                .border),
                                itemBuilder:
                                    (context, index) {
                                  final u =
                                      _users[index];
                                  return ListTile(
                                    onTap: () =>
                                        Navigator.of(
                                                context)
                                            .pop(u),
                                    leading: Container(
                                      width: 40,
                                      height: 40,
                                      decoration:
                                          BoxDecoration(
                                        color: AppColors
                                            .primary500
                                            .withAlpha(
                                                15),
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                                    AppRadius
                                                        .r8),
                                      ),
                                      child:
                                          const Center(
                                        child: FaIcon(
                                            FontAwesomeIcons
                                                .userDoctor,
                                            size: 16,
                                            color: AppColors
                                                .primary500),
                                      ),
                                    ),
                                    title: Text(
                                      u.displayName(
                                          isArabic:
                                              isArabic),
                                      style: Theme.of(
                                              context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight:
                                                FontWeight
                                                    .w600,
                                            color: AppColors
                                                .headingText,
                                          ),
                                    ),
                                    subtitle: Text(
                                      'ID: ${u.userId}${u.phone != null ? ' • ${u.phone}' : ''}',
                                      style: Theme.of(
                                              context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors
                                                .mutedText,
                                          ),
                                    ),
                                    trailing:
                                        const FaIcon(
                                      FontAwesomeIcons
                                          .chevronRight,
                                      size: 14,
                                      color: AppColors
                                          .mutedText,
                                    ),
                                  );
                                },
                              ),
              ),
            ],
          ),
        );
      },
    );
  }
}
