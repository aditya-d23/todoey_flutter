import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/models/productivity_profile.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/app_card.dart';
import '../../onboarding/data/profile_repository.dart';
import '../../planner/data/plan_repository.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _profileRepo = ProfileRepository();
  final _planRepo = PlanRepository();

  int _selected = 0;
  ProductivityProfile? _profile;
  List<Map<String, dynamic>>? _tasks;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Load from Supabase only — NO AI calls.
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

  int _calcScore() {
    if (_tasks == null || _tasks!.isEmpty) return 0;
    final done = _tasks!.where((t) => t['status'] == 'Done').length;
    return (done / _tasks!.length * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Progress Reports')),
        bottomNavigationBar:
            const AppBottomNav(currentRoute: AppRoutes.reports),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Progress Reports')),
      bottomNavigationBar: const AppBottomNav(currentRoute: AppRoutes.reports),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('Daily')),
              ButtonSegment(value: 1, label: Text('Profile')),
            ],
            selected: {_selected},
            onSelectionChanged: (value) =>
                setState(() => _selected = value.first),
          ),
          const SizedBox(height: 16),
          if (_selected == 0) _buildDailyReport(context),
          if (_selected == 1) _buildProfileReport(context),
        ],
      ),
    );
  }

  Widget _buildDailyReport(BuildContext context) {
    final tasks = _tasks ?? [];
    final completed = tasks.where((t) => t['status'] == 'Done').length;
    final snoozed = tasks.where((t) => t['status'] == 'Snoozed').length;
    final pending = tasks.length - completed - snoozed;
    final score = _calcScore();

    // Category breakdown
    final categoryStats = <String, List<int>>{};
    for (final t in tasks) {
      final cat = (t['category'] ?? 'routine') as String;
      categoryStats.putIfAbsent(cat, () => [0, 0]);
      categoryStats[cat]![1]++;
      if (t['status'] == 'Done') categoryStats[cat]![0]++;
    }

    return Column(
      children: [
        // Score
        AppCard(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Today\'s score',
                        style: TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    Text(
                      '$completed done, $snoozed snoozed, $pending pending',
                      style: const TextStyle(color: Color(0xFF627270)),
                    ),
                  ],
                ),
              ),
              Text(
                '$score%',
                style: const TextStyle(
                  color: Color(0xFF0E7C78),
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Category breakdown
        if (categoryStats.isNotEmpty)
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Category breakdown',
                    style: TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                for (final entry in categoryStats.entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.key.toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Text(
                          '${entry.value[0]}/${entry.value[1]}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0E7C78),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 80,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: entry.value[1] > 0
                                  ? entry.value[0] / entry.value[1]
                                  : 0,
                              minHeight: 6,
                              backgroundColor: const Color(0xFFDCE6E3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 14),

        // Coach note (local, no AI)
        AppCard(
          color: const Color(0xFFEAF6F3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.smart_toy,
                      color: Color(0xFF0E7C78), size: 20),
                  const SizedBox(width: 8),
                  Text('Coach Summary',
                      style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _generateLocalCoachNote(completed, tasks.length, snoozed),
                style: const TextStyle(height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Generate coach note locally — NO AI call.
  String _generateLocalCoachNote(int completed, int total, int snoozed) {
    if (total == 0) return 'No tasks scheduled today. Generate a plan first!';

    final score = (completed / total * 100).round();

    if (score >= 80) {
      return 'Excellent day! You completed $completed of $total tasks ($score%). '
          'Keep this momentum going tomorrow.';
    }
    if (score >= 50) {
      return 'Solid progress — $completed of $total tasks done ($score%). '
          '${snoozed > 0 ? "$snoozed tasks snoozed. " : ""}'
          'Focus on finishing remaining tasks before your weak hours.';
    }
    if (score > 0) {
      return 'You\'ve completed $completed of $total tasks so far ($score%). '
          'Try to tackle the most important remaining task next. '
          'Small wins build momentum!';
    }
    return 'No tasks completed yet today. Start with your easiest task '
        'to build momentum, then tackle the bigger ones.';
  }

  Widget _buildProfileReport(BuildContext context) {
    if (_profile == null) {
      return const Center(child: Text('No profile found.'));
    }

    final p = _profile!;

    return Column(
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your coaching profile',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              _ProfileRow('Coaching tone', p.coachingTone),
              _ProfileRow('Wake time', p.wakeTime),
              _ProfileRow('Sleep time', p.sleepTime),
              _ProfileRow('Focus blocks', '${p.focusWindows.length}'),
              _ProfileRow('Annual goals', '${p.annualGoals.length} goals'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AppCard(
          color: const Color(0xFFEAF6F3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Annual goals',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              for (final goal in p.annualGoals)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle,
                          color: Color(0xFF0E7C78), size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(goal)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ElevatedButton(
          onPressed: () =>
              Navigator.of(context).pushNamed(AppRoutes.onboarding),
          child: const Text('Re-run onboarding'),
        ),
      ],
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(color: Color(0xFF627270))),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
