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

/// Lists all close-time requests made by the current doctor.
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
          .map((e) => CloseTimeRequestModel.fromJson(e as Map<String, dynamic>))
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
      case 'P':
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
      case 'P':
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
          : RefreshIndicator(
              onRefresh: _loadRequests,
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.s16),
                itemCount: _requests.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.s12),
                itemBuilder: (context, index) => _RequestCard(
                  request: _requests[index],
                  isArabic: isArabic,
                  statusColor: _statusColor(_requests[index].requestStatus),
                  statusBgColor: _statusBgColor(_requests[index].requestStatus),
                  onTap: () async {
                    await context.push(
                      '/close-time/detail/${_requests[index].requestId}',
                    );
                    _loadRequests();
                  },
                ),
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
          FaIcon(
            FontAwesomeIcons.calendarXmark,
            size: 56,
            color: AppColors.mutedText.withAlpha(120),
          ),
          const SizedBox(height: AppSpacing.s16),
          Text(
            isArabic ? 'لا توجد طلبات' : 'No Requests Found',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.mutedText),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            isArabic
                ? 'اضغط + لإنشاء طلب جديد'
                : 'Tap + to create a new request',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }
}

// ─── Request Card ─────────────────────────────────────────────────────────

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.request,
    required this.isArabic,
    required this.statusColor,
    required this.statusBgColor,
    required this.onTap,
  });

  final CloseTimeRequestModel request;
  final bool isArabic;
  final Color statusColor;
  final Color statusBgColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusLabel = isArabic
        ? request.statusLabelAr
        : request.statusLabelEn;
    final timeRange = request.isFullDay
        ? (isArabic ? 'يوم كامل' : 'Full Day')
        : '${request.startTime ?? '--'} - ${request.endTime ?? '--'}';

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
            // Date column
            Container(
              width: 54,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.softGreen,
                borderRadius: BorderRadius.circular(AppRadius.r12),
              ),
              child: Column(
                children: [
                  Text(
                    _dayFromDate(request.closeTimeDate),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.greenDark,
                    ),
                  ),
                  Text(
                    _monthFromDate(request.closeTimeDate),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.greenDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.s12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.closeTimeDate,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.clock,
                        size: 12,
                        color: AppColors.mutedText,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        timeRange,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                  if (request.notes != null && request.notes!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      request.notes!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.s8),

            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: statusBgColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _dayFromDate(String date) {
    try {
      return DateTime.parse(date).day.toString();
    } catch (_) {
      return '--';
    }
  }

  String _monthFromDate(String date) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    try {
      return months[DateTime.parse(date).month - 1];
    } catch (_) {
      return '';
    }
  }
}
