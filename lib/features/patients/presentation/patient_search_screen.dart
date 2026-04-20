import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/patient_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_app_bar.dart';
import '../../../core/widgets/app_button.dart';

/// Search type for patient lookup.
enum _SearchType { mrn, identity, name, phone }

/// Patient search screen with primary (MR#, Identity No) and
/// expandable additional filters (Name, Phone).
class PatientSearchScreen extends StatefulWidget {
  const PatientSearchScreen({super.key});

  @override
  State<PatientSearchScreen> createState() => _PatientSearchScreenState();
}

class _PatientSearchScreenState extends State<PatientSearchScreen> {
  final _searchController = TextEditingController();
  _SearchType _searchType = _SearchType.mrn;
  bool _showAdvanced = false;
  bool _isLoading = false;
  String? _error;
  List<PatientModel> _results = [];
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _loadAll(); // Load all patients on open
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ─── Load all patients (empty body) ──────────────────────────────────
  Future<void> _loadAll() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _hasSearched = true;
    });

    try {
      final response = await ApiService.getPatients();
      _parseResults(response);
    } on ApiException catch (e) {
      _error = e.message;
      _results = [];
    } catch (e) {
      _error = e.toString();
      _results = [];
    }

    if (mounted) setState(() => _isLoading = false);
  }

  // ─── Search with filter ──────────────────────────────────────────────
  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      // If search field is blank, reload all
      return _loadAll();
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _hasSearched = true;
    });

    try {
      final response = await ApiService.getPatients(
        patientCode: _searchType == _SearchType.mrn ? query : null,
        identityNo: _searchType == _SearchType.identity ? query : null,
        patientName: _searchType == _SearchType.name ? query : null,
        phone: _searchType == _SearchType.phone ? query : null,
      );
      _parseResults(response);
    } on ApiException catch (e) {
      _error = e.message;
      _results = [];
    } catch (e) {
      _error = e.toString();
      _results = [];
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _parseResults(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is List) {
      _results = data
          .map((e) => PatientModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (data is Map<String, dynamic>) {
      _results = [PatientModel.fromJson(data)];
    } else {
      _results = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppAppBar(title: isArabic ? 'البحث عن مريض' : 'Patient Search'),
      body: Column(
        children: [
          // ── Search Section ──────────────────────────────────────
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s20,
              AppSpacing.s16,
              AppSpacing.s20,
              AppSpacing.s20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Primary filter chips
                _FilterChips(
                  selected: _searchType,
                  isArabic: isArabic,
                  showAdvanced: _showAdvanced,
                  onSelected: (type) {
                    setState(() {
                      _searchType = type;
                      _searchController.clear();
                    });
                  },
                  onToggleAdvanced: () {
                    setState(() => _showAdvanced = !_showAdvanced);
                  },
                ),
                const SizedBox(height: AppSpacing.s12),

                // Search bar
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(AppRadius.r12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: TextField(
                          controller: _searchController,
                          textInputAction: TextInputAction.search,
                          keyboardType: _keyboardType,
                          onSubmitted: (_) => _search(),
                          decoration: InputDecoration(
                            hintText: _hintText(isArabic),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(12),
                              child: FaIcon(
                                _searchIcon,
                                size: 18,
                                color: AppColors.mutedText,
                              ),
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.s16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    SizedBox(
                      height: 52,
                      child: AppButton(
                        text: isArabic ? 'بحث' : 'Search',
                        isFullWidth: false,
                        isLoading: _isLoading,
                        onPressed: _search,
                        icon: FontAwesomeIcons.magnifyingGlass,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Subtle separator
          Container(height: 1, color: AppColors.border),

          // ── Results ─────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? _buildError(isArabic)
                : !_hasSearched
                ? _buildPrompt(isArabic)
                : _results.isEmpty
                ? _buildNoResults(isArabic)
                : _buildResults(isArabic),
          ),
        ],
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────

  TextInputType get _keyboardType {
    switch (_searchType) {
      case _SearchType.mrn:
      case _SearchType.identity:
      case _SearchType.phone:
        return TextInputType.number;
      case _SearchType.name:
        return TextInputType.text;
    }
  }

  dynamic get _searchIcon {
    switch (_searchType) {
      case _SearchType.mrn:
        return FontAwesomeIcons.hashtag;
      case _SearchType.identity:
        return FontAwesomeIcons.idCard;
      case _SearchType.name:
        return FontAwesomeIcons.userPen;
      case _SearchType.phone:
        return FontAwesomeIcons.phone;
    }
  }

  String _hintText(bool isArabic) {
    switch (_searchType) {
      case _SearchType.mrn:
        return isArabic ? 'أدخل رقم الملف (MR#)...' : 'Enter MR# number...';
      case _SearchType.identity:
        return isArabic ? 'أدخل رقم الهوية...' : 'Enter Identity No...';
      case _SearchType.name:
        return isArabic ? 'أدخل اسم المريض...' : 'Enter patient name...';
      case _SearchType.phone:
        return isArabic ? 'أدخل رقم الهاتف...' : 'Enter phone number...';
    }
  }

  // ── State Widgets ───────────────────────────────────────────────────

  Widget _buildPrompt(bool isArabic) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary500.withAlpha(12),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.magnifyingGlass,
                  size: 32,
                  color: AppColors.primary500,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            Text(
              isArabic ? 'ابحث عن مريض' : 'Search for a Patient',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.headingText,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              isArabic
                  ? 'استخدم رقم الملف أو رقم الهوية للبحث السريع'
                  : 'Use MR# or Identity No for quick lookup',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(bool isArabic) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.circleExclamation,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.s16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: AppSpacing.s16),
            OutlinedButton.icon(
              onPressed: _search,
              icon: const FaIcon(FontAwesomeIcons.arrowsRotate, size: 16),
              label: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults(bool isArabic) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.userSlash,
            size: 48,
            color: AppColors.mutedText.withAlpha(120),
          ),
          const SizedBox(height: AppSpacing.s16),
          Text(
            isArabic ? 'لا توجد نتائج' : 'No Results Found',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.mutedText),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            isArabic
                ? 'جرّب البحث بمعيار آخر'
                : 'Try searching with a different criteria',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s20,
            AppSpacing.s16,
            AppSpacing.s20,
            AppSpacing.s8,
          ),
          child: Text(
            isArabic
                ? '${_results.length} نتيجة'
                : '${_results.length} result${_results.length == 1 ? '' : 's'}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.mutedText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s20,
              0,
              AppSpacing.s20,
              AppSpacing.s20,
            ),
            itemCount: _results.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.s12),
            itemBuilder: (context, index) {
              final patient = _results[index];
              return _PatientCard(
                patient: patient,
                isArabic: isArabic,
                onTap: () {
                  context.push('/patient-detail/${patient.patientCode ?? ""}');
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Filter Chips ─────────────────────────────────────────────────────────

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.selected,
    required this.isArabic,
    required this.showAdvanced,
    required this.onSelected,
    required this.onToggleAdvanced,
  });

  final _SearchType selected;
  final bool isArabic;
  final bool showAdvanced;
  final ValueChanged<_SearchType> onSelected;
  final VoidCallback onToggleAdvanced;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Primary filters
        Row(
          children: [
            _Chip(
              label: 'MR#',
              icon: FontAwesomeIcons.hashtag,
              isSelected: selected == _SearchType.mrn,
              onTap: () => onSelected(_SearchType.mrn),
            ),
            const SizedBox(width: AppSpacing.s8),
            _Chip(
              label: isArabic ? 'رقم الهوية' : 'Identity No',
              icon: FontAwesomeIcons.idCard,
              isSelected: selected == _SearchType.identity,
              onTap: () => onSelected(_SearchType.identity),
            ),
            const Spacer(),
            // Toggle advanced
            GestureDetector(
              onTap: onToggleAdvanced,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: showAdvanced
                      ? AppColors.primary500.withAlpha(15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.r8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FaIcon(
                      showAdvanced
                          ? FontAwesomeIcons.chevronUp
                          : FontAwesomeIcons.sliders,
                      size: 12,
                      color: AppColors.primary500,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isArabic ? 'المزيد' : 'More',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Advanced filters (expandable)
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState: showAdvanced
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.s8),
            child: Row(
              children: [
                _Chip(
                  label: isArabic ? 'الاسم' : 'Name',
                  icon: FontAwesomeIcons.userPen,
                  isSelected: selected == _SearchType.name,
                  onTap: () => onSelected(_SearchType.name),
                ),
                const SizedBox(width: AppSpacing.s8),
                _Chip(
                  label: isArabic ? 'الهاتف' : 'Phone',
                  icon: FontAwesomeIcons.phone,
                  isSelected: selected == _SearchType.phone,
                  onTap: () => onSelected(_SearchType.phone),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final dynamic icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary500 : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppRadius.r8),
          border: Border.all(
            color: isSelected ? AppColors.primary500 : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              icon,
              size: 12,
              color: isSelected ? AppColors.white : AppColors.mutedText,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected ? AppColors.white : AppColors.bodyText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Patient Card ─────────────────────────────────────────────────────────

class _PatientCard extends StatelessWidget {
  const _PatientCard({
    required this.patient,
    required this.isArabic,
    required this.onTap,
  });

  final PatientModel patient;
  final bool isArabic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary100,
                borderRadius: BorderRadius.circular(AppRadius.r12),
              ),
              child: Center(
                child: Text(
                  _initials(patient.displayName),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primary500,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.displayName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.headingText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (patient.patientCode != null) ...[
                        _InfoBadge(
                          icon: FontAwesomeIcons.hashtag,
                          text: patient.patientCode!,
                        ),
                        const SizedBox(width: AppSpacing.s8),
                      ],
                      if (patient.phone != null || patient.mobile != null)
                        _InfoBadge(
                          icon: FontAwesomeIcons.phone,
                          text: patient.mobile ?? patient.phone ?? '',
                        ),
                    ],
                  ),
                  if (patient.identityNo != null) ...[
                    const SizedBox(height: 4),
                    _InfoBadge(
                      icon: FontAwesomeIcons.idCard,
                      text: patient.identityNo!,
                    ),
                  ],
                ],
              ),
            ),

            // Chevron
            const FaIcon(
              FontAwesomeIcons.chevronRight,
              size: 14,
              color: AppColors.mutedText,
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({required this.icon, required this.text});
  final dynamic icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FaIcon(icon, size: 10, color: AppColors.mutedText),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.mutedText,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
