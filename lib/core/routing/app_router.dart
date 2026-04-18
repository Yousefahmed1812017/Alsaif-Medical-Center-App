import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/internal_login/internal_login_screen.dart';
import '../../features/auth/presentation/internal_login/internal_otp_verification_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/new_patient_placeholder_screen.dart';
import '../../features/auth/presentation/otp_verification_screen.dart';
import '../../features/auth/presentation/patient_type_selection_screen.dart';
import '../../features/auth/presentation/user_type_selection_screen.dart';
import '../../features/close_time/presentation/close_time_detail_screen.dart';
import '../../features/close_time/presentation/close_time_requests_screen.dart';
import '../../features/close_time/presentation/create_close_time_screen.dart';
import '../../features/dashboard/presentation/mock_dashboards.dart';
import '../../features/onboarding/presentation/language_selection_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/patients/presentation/patient_detail_screen.dart';
import '../../features/patients/presentation/patient_search_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/todo_tasks/presentation/todo_tasks_screen.dart';
import '../../features/todo_tasks/presentation/create_todo_task_screen.dart';
import '../../features/todo_tasks/presentation/todo_task_detail_screen.dart';
import '../../features/booking/presentation/booking_flow_screen.dart';
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
          return DashboardDispatcher(role: role);
        },
      ),

      // Profile
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // Close Time Requests
      GoRoute(
        path: '/close-time',
        builder: (context, state) => const CloseTimeRequestsScreen(),
      ),
      GoRoute(
        path: '/close-time/create',
        builder: (context, state) => const CreateCloseTimeScreen(),
      ),
      GoRoute(
        path: '/close-time/detail/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id'] ?? '0');
          return CloseTimeDetailScreen(requestId: id);
        },
      ),

      // Patients
      GoRoute(
        path: '/patients',
        builder: (context, state) => const PatientSearchScreen(),
      ),
      GoRoute(
        path: '/patient-detail/:code',
        builder: (context, state) {
          final code = state.pathParameters['code'] ?? '';
          return PatientDetailScreen(patientCode: code);
        },
      ),

      // To-Do Tasks
      GoRoute(
        path: '/todo-tasks',
        builder: (context, state) => const TodoTasksScreen(),
      ),
      GoRoute(
        path: '/todo-tasks/create',
        builder: (context, state) => const CreateTodoTaskScreen(),
      ),
      GoRoute(
        path: '/todo-tasks/detail/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id'] ?? '0');
          return TodoTaskDetailScreen(taskId: id);
        },
      ),

      // Booking
      GoRoute(
        path: '/booking',
        builder: (context, state) => const BookingFlowScreen(),
      ),
    ],
  );

  static String _getInitialLocation() {
    // Language selection is always shown first so the user picks their language.
    // After that we check onboarding, then go to user-type.
    if (StorageService.selectedLanguage == null) {
      return '/language-selection';
    }
    if (!StorageService.isOnboardingCompleted) {
      return '/onboarding';
    }
    return '/user-type';
  }
}
