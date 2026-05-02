import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/chat_message.dart';
import '../../../core/models/productivity_profile.dart';

/// Repository for saving and loading user productivity profiles in Supabase.
class ProfileRepository {
  ProfileRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const _table = 'user_profiles';

  /// Save the extracted productivity profile for the current user.
  ///
  /// Uses upsert so re-running onboarding overwrites the old profile.
  Future<void> saveProfile(ProductivityProfile profile) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const ProfileRepositoryException('User is not authenticated.');
    }

    final json = profile.toJson();

    await _client.from(_table).upsert(
      {
        'user_id': userId,
        'annual_goals': json['annualGoals'],
        'monthly_milestones': json['monthlyMilestones'],
        'daily_habits': json['dailyHabits'],
        'focus_windows': json['focusWindows'],
        'weak_hours': json['weakHours'],
        'procrastination_triggers': json['procrastinationTriggers'],
        'wake_time': json['wakeTime'],
        'sleep_time': json['sleepTime'],
        'coaching_tone': json['coachingTone'],
        'recommended_alarms': json['recommendedAlarms'],
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'user_id',
    );
  }

  /// Load the current user's profile, or null if none exists.
  Future<ProductivityProfile?> loadProfile() async {
    final userId = _currentUserId;
    if (userId == null) return null;

    final result = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (result == null) return null;

    // Map snake_case Supabase columns to camelCase for the model
    return ProductivityProfile.fromJson({
      'annualGoals': result['annual_goals'],
      'monthlyMilestones': result['monthly_milestones'],
      'dailyHabits': result['daily_habits'],
      'focusWindows': result['focus_windows'],
      'weakHours': result['weak_hours'],
      'procrastinationTriggers': result['procrastination_triggers'],
      'wakeTime': result['wake_time'],
      'sleepTime': result['sleep_time'],
      'coachingTone': result['coaching_tone'],
      'recommendedAlarms': result['recommended_alarms'],
    });
  }

  /// Save the raw onboarding conversation for debugging / re-extraction.
  Future<void> saveConversationHistory(List<ChatMessage> messages) async {
    final userId = _currentUserId;
    if (userId == null) return;

    final jsonMessages = messages.map((m) => m.toJson()).toList();

    await _client.from(_table).update({
      'raw_conversation': jsonMessages,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('user_id', userId);
  }

  String? get _currentUserId => _client.auth.currentUser?.id;
}

/// Exception thrown by [ProfileRepository].
class ProfileRepositoryException implements Exception {
  const ProfileRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
