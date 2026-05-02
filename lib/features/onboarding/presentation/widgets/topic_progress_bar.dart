import 'package:flutter/material.dart';

import '../../../../core/widgets/app_card.dart';

/// A progress bar showing how many onboarding topics the AI has covered.
///
/// Progress is driven by the [PROGRESS:X/8] markers parsed from AI responses.
class TopicProgressBar extends StatelessWidget {
  const TopicProgressBar({required this.progress, super.key});

  /// Value between 0.0 and 1.0.
  final double progress;

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: AppCard(
        color: const Color(0xFFEAF6F3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Automation profile progress',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                Text(
                  '$percent%',
                  style: const TextStyle(
                    color: Color(0xFF0E7C78),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: const Color(0xFFD0E8E4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
