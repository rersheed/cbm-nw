import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/providers/providers.dart';
import '../../core/constants/app_constants.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/member/presentation/member_home.dart';
import '../../features/member/presentation/registration_wizard.dart';
import '../../features/member/presentation/membership_card_screen.dart';
import '../../features/member/presentation/member_profile_screen.dart';
import '../../features/admin/presentation/admin_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final user = ref.watch(sessionProvider);
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: _RouterRefresh(ref),
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final loggingIn = loc == '/login' ||
          loc == '/forgot' ||
          loc == '/splash' ||
          loc == '/otp' ||
          loc == '/register';
      if (user == null && !loggingIn) return '/login';
      if (user != null && (loc == '/login' || loc == '/splash' || loc == '/otp' || loc == '/register')) {
        return _homeForRole(user.role);
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/otp', builder: (_, __) => const OtpScreen()),
      GoRoute(path: '/forgot', builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: '/member', builder: (_, __) => const MemberHome()),
      GoRoute(path: '/member/register', builder: (_, __) => const RegistrationWizard()),
      GoRoute(path: '/member/profile', builder: (_, __) => const MemberProfileScreen()),
      GoRoute(
        path: '/member/card/:memberId',
        builder: (_, s) => MembershipCardScreen(memberId: s.pathParameters['memberId']!),
      ),
      GoRoute(path: '/admin', builder: (_, __) => const AdminShell()),
    ],
  );
});

String _homeForRole(String role) {
  switch (role) {
    case AppRoles.admin:
      return '/admin';
    case AppRoles.member:
    default:
      return '/member';
  }
}

class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(this._ref) {
    _ref.listen(sessionProvider, (_, __) => notifyListeners());
  }
  final Ref _ref;
}
