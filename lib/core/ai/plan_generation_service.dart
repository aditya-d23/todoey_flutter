import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../models/productivity_profile.dart';

/// AI service for generating personalized day plans from a user's profile.
class PlanGenerationService {
  PlanGenerationService();

  GenerativeModel? _model;

  void initialize() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in .env file.');
    }

    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
    );
  }

  /// Generate a whole-day plan based on the user's productivity profile.
  ///
  /// Returns a list of task maps with: time, title, description, category.
  Future<List<Map<String, dynamic>>> generateDayPlan(
    ProductivityProfile profile,
  ) async {
    if (_model == null) initialize();

    final prompt = _buildPlanPrompt(profile);

    final response = await _model!.generateContent([Content.text(prompt)]);
    final text = response.text;

    if (text == null || text.trim().isEmpty) {
      throw Exception('AI returned empty plan.');
    }

    // Strip code fences
    var cleaned = text.trim();
    cleaned = cleaned.replaceFirst(RegExp(r'^```(?:json)?\s*\n?'), '');
    cleaned = cleaned.replaceFirst(RegExp(r'\n?```\s*$'), '');

    final decoded = jsonDecode(cleaned);
    if (decoded is List) {
      return decoded.cast<Map<String, dynamic>>();
    }
    // Sometimes AI wraps in { "tasks": [...] }
    if (decoded is Map && decoded.containsKey('tasks')) {
      return (decoded['tasks'] as List).cast<Map<String, dynamic>>();
    }
    throw Exception('Unexpected plan format from AI.');
  }

  /// Generate a coach response to a user's task update.
  Future<String> getCoachResponse({
    required ProductivityProfile profile,
    required String taskTitle,
    required String userUpdate,
    required String coachingTone,
  }) async {
    if (_model == null) initialize();

    final prompt = '''
You are a productivity coach. Your tone is: $coachingTone.

The user was working on: "$taskTitle"
Their update: "$userUpdate"

Their profile context:
- Wake time: ${profile.wakeTime}
- Focus windows: ${profile.focusWindows.map((f) => '${f.startTime}-${f.endTime}: ${f.label}').join(', ')}
- Procrastination triggers: ${profile.procrastinationTriggers.join(', ')}

Respond in 2-3 sentences. Acknowledge their update, give brief actionable advice, and update their score context. Be concise and supportive.
''';

    final response = await _model!.generateContent([Content.text(prompt)]);
    return response.text ?? 'Great job! Keep going.';
  }

  /// Generate a daily report summary.
  Future<Map<String, dynamic>> generateDailyReport({
    required ProductivityProfile profile,
    required List<Map<String, dynamic>> tasks,
  }) async {
    if (_model == null) initialize();

    final completedCount =
        tasks.where((t) => t['status'] == 'Done').length;
    final totalCount = tasks.length;
    final score = totalCount > 0
        ? (completedCount / totalCount * 100).round()
        : 0;

    final taskSummary = tasks
        .map((t) => '${t['time']} ${t['title']} - ${t['status'] ?? 'Pending'}')
        .join('\n');

    final prompt = '''
You are a productivity coach with a ${profile.coachingTone} tone.

Today's results ($completedCount/$totalCount completed, score: $score%):
$taskSummary

User profile:
- Annual goals: ${profile.annualGoals.join(', ')}
- Procrastination triggers: ${profile.procrastinationTriggers.join(', ')}
- Weak hours: ${profile.weakHours.join(', ')}

Generate a daily report as JSON with this schema:
{
  "score": $score,
  "summary": "1-2 sentence summary of the day",
  "coachNote": "2-3 sentence coaching advice for tomorrow",
  "pattern": "1 sentence pattern observation",
  "tomorrowAdjustments": ["adjustment 1", "adjustment 2"]
}

Return ONLY the raw JSON object.
''';

    final response = await _model!.generateContent([Content.text(prompt)]);
    final text = response.text ?? '{}';

    var cleaned = text.trim();
    cleaned = cleaned.replaceFirst(RegExp(r'^```(?:json)?\s*\n?'), '');
    cleaned = cleaned.replaceFirst(RegExp(r'\n?```\s*$'), '');

    return jsonDecode(cleaned) as Map<String, dynamic>;
  }

  String _buildPlanPrompt(ProductivityProfile profile) {
    final focusWindowsStr = profile.focusWindows
        .map((f) => '  - ${f.startTime} to ${f.endTime}: ${f.label}')
        .join('\n');

    return '''
You are a productivity planning AI. Create a complete whole-day schedule for the user based on their profile.

USER PROFILE:
- Wake time: ${profile.wakeTime}
- Sleep time: ${profile.sleepTime}
- Annual goals: ${profile.annualGoals.join(', ')}
- Monthly milestones: ${profile.monthlyMilestones.join(', ')}
- Daily habits: ${profile.dailyHabits.join(', ')}
- Focus windows:
$focusWindowsStr
- Weak hours: ${profile.weakHours.join(', ')}
- Procrastination triggers: ${profile.procrastinationTriggers.join(', ')}
- Coaching tone: ${profile.coachingTone}

RULES:
1. Create 7-10 time-blocked tasks from wake to sleep
2. Place hardest tasks in focus windows
3. Add buffer/break time during weak hours
4. Include habits from dailyHabits
5. Each task should advance a monthly milestone or annual goal
6. Add a wake-up routine and wind-down routine

Return a JSON ARRAY of tasks, each with:
{
  "time": "6:00 AM",
  "title": "Task title",
  "description": "Brief description of what to do",
  "category": "focus|habit|break|routine"
}

Return ONLY the raw JSON array — no markdown, no explanation.
''';
  }
}
