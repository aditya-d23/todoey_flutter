import 'package:equatable/equatable.dart';

import '../../../core/models/chat_message.dart';
import '../../../core/models/productivity_profile.dart';

/// State for the onboarding chat BLoC.
class OnboardingChatState extends Equatable {
  const OnboardingChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isProfileReady = false,
    this.isCreatingProfile = false,
    this.progress = 0.0,
    this.error,
    this.profile,
  });

  /// All chat messages in order.
  final List<ChatMessage> messages;

  /// True while waiting for an AI response.
  final bool isLoading;

  /// True when the AI signals [PROFILE_READY] — all topics covered.
  final bool isProfileReady;

  /// True while extracting and saving the profile.
  final bool isCreatingProfile;

  /// Conversation progress from 0.0 to 1.0 (based on [PROGRESS:X/8]).
  final double progress;

  /// Error message if something went wrong; null otherwise.
  final String? error;

  /// The extracted profile, set after [CreateProfile] succeeds.
  final ProductivityProfile? profile;

  OnboardingChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isProfileReady,
    bool? isCreatingProfile,
    double? progress,
    String? Function()? error,
    ProductivityProfile? Function()? profile,
  }) {
    return OnboardingChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isProfileReady: isProfileReady ?? this.isProfileReady,
      isCreatingProfile: isCreatingProfile ?? this.isCreatingProfile,
      progress: progress ?? this.progress,
      error: error != null ? error() : this.error,
      profile: profile != null ? profile() : this.profile,
    );
  }

  @override
  List<Object?> get props => [
        messages,
        isLoading,
        isProfileReady,
        isCreatingProfile,
        progress,
        error,
        profile,
      ];
}
