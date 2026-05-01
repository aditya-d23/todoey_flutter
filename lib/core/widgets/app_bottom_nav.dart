import 'package:flutter/material.dart';

import '../../app/app_routes.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({required this.currentRoute, super.key});

  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        final route = _routes[index];
        if (route != currentRoute) {
          Navigator.of(context).pushReplacementNamed(route);
        }
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.event_note), label: 'Plan'),
        NavigationDestination(
          icon: Icon(Icons.chat_bubble_outline),
          label: 'Coach',
        ),
        NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Reports'),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          label: 'Settings',
        ),
      ],
    );
  }

  int get _selectedIndex {
    final index = _routes.indexOf(currentRoute);
    return index == -1 ? 0 : index;
  }

  static const _routes = [
    AppRoutes.dashboard,
    AppRoutes.plan,
    AppRoutes.coach,
    AppRoutes.reports,
    AppRoutes.settings,
  ];
}
