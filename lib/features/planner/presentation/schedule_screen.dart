import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/app_card.dart';
import '../data/plan_repository.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final _planRepo = PlanRepository();
  List<Map<String, dynamic>>? _tasks;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  Future<void> _loadPlan() async {
    try {
      final tasks = await _planRepo.loadTodayPlan();
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Whole Day Plan')),
        bottomNavigationBar: const AppBottomNav(currentRoute: AppRoutes.plan),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_tasks == null || _tasks!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Whole Day Plan')),
        bottomNavigationBar: const AppBottomNav(currentRoute: AppRoutes.plan),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No plan generated yet.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.plan),
                child: const Text('Generate plan'),
              ),
            ],
          ),
        ),
      );
    }

    final completed =
        _tasks!.where((t) => t['status'] == 'Done').length;
    final score =
        (_tasks!.isNotEmpty ? completed / _tasks!.length * 100 : 0).round();

    return Scaffold(
      appBar: AppBar(title: const Text('Whole Day Plan')),
      bottomNavigationBar: const AppBottomNav(currentRoute: AppRoutes.plan),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            color: const Color(0xFFEAF6F3),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Auto-scheduled from your goals and habits.',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  '$score%',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0E7C78),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          for (var index = 0; index < _tasks!.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ScheduleTaskCard(
                task: _tasks![index],
                onStatusChanged: (status) async {
                  setState(() => _tasks![index]['status'] = status);
                  await _planRepo.updateTaskStatus(index, status);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ScheduleTaskCard extends StatelessWidget {
  const _ScheduleTaskCard({
    required this.task,
    required this.onStatusChanged,
  });

  final Map<String, dynamic> task;
  final ValueChanged<String> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final status = (task['status'] ?? 'Pending') as String;
    final isDone = status == 'Done';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 72,
                child: Text(
                  (task['time'] ?? '') as String,
                  style: const TextStyle(
                    color: Color(0xFF627270),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  (task['title'] ?? '') as String,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    color: isDone ? const Color(0xFF627270) : null,
                  ),
                ),
              ),
              AppTag(status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            (task['description'] ?? '') as String,
            style: const TextStyle(color: Color(0xFF627270), height: 1.35),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonal(
                onPressed: isDone ? null : () => onStatusChanged('Done'),
                child: const Text('Done'),
              ),
              FilledButton.tonal(
                onPressed: () => onStatusChanged('Snoozed'),
                child: const Text('Snooze'),
              ),
              FilledButton.tonal(
                onPressed: () => onStatusChanged('Rescheduled'),
                child: const Text('Reschedule'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
