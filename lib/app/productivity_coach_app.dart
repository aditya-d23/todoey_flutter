import 'package:flutter/material.dart';

import '../features/auth/presentation/auth_gate.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/onboarding/presentation/onboarding_chat_screen.dart';
import '../features/planner/presentation/coach_popup_screen.dart';
import '../features/planner/presentation/generated_plan_screen.dart';
import '../features/planner/presentation/schedule_screen.dart';
import '../features/profile/presentation/profile_summary_screen.dart';
import '../features/reports/presentation/reports_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import 'app_routes.dart';
import 'theme.dart';

class ProductivityCoachApp extends StatelessWidget {
  const ProductivityCoachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Productivity Coach',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const AuthGate(),
      routes: {
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.onboarding: (_) => const OnboardingChatScreen(),
        AppRoutes.profile: (_) => const ProfileSummaryScreen(),
        AppRoutes.plan: (_) => const GeneratedPlanScreen(),
        AppRoutes.dashboard: (_) => const DashboardScreen(),
        AppRoutes.schedule: (_) => const ScheduleScreen(),
        AppRoutes.coach: (_) => const CoachPopupScreen(),
        AppRoutes.reports: (_) => const ReportsScreen(),
        AppRoutes.settings: (_) => const SettingsScreen(),
      },
    );
  }
}
