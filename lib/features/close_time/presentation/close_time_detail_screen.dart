import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/models/close_time_request_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_app_bar.dart';
import '../../../core/widgets/app_button.dart';

/// Detail view for a single Close Time Request.
/// Shows Approve / Reject buttons when status is Pending.
class CloseTimeDetailScreen extends StatefulWidget {
  const CloseTimeDetailScreen({super.key, required this.requestId});

  final int requestId;

  @override
  State<CloseTimeDetailScreen> createState() => _CloseTimeDetailScreenState();
}

class _CloseTimeDetailScreenState extends State<CloseTimeDetailScreen> {
  CloseTimeRequestModel? _request;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.getCloseRequestDetails(
        requestId: widget.requestId,
      );
      final data = response['data'] as Map<String, dynamic>;
      _request = CloseTimeRequestModel.fromJson(data);
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
      appBar: AppAppBar(title: isArabic ? 'تفاصيل الطلب' : 'Request Details'),
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
            FaIcon(
              FontAwesomeIcons.circleExclamation,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.s16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.s16),
            OutlinedButton.icon(
              onPressed: _loadDetails,
              icon: const FaIcon(FontAwesomeIcons.arrowsRotate, size: 16),
              label: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isArabic) {
    final req = _request!;
    final statusLabel = isArabic ? req.statusLabelAr : req.statusLabelEn;
    final sc = _statusColor(req.requestStatus);
    final sbg = _statusBgColor(req.requestStatus);

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
                      req.requestStatus.toUpperCase() == 'A'
                          ? FontAwesomeIcons.circleCheck
                          : req.requestStatus.toUpperCase() == 'R'
                          ? FontAwesomeIcons.circleXmark
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
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: sc, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isArabic
                            ? 'رقم الطلب: #${req.requestId}'
                            : 'Request #${req.requestId}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: sc.withAlpha(180),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.s24),

          // ── Details Card ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(AppSpacing.s20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.r20),
            ),
            child: Column(
              children: [
                _DetailRow(
                  icon: FontAwesomeIcons.calendarDay,
                  label: isArabic ? 'التاريخ' : 'Date',
                  value: req.closeTimeDate,
                ),
                const Divider(height: AppSpacing.s24),
                _DetailRow(
                  icon: FontAwesomeIcons.clock,
                  label: isArabic ? 'الوقت' : 'Time',
                  value: req.isFullDay
                      ? (isArabic ? 'يوم كامل' : 'Full Day')
                      : '${req.startTime ?? '--'} - ${req.endTime ?? '--'}',
                ),
                const Divider(height: AppSpacing.s24),
                _DetailRow(
                  icon: FontAwesomeIcons.calendarCheck,
                  label: isArabic ? 'يوم كامل' : 'Full Day',
                  value: req.isFullDay
                      ? (isArabic ? 'نعم' : 'Yes')
                      : (isArabic ? 'لا' : 'No'),
                ),
                if (req.notes != null && req.notes!.isNotEmpty) ...[
                  const Divider(height: AppSpacing.s24),
                  _DetailRow(
                    icon: FontAwesomeIcons.noteSticky,
                    label: isArabic ? 'الملاحظات' : 'Notes',
                    value: req.notes!,
                  ),
                ],
                if (req.createdBy != null && req.createdBy!.isNotEmpty) ...[
                  const Divider(height: AppSpacing.s24),
                  _DetailRow(
                    icon: FontAwesomeIcons.user,
                    label: isArabic ? 'أنشئ بواسطة' : 'Created By',
                    value: req.createdBy!,
                  ),
                ],
                if (req.createdDate != null) ...[
                  const Divider(height: AppSpacing.s24),
                  _DetailRow(
                    icon: FontAwesomeIcons.clockRotateLeft,
                    label: isArabic ? 'تاريخ الإنشاء' : 'Created At',
                    value: req.createdDate!,
                  ),
                ],
              ],
            ),
          ),

          // ── Action buttons (only when Pending) ────────────────
          if (req.requestStatus.toUpperCase() == 'P') ...[
            const SizedBox(height: AppSpacing.s32),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: isArabic ? 'قبول' : 'Approve',
                    type: AppButtonType.primary,
                    icon: FontAwesomeIcons.check,
                    onPressed: () {
                      // TODO: wire to approve API later
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isArabic
                                ? 'سيتم الربط لاحقاً'
                                : 'Will be connected later',
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.r12),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: AppButton(
                    text: isArabic ? 'رفض' : 'Reject',
                    type: AppButtonType.secondary,
                    icon: FontAwesomeIcons.xmark,
                    onPressed: () {
                      // TODO: wire to reject API later
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isArabic
                                ? 'سيتم الربط لاحقاً'
                                : 'Will be connected later',
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.r12),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],

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
            color: AppColors.primary100,
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
                  color: AppColors.textPrimary,
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
