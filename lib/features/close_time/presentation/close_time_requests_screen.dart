import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/close_time_request_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_app_bar.dart';

/// Lists all Close Time Requests for the logged-in doctor.
class CloseTimeRequestsScreen extends StatefulWidget {
  const CloseTimeRequestsScreen({super.key});

  @override
  State<CloseTimeRequestsScreen> createState() =>
      _CloseTimeRequestsScreenState();
}

class _CloseTimeRequestsScreenState extends State<CloseTimeRequestsScreen> {
  List<CloseTimeRequestModel> _requests = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    final user = AuthService.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.getCloseRequests(docId: user.userId);
      final dataList = response['data'] as List<dynamic>;
      _requests = dataList
          .map((e) =>
              CloseTimeRequestModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'A':
        return AppColors.success;
      case 'R':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  Color _statusBgColor(String status) {
    switch (status.toUpperCase()) {
      case 'A':
        return AppColors.successSoft;
      case 'R':
        return AppColors.errorSoft;
      default:
        return AppColors.warningSoft;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppAppBar(
        title: isArabic ? 'طلبات إغلاق المواعيد' : 'Close Time Requests',
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push('/close-time/create');
          if (result == true) _loadRequests();
        },
        tooltip: isArabic ? 'طلب جديد' : 'New Request',
        child: const FaIcon(FontAwesomeIcons.plus, size: 20),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError(isArabic)
              : _requests.isEmpty
                  ? _buildEmpty(isArabic)
                  : _buildList(isArabic),
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
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: AppSpacing.s16),
            OutlinedButton.icon(
              onPressed: _loadRequests,
              icon: const FaIcon(FontAwesomeIcons.arrowsRotate, size: 16),
              label: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(bool isArabic) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(FontAwesomeIcons.calendarXmark,
              size: 56, color: AppColors.mutedText.withAlpha(120)),
          const SizedBox(height: AppSpacing.s16),
          Text(
            isArabic ? 'لا توجد طلبات' : 'No Requests',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: AppColors.mutedText),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            isArabic
                ? 'اضغط + لإنشاء طلب إغلاق جديد'
                : 'Tap + to create a new close time request',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }

  Widget _buildList(bool isArabic) {
    return RefreshIndicator(
      onRefresh: _loadRequests,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s16,
          AppSpacing.s8,
          AppSpacing.s16,
          AppSpacing.s48 * 2,
        ),
        itemCount: _requests.length,
        separatorBuilder: (context, i) =>
            const SizedBox(height: AppSpacing.s12),
        itemBuilder: (context, index) {
          final req = _requests[index];
          final statusLabel =
              isArabic ? req.statusLabelAr : req.statusLabelEn;
          final sc = _statusColor(req.requestStatus);
          final sbg = _statusBgColor(req.requestStatus);

          return GestureDetector(
            onTap: () async {
              await context.push('/close-time/detail/${req.requestId}');
              _loadRequests();
            },
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
                  // ── Top row: date + status badge ────────────────
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.primary500.withAlpha(15),
                          borderRadius:
                              BorderRadius.circular(AppRadius.r12),
                        ),
                        child: const Center(
                          child: FaIcon(FontAwesomeIcons.calendarDay,
                              size: 18, color: AppColors.primary500),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              req.closeTimeDate,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.headingText,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${isArabic ? 'رقم الطلب:' : 'Request #'}${req.requestId}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.mutedText,
                                    fontSize: 11,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: sbg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          statusLabel,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: sc,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.s12),
                  Divider(
                      height: 1,
                      color: AppColors.border.withAlpha(120)),
                  const SizedBox(height: AppSpacing.s12),

                  // ── Bottom row: time info ──────────────────────
                  Row(
                    children: [
                      FaIcon(FontAwesomeIcons.clock,
                          size: 12, color: AppColors.mutedText),
                      const SizedBox(width: 6),
                      Text(
                        req.isFullDay
                            ? (isArabic ? 'يوم كامل' : 'Full Day')
                            : '${req.startTime ?? '--'} - ${req.endTime ?? '--'}',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              color: AppColors.bodyText,
                              fontSize: 12,
                            ),
                      ),
                      if (req.notes != null &&
                          req.notes!.isNotEmpty) ...[
                        const SizedBox(width: AppSpacing.s16),
                        FaIcon(FontAwesomeIcons.noteSticky,
                            size: 11, color: AppColors.mutedText),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            req.notes!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppColors.mutedText,
                                  fontSize: 11,
                                ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
