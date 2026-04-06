import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/internal_login/internal_login_screen.dart';
import '../../features/auth/presentation/internal_login/internal_otp_verification_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/new_patient_placeholder_screen.dart';
import '../../features/auth/presentation/otp_verification_screen.dart';
import '../../features/auth/presentation/patient_type_selection_screen.dart';
import '../../features/auth/presentation/user_type_selection_screen.dart';
import '../../features/dashboard/presentation/mock_dashboards.dart';
import '../../features/onboarding/presentation/language_selection_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../services/storage_service.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: _getInitialLocation(),
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/language-selection',
        builder: (context, state) => const LanguageSelectionScreen(),
      ),
      GoRoute(
        path: '/user-type',
        builder: (context, state) => const UserTypeSelectionScreen(),
      ),
      // Patient Routes
      GoRoute(
        path: '/patient-type',
        builder: (context, state) => const PatientTypeSelectionScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) => const OtpVerificationScreen(),
      ),
      GoRoute(
        path: '/new-patient',
        builder: (context, state) => const NewPatientPlaceholderScreen(),
      ),

      // Internal User Routes
      GoRoute(
        path: '/internal-login',
        builder: (context, state) => const InternalLoginScreen(),
      ),
      GoRoute(
        path: '/internal-otp/:role',
        builder: (context, state) {
          final role = state.pathParameters['role'] ?? 'employee';
          return InternalOtpVerificationScreen(role: role);
        },
      ),
      GoRoute(
        path: '/internal-dashboard/:role',
        builder: (context, state) {
          final role = state.pathParameters['role'] ?? 'employee';
          return MockInternalDashboardScreen(role: role);
        },
      ),
    ],
  );

  static String _getInitialLocation() {
    if (!StorageService.isOnboardingCompleted) {
      return '/onboarding';
    }
    if (StorageService.selectedLanguage == null) {
      return '/language-selection';
    }
    return '/user-type';
  }
}
