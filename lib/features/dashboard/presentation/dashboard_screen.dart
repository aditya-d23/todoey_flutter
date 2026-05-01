import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/app_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Today')),
      bottomNavigationBar: const AppBottomNav(
        currentRoute: AppRoutes.dashboard,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Good morning, Aditya',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const CircleAvatar(child: Text('AI')),
            ],
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Live productivity score',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Score changes from alarms, task popups, lag reasons, and completed goals.',
                        style: TextStyle(
                          color: Color(0xFF627270),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                _ScoreRing(score: 74),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            color: const Color(0xFF123533),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Next automated action',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                const Text(
                  '9:30 AM app-building focus block',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Coach will show a popup at start, midway, and end.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.schedule),
                  child: const Text('View schedule'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              Expanded(
                child: _DashboardMetric(value: '3/5', label: 'goals on track'),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _DashboardMetric(value: '2', label: 'nudges left'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              children: [
                _ActionTile(
                  title: '6:15 wake alarm',
                  status: 'Set',
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.schedule),
                ),
                _ActionTile(
                  title: 'Task completion popup',
                  status: 'Now',
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.coach),
                ),
                _ActionTile(
                  title: 'Night report',
                  status: '9 PM',
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.reports),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 88,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 10,
            backgroundColor: const Color(0xFFDCE6E3),
          ),
          Center(
            child: Text(
              '$score%',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardMetric extends StatelessWidget {
  const _DashboardMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
          ),
          Text(label, style: const TextStyle(color: Color(0xFF627270))),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.title,
    required this.status,
    required this.onTap,
  });

  final String title;
  final String status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      trailing: AppTag(status),
      onTap: onTap,
    );
  }
}
