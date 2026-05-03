import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/ai/plan_generation_service.dart';
import '../../../core/models/productivity_profile.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/app_card.dart';
import '../../onboarding/data/profile_repository.dart';
import '../data/plan_repository.dart';

class GeneratedPlanScreen extends StatefulWidget {
  const GeneratedPlanScreen({super.key});

  @override
  State<GeneratedPlanScreen> createState() => _GeneratedPlanScreenState();
}

class _GeneratedPlanScreenState extends State<GeneratedPlanScreen> {
  final _profileRepo = ProfileRepository();
  final _planRepo = PlanRepository();

  ProductivityProfile? _profile;
  List<Map<String, dynamic>>? _tasks;
  bool _isLoading = true;
  bool _isRegenerating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFromSupabase();
  }

  /// Load existing plan from Supabase — NO AI calls.
  Future<void> _loadFromSupabase() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      _profile = await _profileRepo.loadProfile();
      final tasks = await _planRepo.loadTodayPlan();

      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error loading plan: $e';
      });
    }
  }

  /// Regenerate plan — ONLY called by explicit user tap.
  Future<void> _regeneratePlan() async {
    if (_profile == null) {
      _profile = await _profileRepo.loadProfile();
    }
    if (_profile == null) {
      setState(() => _error = 'No profile found.');
      return;
    }

    setState(() {
      _isRegenerating = true;
      _error = null;
    });

    try {
      final planService = PlanGenerationService()..initialize();
      final tasks = await planService.generateDayPlan(_profile!);
      await _planRepo.savePlan(tasks);

      setState(() {
        _tasks = tasks;
        _isRegenerating = false;
      });
    } catch (e) {
      setState(() {
        _isRegenerating = false;
        _error = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generated Plan'),
        actions: [
          if (_tasks != null && _tasks!.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Regenerate plan (uses AI)',
              onPressed: _isRegenerating ? null : _regeneratePlan,
            ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentRoute: AppRoutes.plan),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.orange),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadFromSupabase,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_tasks == null || _tasks!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today, size: 48, color: Color(0xFF0E7C78)),
              const SizedBox(height: 16),
              const Text(
                'No plan generated yet.\nTap below to generate your first plan.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isRegenerating ? null : _regeneratePlan,
                icon: _isRegenerating
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(_isRegenerating ? 'Generating...' : 'Generate plan'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isRegenerating) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Regenerating your plan...'),
          ],
        ),
      );
    }

    final p = _profile;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Annual target card
        if (p != null)
          AppCard(
            color: const Color(0xFF123533),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Annual target',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  p.annualGoals.take(3).join(', '),
                  style: const TextStyle(color: Colors.white70, height: 1.45),
                ),
              ],
            ),
          ),
        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: _PlanMetric(
                value: p?.wakeTime ?? '--',
                label: 'alarm set',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PlanMetric(
                value: '${_tasks!.length}',
                label: 'tasks today',
              ),
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
              for (final task in _tasks!) _TimelineRow(task: task),
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
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          Text(label, style: const TextStyle(color: Color(0xFF627270))),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.task});

  final Map<String, dynamic> task;

  @override
  Widget build(BuildContext context) {
    final category = (task['category'] ?? 'routine') as String;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              (task['time'] ?? '') as String,
              style: const TextStyle(
                color: Color(0xFF627270), fontSize: 12, fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Container(
            width: 4, height: 48,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: _categoryColor(category),
              borderRadius: BorderRadius.circular(2),
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          (task['title'] ?? '') as String,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      AppTag(category),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (task['description'] ?? '') as String,
                    style: const TextStyle(color: Color(0xFF627270), height: 1.35),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'focus': return const Color(0xFF0E7C78);
      case 'habit': return const Color(0xFF4CAF50);
      case 'break': return const Color(0xFFFFA726);
      default: return const Color(0xFF78909C);
    }
  }
}
