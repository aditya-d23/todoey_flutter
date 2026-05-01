import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/data/demo_content.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/app_card.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final _statuses = demoTasks.map((task) => task.status).toList();

  @override
  Widget build(BuildContext context) {
    final completed = _statuses.where((status) => status == 'Done').length;
    final score = (completed / demoTasks.length * 100).round();

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
                    'Auto-scheduled from your annual, monthly, and daily goals.',
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
          for (var index = 0; index < demoTasks.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ScheduleTaskCard(
                task: demoTasks[index],
                status: _statuses[index],
                onStatusChanged: (status) {
                  setState(() => _statuses[index] = status);
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
    required this.status,
    required this.onStatusChanged,
  });

  final DayTask task;
  final String status;
  final ValueChanged<String> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 72,
                child: Text(
                  task.time,
                  style: const TextStyle(
                    color: Color(0xFF627270),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              AppTag(status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            task.description,
            style: const TextStyle(color: Color(0xFF627270), height: 1.35),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonal(
                onPressed: () => onStatusChanged('Done'),
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
