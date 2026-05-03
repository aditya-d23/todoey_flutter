import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/models/productivity_profile.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/app_card.dart';
import '../../onboarding/data/profile_repository.dart';
import '../../planner/data/plan_repository.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _profileRepo = ProfileRepository();
  final _planRepo = PlanRepository();

  ProductivityProfile? _profile;
  List<Map<String, dynamic>>? _tasks;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final profile = await _profileRepo.loadProfile();
      final tasks = await _planRepo.loadTodayPlan();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Today')),
        bottomNavigationBar:
            const AppBottomNav(currentRoute: AppRoutes.dashboard),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final tasks = _tasks ?? [];
    final completed = tasks.where((t) => t['status'] == 'Done').length;
    final score = tasks.isNotEmpty
        ? (completed / tasks.length * 100).round()
        : 0;

    // Find next pending task
    final nextTask = tasks.cast<Map<String, dynamic>?>().firstWhere(
          (t) => t!['status'] != 'Done',
          orElse: () => null,
        );

    final goalsOnTrack = _profile?.annualGoals.length ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Today')),
      bottomNavigationBar:
          const AppBottomNav(currentRoute: AppRoutes.dashboard),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _greeting(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
                const CircleAvatar(child: Text('AI')),
              ],
            ),
            const SizedBox(height: 16),

            // Live score
            AppCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Live productivity score',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$completed/${tasks.length} tasks completed today.',
                          style: const TextStyle(
                            color: Color(0xFF627270),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  _ScoreRing(score: score),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Next action
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
                  Text(
                    nextTask != null
                        ? '${nextTask['time']} ${nextTask['title']}'
                        : 'All tasks complete! 🎉',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    nextTask != null
                        ? (nextTask['description'] ?? '') as String
                        : 'Great work today!',
                    style: const TextStyle(color: Colors.white70),
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

            // Metrics
            Row(
              children: [
                Expanded(
                  child: _DashboardMetric(
                    value: '$completed/${tasks.length}',
                    label: 'tasks done',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DashboardMetric(
                    value: '$goalsOnTrack',
                    label: 'annual goals',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Quick actions
            AppCard(
              child: Column(
                children: [
                  _ActionTile(
                    title: _profile?.wakeTime.isNotEmpty == true
                        ? '${_profile!.wakeTime} wake alarm'
                        : 'Wake alarm',
                    status: 'Set',
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.schedule),
                  ),
                  _ActionTile(
                    title: 'Task completion popup',
                    status: nextTask != null ? 'Active' : 'Done',
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.coach),
                  ),
                  _ActionTile(
                    title: 'Daily report',
                    status: _profile?.sleepTime ?? '9 PM',
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.reports),
                  ),
                ],
              ),
            ),

            // No plan generated yet
            if (tasks.isEmpty) ...[
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.plan),
                child: const Text('Generate today\'s plan'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
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
