import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/app_card.dart';
import '../../auth/data/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authService = AuthService();

  bool floatingCoach = true;
  bool smartAlarms = true;
  bool distractionDetection = false;
  bool dailyEmail = true;
  bool monthlyEmail = true;
  bool signingOut = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      bottomNavigationBar: const AppBottomNav(currentRoute: AppRoutes.settings),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Column(
              children: [
                _SettingSwitch(
                  title: 'Floating coach',
                  subtitle: 'Show overlay-style reminders in the app.',
                  value: floatingCoach,
                  onChanged: (value) => setState(() => floatingCoach = value),
                ),
                _SettingSwitch(
                  title: 'Smart alarms',
                  subtitle: 'Let the app schedule wake and task reminders.',
                  value: smartAlarms,
                  onChanged: (value) => setState(() => smartAlarms = value),
                ),
                _SettingSwitch(
                  title: 'Distraction detection',
                  subtitle: 'Future Android app usage permission.',
                  value: distractionDetection,
                  onChanged: (value) =>
                      setState(() => distractionDetection = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Email reports',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                _SettingSwitch(
                  title: 'Daily summary email',
                  subtitle: 'Send the daily productivity summary.',
                  value: dailyEmail,
                  onChanged: (value) => setState(() => dailyEmail = value),
                ),
                _SettingSwitch(
                  title: 'Monthly report email',
                  subtitle: 'Send monthly progress and coaching decisions.',
                  value: monthlyEmail,
                  onChanged: (value) => setState(() => monthlyEmail = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            color: const Color(0xFFEAF6F3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Focus hours',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 10),
                Text('Deep work: 9 AM - 12 PM'),
                Text('Quiet hours: 10 PM - 6 AM'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: signingOut ? null : _signOut,
            icon: signingOut
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    setState(() => signingOut = true);

    try {
      await _authService.signOut();
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => signingOut = false);
      }
    }
  }
}

class _SettingSwitch extends StatelessWidget {
  const _SettingSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }
}
