import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/records/records_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/rfid/rfid_monitor_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String records = '/records';
  static const String dashboard = '/dashboard';
  static const String rfidMonitor = '/rfid-monitor';

  static GoRouter router() {
    return GoRouter(
      initialLocation: splash,
      debugLogDiagnostics: false,
      routes: [
        GoRoute(
          path: splash,
          pageBuilder: (context, state) => _fadeTransition(
            state,
            const SplashScreen(),
          ),
        ),
        GoRoute(
          path: login,
          pageBuilder: (context, state) => _slideTransition(
            state,
            const LoginScreen(),
          ),
        ),
        GoRoute(
          path: home,
          pageBuilder: (context, state) => _slideTransition(
            state,
            const HomeScreen(),
          ),
        ),
        GoRoute(
          path: records,
          pageBuilder: (context, state) => _slideTransition(
            state,
            const RecordsScreen(),
          ),
        ),
        GoRoute(
          path: dashboard,
          pageBuilder: (context, state) => _slideTransition(
            state,
            const DashboardScreen(),
          ),
        ),
        GoRoute(
          path: rfidMonitor,
          pageBuilder: (context, state) => _slideTransition(
            state,
            const RfidMonitorScreen(),
          ),
        ),
      ],
    );
  }

  static CustomTransitionPage _fadeTransition(
      GoRouterState state, Widget child) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 600),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  static CustomTransitionPage _slideTransition(
      GoRouterState state, Widget child) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 450),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(
          begin: const Offset(0.08, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: animation.drive(tween),
            child: child,
          ),
        );
      },
    );
  }
}
