import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/data/demo_content.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/app_card.dart';

class CoachPopupScreen extends StatefulWidget {
  const CoachPopupScreen({super.key});

  @override
  State<CoachPopupScreen> createState() => _CoachPopupScreenState();
}

class _CoachPopupScreenState extends State<CoachPopupScreen> {
  String _status = 'Awaiting response';
  final _reasonController = TextEditingController(
    text: 'I got distracted after lunch and need this task broken smaller.',
  );

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coach Popup')),
      bottomNavigationBar: const AppBottomNav(currentRoute: AppRoutes.coach),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            color: const Color(0xFF123533),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppTag('Task popup'),
                const SizedBox(height: 14),
                Text(
                  'Did you complete your deep work block?',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your goal was 25 minutes on the app prototype. Tell me what happened so I can update your score and tomorrow plan.',
                  style: TextStyle(color: Colors.white70, height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTag(_status),
                const SizedBox(height: 14),
                TextField(
                  controller: _reasonController,
                  minLines: 3,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Lag reason / what should be added?',
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton(
                      onPressed: () => _setStatus('Completed. Report updated.'),
                      child: const Text('Completed'),
                    ),
                    FilledButton.tonal(
                      onPressed: () =>
                          _setStatus('Lagging. Tomorrow will adjust.'),
                      child: const Text('Not done'),
                    ),
                    FilledButton.tonal(
                      onPressed: () => _setStatus('Snoozed 15 min.'),
                      child: const Text('Snooze'),
                    ),
                    FilledButton.tonal(
                      onPressed: () => _setStatus('Extra reminder added.'),
                      child: const Text('Add reminder'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            color: const Color(0xFFEAF6F3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Common lag reasons',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: lagReasons.map(AppTag.new).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: () =>
                Navigator.of(context).pushReplacementNamed(AppRoutes.reports),
            child: const Text('View updated report'),
          ),
        ],
      ),
    );
  }

  void _setStatus(String status) {
    setState(() => _status = status);
  }
}
