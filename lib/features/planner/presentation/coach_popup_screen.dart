import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/models/productivity_profile.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/app_card.dart';
import '../../onboarding/data/profile_repository.dart';
import '../data/plan_repository.dart';

class CoachPopupScreen extends StatefulWidget {
  const CoachPopupScreen({super.key});

  @override
  State<CoachPopupScreen> createState() => _CoachPopupScreenState();
}

class _CoachPopupScreenState extends State<CoachPopupScreen> {
  final _profileRepo = ProfileRepository();
  final _planRepo = PlanRepository();
  final _reasonController = TextEditingController();

  ProductivityProfile? _profile;
  Map<String, dynamic>? _currentTask;
  int? _currentTaskIndex;
  String _statusMessage = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  /// Load from Supabase only — NO AI calls.
  Future<void> _loadData() async {
    try {
      final profile = await _profileRepo.loadProfile();
      final tasks = await _planRepo.loadTodayPlan();

      Map<String, dynamic>? current;
      int? currentIndex;
      if (tasks != null) {
        for (var i = 0; i < tasks.length; i++) {
          if (tasks[i]['status'] != 'Done') {
            current = tasks[i];
            currentIndex = i;
            break;
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _profile = profile;
        _currentTask = current;
        _currentTaskIndex = currentIndex;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  /// Update task status in Supabase — NO AI calls.
  Future<void> _submitUpdate(String status) async {
    if (_currentTaskIndex == null) return;

    await _planRepo.updateTaskStatus(_currentTaskIndex!, status);

    final reason = _reasonController.text.trim();

    setState(() {
      _statusMessage = status == 'Done'
          ? '✅ Completed! Great work. Keep the momentum going.'
          : status == 'Snoozed'
              ? '⏰ Snoozed. I\'ll check back later.'
              : '📝 Noted${reason.isNotEmpty ? ": $reason" : "."}. Let\'s adjust tomorrow.';
    });

    // Move to next task
    final tasks = await _planRepo.loadTodayPlan();
    if (tasks != null) {
      for (var i = 0; i < tasks.length; i++) {
        if (tasks[i]['status'] != 'Done' && tasks[i]['status'] != 'Snoozed') {
          if (!mounted) return;
          setState(() {
            _currentTask = tasks[i];
            _currentTaskIndex = i;
          });
          return;
        }
      }
    }

    if (!mounted) return;
    setState(() {
      _currentTask = null;
      _currentTaskIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Coach Popup')),
        bottomNavigationBar: const AppBottomNav(currentRoute: AppRoutes.coach),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Coach Popup')),
      bottomNavigationBar: const AppBottomNav(currentRoute: AppRoutes.coach),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Current task
          AppCard(
            color: const Color(0xFF123533),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppTag('Task popup'),
                const SizedBox(height: 14),
                Text(
                  _currentTask != null
                      ? 'Did you complete "${_currentTask!['title']}"?'
                      : 'All tasks completed! 🎉',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  _currentTask != null
                      ? (_currentTask!['description'] ?? '') as String
                      : 'Great job today! Check your reports.',
                  style: const TextStyle(color: Colors.white70, height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Response input
          if (_currentTask != null) ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppTag('Your update'),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _reasonController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'What happened? Any blockers...',
                      labelText: 'Update / lag reason',
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton(
                        onPressed: () => _submitUpdate('Done'),
                        child: const Text('Completed'),
                      ),
                      FilledButton.tonal(
                        onPressed: () => _submitUpdate('Not done'),
                        child: const Text('Not done'),
                      ),
                      FilledButton.tonal(
                        onPressed: () => _submitUpdate('Snoozed'),
                        child: const Text('Snooze'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Status message (local, no AI)
          if (_statusMessage.isNotEmpty)
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
                      Text('Coach',
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(_statusMessage,
                      style: const TextStyle(height: 1.45)),
                ],
              ),
            ),

          // Procrastination triggers from profile (no AI)
          if (_profile != null &&
              _profile!.procrastinationTriggers.isNotEmpty) ...[
            const SizedBox(height: 14),
            AppCard(
              color: const Color(0xFFFFF8F0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Known triggers',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _profile!.procrastinationTriggers
                        .map((t) =>
                            AppTag(t, color: const Color(0xFFFFE0B2)))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () => Navigator.of(context)
                .pushReplacementNamed(AppRoutes.reports),
            child: const Text('View reports'),
          ),
        ],
      ),
    );
  }
}
