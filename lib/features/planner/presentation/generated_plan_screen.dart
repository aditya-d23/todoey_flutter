import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/data/demo_content.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/app_card.dart';

class GeneratedPlanScreen extends StatelessWidget {
  const GeneratedPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generated Plan')),
      bottomNavigationBar: const AppBottomNav(currentRoute: AppRoutes.plan),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            color: const Color(0xFF123533),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Annual target',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ship the productivity app, build a consistent study routine, improve health, and reduce evening procrastination by 70%.',
                  style: TextStyle(color: Colors.white70, height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              Expanded(
                child: _PlanMetric(value: '6:15', label: 'alarm set'),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _PlanMetric(value: '7', label: 'check-ins'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Automated whole-day plan',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                for (final task in demoTasks) _TimelineRow(task: task),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            color: const Color(0xFFEAF6F3),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                AppTag('Auto alarms'),
                AppTag('Completion popups'),
                AppTag('Lag tracking'),
                AppTag('Reports'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: () =>
                Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard),
            child: const Text('Open dashboard'),
          ),
        ],
      ),
    );
  }
}

class _PlanMetric extends StatelessWidget {
  const _PlanMetric({required this.value, required this.label});

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

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.task});

  final DayTask task;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              task.time,
              style: const TextStyle(
                color: Color(0xFF627270),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAF8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task.description,
                    style: const TextStyle(
                      color: Color(0xFF627270),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
