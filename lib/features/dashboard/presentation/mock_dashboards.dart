import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/widgets/app_empty_state.dart';

class MockInternalDashboardScreen extends StatelessWidget {
  final String role;
  
  const MockInternalDashboardScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    dynamic roleIcon = FontAwesomeIcons.userTie;
    String displayRole = role.toUpperCase();

    if (role == 'admin') {
      roleIcon = FontAwesomeIcons.userGear;
    } else if (role == 'doctor') {
      roleIcon = FontAwesomeIcons.userDoctor;
    } else if (role == 'manager') {
      roleIcon = FontAwesomeIcons.briefcase;
    }

    return Scaffold(
      appBar: AppAppBar(
        title: isArabic ? 'لوحة تحكم: $displayRole' : 'Dashboard: $displayRole',
        showBackButton: false, // Usually root of flow
      ),
      body: AppEmptyState(
        icon: roleIcon,
        title: isArabic ? 'مرحباً بك' : 'Welcome',
        message: isArabic
            ? 'هذه مساحة عمل $displayRole. سيتم ربط البيانات لاحقاً.'
            : 'This is the $displayRole workspace. Data will be mapped later.',
      ),
    );
  }
}
