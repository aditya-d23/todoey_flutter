import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/widgets/app_card.dart';

class ProfileSummaryScreen extends StatelessWidget {
  const ProfileSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Automation Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            color: const Color(0xFF123533),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Primary annual mission',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Build the app, study consistently, improve health, and reduce evening procrastination with automated planning.',
                  style: TextStyle(color: Colors.white70, height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              Expanded(
                child: _MetricCard(value: '6:15', label: 'wake alarm'),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _MetricCard(value: '2 PM', label: 'lag risk'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI will automate',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                const _ProfilePoint(
                  'Day-wise plans from annual, monthly, and daily goals.',
                ),
                const _ProfilePoint(
                  'Morning alarms and task completion popups.',
                ),
                const _ProfilePoint(
                  'Lag reasons, report generation, and tomorrow adjustments.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.plan),
            child: const Text('Generate full-day plan'),
          ),
        ],
      ),
    );
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

class _ProfilePoint extends StatelessWidget {
  const _ProfilePoint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF0E7C78), size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
