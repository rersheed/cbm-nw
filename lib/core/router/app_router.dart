import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/providers/providers.dart';
import '../../core/constants/app_constants.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/agent/presentation/agent_dashboard.dart';
import '../../features/agent/presentation/registration_wizard.dart';
import '../../features/agent/presentation/membership_card_screen.dart';
import '../../features/ward/presentation/ward_dashboard.dart';
import '../../features/ward/presentation/approval_list_screen.dart';
import '../../features/lga/presentation/lga_dashboard.dart';
import '../../features/state_coord/presentation/state_dashboard.dart';
import '../../features/admin/presentation/admin_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final user = ref.watch(sessionProvider);
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: _RouterRefresh(ref),
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final loggingIn = loc == '/login' || loc == '/forgot' || loc == '/splash' || loc == '/otp';
      if (user == null && !loggingIn) return '/login';
      if (user != null && (loc == '/login' || loc == '/splash' || loc == '/otp')) {
        return _homeForRole(user.role);
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/otp', builder: (_, __) => const OtpScreen()),
      GoRoute(path: '/forgot', builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: '/agent', builder: (_, __) => const AgentDashboard()),
      GoRoute(path: '/agent/register', builder: (_, __) => const RegistrationWizard()),
      GoRoute(
        path: '/agent/card/:memberId',
        builder: (_, s) => MembershipCardScreen(memberId: s.pathParameters['memberId']!),
      ),
      GoRoute(path: '/ward', builder: (_, __) => const WardDashboard()),
      GoRoute(path: '/ward/approvals', builder: (_, __) => const ApprovalListScreen()),
      GoRoute(path: '/lga', builder: (_, __) => const LgaDashboard()),
      GoRoute(path: '/state', builder: (_, __) => const StateDashboard()),
      GoRoute(path: '/admin', builder: (_, __) => const AdminShell()),
    ],
  );
});

String _homeForRole(String role) {
  switch (role) {
    case AppRoles.registrationAgent:
      return '/agent';
    case AppRoles.wardCoordinator:
      return '/ward';
    case AppRoles.lgaCoordinator:
      return '/lga';
    case AppRoles.stateCoordinator:
      return '/state';
    case AppRoles.admin:
      return '/admin';
    default:
      return '/agent';
  }
}

class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(this._ref) {
    _ref.listen(sessionProvider, (_, __) => notifyListeners());
  }
  final Ref _ref;
}
