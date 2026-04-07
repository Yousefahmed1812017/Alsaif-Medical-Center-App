import 'package:flutter/material.dart';

import '../../../core/services/auth_service.dart';
import 'admin_dashboard_screen.dart';
import 'doctor_dashboard_screen.dart';
import 'employee_dashboard_screen.dart';

/// Dispatches to the correct role-specific dashboard based on the route
/// parameter and the logged-in user data.
class DashboardDispatcher extends StatelessWidget {
  final String role;

  const DashboardDispatcher({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    // Determine which dashboard to show
    final effectiveRole = user?.roleKey ?? role;

    switch (effectiveRole) {
      case 'admin':
        return AdminDashboardScreen(user: user!);
      case 'doctor':
        return DoctorDashboardScreen(user: user!);
      default:
        return EmployeeDashboardScreen(user: user!);
    }
  }
}
