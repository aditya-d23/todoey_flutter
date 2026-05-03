import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/models/productivity_profile.dart';
import '../../../core/widgets/app_card.dart';
import '../../onboarding/data/profile_repository.dart';

class ProfileSummaryScreen extends StatefulWidget {
  const ProfileSummaryScreen({super.key});

  @override
  State<ProfileSummaryScreen> createState() => _ProfileSummaryScreenState();
}

class _ProfileSummaryScreenState extends State<ProfileSummaryScreen> {
  late final ProfileRepository _repo;
  ProductivityProfile? _profile;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repo = ProfileRepository();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _repo.loadProfile();
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Automation Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Automation Profile')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.orange),
                const SizedBox(height: 16),
                Text(
                  _error ?? 'No profile found. Complete the onboarding chat first.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Go back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final p = _profile!;

    return Scaffold(
      appBar: AppBar(title: const Text('Automation Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Annual Goals
          AppCard(
            color: const Color(0xFF123533),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Annual Goals',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                for (final goal in p.annualGoals)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(color: Colors.white70)),
                        Expanded(
                          child: Text(
                            goal,
                            style: const TextStyle(
                                color: Colors.white70, height: 1.45),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Wake / Sleep metrics
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  value: p.wakeTime.isNotEmpty ? p.wakeTime : '--',
                  label: 'wake time',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  value: p.sleepTime.isNotEmpty ? p.sleepTime : '--',
                  label: 'sleep time',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Coaching tone
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  value: _coachingIcon(p.coachingTone),
                  label: p.coachingTone,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  value: '${p.focusWindows.length}',
                  label: 'focus blocks',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Monthly Milestones
          if (p.monthlyMilestones.isNotEmpty) ...[
            _SectionCard(
              title: 'Monthly Milestones',
              icon: Icons.flag_rounded,
              items: p.monthlyMilestones,
            ),
            const SizedBox(height: 14),
          ],

          // Daily Habits
          if (p.dailyHabits.isNotEmpty) ...[
            _SectionCard(
              title: 'Daily Habits',
              icon: Icons.repeat_rounded,
              items: p.dailyHabits,
            ),
            const SizedBox(height: 14),
          ],

          // Focus Windows
          if (p.focusWindows.isNotEmpty) ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.schedule, color: Color(0xFF0E7C78), size: 20),
                      const SizedBox(width: 8),
                      Text('Focus Windows',
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 12),
                  for (final fw in p.focusWindows)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF6F3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${fw.startTime} – ${fw.endTime}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0E7C78),
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(fw.label,
                                style: const TextStyle(color: Color(0xFF627270))),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Weak Hours & Triggers
          if (p.weakHours.isNotEmpty || p.procrastinationTriggers.isNotEmpty) ...[
            AppCard(
              color: const Color(0xFFFFF8F0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Text('Risk Areas',
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (p.weakHours.isNotEmpty) ...[
                    const Text('Weak hours:',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 4),
                    for (final wh in p.weakHours)
                      _ProfilePoint(wh, color: Colors.orange),
                  ],
                  if (p.procrastinationTriggers.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text('Triggers:',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 4),
                    for (final trigger in p.procrastinationTriggers)
                      _ProfilePoint(trigger, color: Colors.orange),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Recommended Alarms
          if (p.recommendedAlarms.isNotEmpty) ...[
            AppCard(
              color: const Color(0xFFEAF6F3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.alarm, color: Color(0xFF0E7C78), size: 20),
                      const SizedBox(width: 8),
                      Text('Recommended Alarms',
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final alarm in p.recommendedAlarms)
                        Chip(
                          label: Text(alarm, style: const TextStyle(fontSize: 13)),
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFFDCE6E3)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          const SizedBox(height: 4),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.plan),
            child: const Text('Generate full-day plan'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _coachingIcon(String tone) {
    switch (tone.toLowerCase()) {
      case 'strict':
        return '🔥';
      case 'gentle':
        return '🌱';
      case 'motivational':
        return '💪';
      default:
        return '🎯';
    }
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.value, required this.label});

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
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          Text(label, style: const TextStyle(color: Color(0xFF627270))),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.items,
  });

  final String title;
  final IconData icon;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF0E7C78), size: 20),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          for (final item in items)
            _ProfilePoint(item, color: const Color(0xFF0E7C78)),
        ],
      ),
    );
  }
}

class _ProfilePoint extends StatelessWidget {
  const _ProfilePoint(this.text, {required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(height: 1.35)),
          ),
        ],
      ),
    );
  }
}
