import 'package:equatable/equatable.dart';

/// Events for the onboarding chat BLoC.
abstract class OnboardingChatEvent extends Equatable {
  const OnboardingChatEvent();

  @override
  List<Object?> get props => [];
}

/// Start the conversation — AI sends the first greeting.
class StartConversation extends OnboardingChatEvent {
  const StartConversation();
}

/// User sends a message.
class SendMessage extends OnboardingChatEvent {
  const SendMessage(this.text);

  final String text;

  @override
  List<Object?> get props => [text];
}

/// User taps "Create profile" after the conversation is complete.
class CreateProfile extends OnboardingChatEvent {
  const CreateProfile();
}

/// Retry the last failed operation.
class RetryLastAction extends OnboardingChatEvent {
  const RetryLastAction();
}
