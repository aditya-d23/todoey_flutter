import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/app_card.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progress Reports')),
      bottomNavigationBar: const AppBottomNav(currentRoute: AppRoutes.reports),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('Daily')),
              ButtonSegment(value: 1, label: Text('Monthly')),
              ButtonSegment(value: 2, label: Text('Annual')),
            ],
            selected: {_selected},
            onSelectionChanged: (value) =>
                setState(() => _selected = value.first),
          ),
          const SizedBox(height: 16),
          if (_selected == 0) const _DailyReport(),
          if (_selected == 1) const _MonthlyReport(),
          if (_selected == 2) const _AnnualReport(),
        ],
      ),
    );
  }
}

class _DailyReport extends StatelessWidget {
  const _DailyReport();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _ScoreCard(
          title: 'Today score',
          score: '74%',
          note: 'Strong morning, slight drift after lunch.',
        ),
        SizedBox(height: 14),
        _Bars(title: 'Planned vs completed', values: [72, 64, 48, 78, 38]),
        SizedBox(height: 14),
        _CoachNote(
          title: 'Coach note',
          note:
              'You won the morning. Tomorrow I will keep hard work before noon and move the health habit before dinner.',
        ),
      ],
    );
  }
}

class _MonthlyReport extends StatelessWidget {
  const _MonthlyReport();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Row(
          children: [
            Expanded(
              child: _Metric(value: '21', label: 'productive days'),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _Metric(value: '68%', label: 'monthly average'),
            ),
          ],
        ),
        SizedBox(height: 14),
        _Bars(title: 'Monthly score trend', values: [42, 56, 61, 74, 68]),
        SizedBox(height: 14),
        _CoachNote(
          title: 'Pattern found',
          note:
              'You finish 82% of tasks before noon and only 39% after 8 PM. The coach will avoid hard tasks late.',
        ),
      ],
    );
  }
}

class _AnnualReport extends StatelessWidget {
  const _AnnualReport();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _ScoreCard(
          title: 'Annual goal progress',
          score: '31%',
          note:
              'App progress is strong. Health consistency needs fixed alarms before dinner.',
        ),
        SizedBox(height: 14),
        _Bars(title: 'Quarterly projection', values: [30, 45, 58, 72]),
        SizedBox(height: 14),
        _CoachNote(
          title: 'Annual coaching decision',
          note:
              'Next month will add exercise alarms and reduce late-night app work.',
        ),
      ],
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.title,
    required this.score,
    required this.note,
  });

  final String title;
  final String score;
  final String note;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(note, style: const TextStyle(color: Color(0xFF627270))),
              ],
            ),
          ),
          Text(
            score,
            style: const TextStyle(
              color: Color(0xFF0E7C78),
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});

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

class _Bars extends StatelessWidget {
  const _Bars({required this.title, required this.values});

  final String title;
  final List<int> values;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          SizedBox(
            height: 132,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final value in values)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FractionallySizedBox(
                        heightFactor: value / 100,
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF0E7C78),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoachNote extends StatelessWidget {
  const _CoachNote({required this.title, required this.note});

  final String title;
  final String note;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: const Color(0xFFEAF6F3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(note, style: const TextStyle(height: 1.4)),
        ],
      ),
    );
  }
}
