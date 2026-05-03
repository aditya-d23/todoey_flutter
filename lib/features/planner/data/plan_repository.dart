import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository for saving and loading generated day plans in Supabase.
class PlanRepository {
  PlanRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const _table = 'day_plans';

  String? get _currentUserId => _client.auth.currentUser?.id;

  /// Save a generated day plan for today.
  Future<void> savePlan(List<Map<String, dynamic>> tasks) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    final today = DateTime.now().toIso8601String().substring(0, 10);

    // Add default status to each task
    final tasksWithStatus = tasks.map((t) {
      return {
        ...t,
        'status': t['status'] ?? 'Pending',
      };
    }).toList();

    await _client.from(_table).upsert(
      {
        'user_id': userId,
        'plan_date': today,
        'tasks': tasksWithStatus,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'user_id,plan_date',
    );
  }

  /// Load today's plan, or null if none exists.
  Future<List<Map<String, dynamic>>?> loadTodayPlan() async {
    final userId = _currentUserId;
    if (userId == null) return null;

    final today = DateTime.now().toIso8601String().substring(0, 10);

    final result = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .eq('plan_date', today)
        .maybeSingle();

    if (result == null) return null;

    final tasks = result['tasks'];
    if (tasks is List) {
      return tasks.cast<Map<String, dynamic>>();
    }
    return null;
  }

  /// Update the status of a specific task (by index).
  Future<void> updateTaskStatus(int taskIndex, String newStatus) async {
    final tasks = await loadTodayPlan();
    if (tasks == null || taskIndex >= tasks.length) return;

    tasks[taskIndex]['status'] = newStatus;
    await savePlan(tasks);
  }
}
