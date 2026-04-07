import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_app_bar.dart';
import '../../../core/widgets/app_empty_state.dart';

class NewPatientPlaceholderScreen extends StatelessWidget {
  const NewPatientPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppAppBar(
        title: isArabic ? 'مريض جديد' : 'New Patient',
      ),
      body: AppEmptyState(
        icon: FontAwesomeIcons.screwdriverWrench,
        title: isArabic ? 'قريباً' : 'Coming Soon',
        message: isArabic
            ? 'سيتم تنفيذ مسار تسجيل المرضى الجدد في التحديث القادم.'
            : 'New patient registration flow will be implemented next.',
        actionText: isArabic ? 'العودة' : 'Go Back',
        onActionPressed: () => context.pop(),
      ),
    );
  }
}
