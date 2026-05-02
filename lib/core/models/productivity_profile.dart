import 'package:equatable/equatable.dart';

class ProductivityProfile extends Equatable {
  const ProductivityProfile({
    required this.annualGoals,
    required this.monthlyMilestones,
    required this.dailyHabits,
    required this.focusWindows,
    required this.weakHours,
    required this.procrastinationTriggers,
    required this.wakeTime,
    required this.sleepTime,
    required this.coachingTone,
    required this.recommendedAlarms,
  });

  final List<String> annualGoals;
  final List<String> monthlyMilestones;
  final List<String> dailyHabits;
  final List<FocusWindow> focusWindows;
  final List<String> weakHours;
  final List<String> procrastinationTriggers;
  final String wakeTime;
  final String sleepTime;
  final String coachingTone;
  final List<String> recommendedAlarms;

  Map<String, dynamic> toJson() => {
        'annualGoals': annualGoals,
        'monthlyMilestones': monthlyMilestones,
        'dailyHabits': dailyHabits,
        'focusWindows': focusWindows.map((w) => w.toJson()).toList(),
        'weakHours': weakHours,
        'procrastinationTriggers': procrastinationTriggers,
        'wakeTime': wakeTime,
        'sleepTime': sleepTime,
        'coachingTone': coachingTone,
        'recommendedAlarms': recommendedAlarms,
      };

  factory ProductivityProfile.fromJson(Map<String, dynamic> json) {
    return ProductivityProfile(
      annualGoals: _stringList(json['annualGoals']),
      monthlyMilestones: _stringList(json['monthlyMilestones']),
      dailyHabits: _stringList(json['dailyHabits']),
      focusWindows: (json['focusWindows'] as List<dynamic>? ?? [])
          .map((e) => FocusWindow.fromJson(e as Map<String, dynamic>))
          .toList(),
      weakHours: _stringList(json['weakHours']),
      procrastinationTriggers: _stringList(json['procrastinationTriggers']),
      wakeTime: json['wakeTime'] as String? ?? '',
      sleepTime: json['sleepTime'] as String? ?? '',
      coachingTone: json['coachingTone'] as String? ?? 'motivational',
      recommendedAlarms: _stringList(json['recommendedAlarms']),
    );
  }

  static List<String> _stringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  @override
  List<Object?> get props => [
        annualGoals,
        monthlyMilestones,
        dailyHabits,
        focusWindows,
        weakHours,
        procrastinationTriggers,
        wakeTime,
        sleepTime,
        coachingTone,
        recommendedAlarms,
      ];
}

class FocusWindow extends Equatable {
  const FocusWindow({
    required this.startTime,
    required this.endTime,
    required this.label,
  });

  final String startTime;
  final String endTime;
  final String label;

  Map<String, dynamic> toJson() => {
        'startTime': startTime,
        'endTime': endTime,
        'label': label,
      };

  factory FocusWindow.fromJson(Map<String, dynamic> json) => FocusWindow(
        startTime: json['startTime'] as String? ?? '',
        endTime: json['endTime'] as String? ?? '',
        label: json['label'] as String? ?? '',
      );

  @override
  List<Object?> get props => [startTime, endTime, label];
}
