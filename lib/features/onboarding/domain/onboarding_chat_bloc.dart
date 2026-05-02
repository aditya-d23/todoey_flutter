import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/ai/gemini_chat_service.dart';
import '../../../core/models/chat_message.dart';
import '../../../core/models/productivity_profile.dart';
import '../data/profile_repository.dart';
import 'onboarding_chat_event.dart';
import 'onboarding_chat_state.dart';

/// BLoC that drives the onboarding AI goal conversation.
///
/// Manages the Gemini chat session, parses progress markers from AI responses,
/// and orchestrates profile extraction + persistence.
class OnboardingChatBloc
    extends Bloc<OnboardingChatEvent, OnboardingChatState> {
  OnboardingChatBloc({
    required GeminiChatService chatService,
    required ProfileRepository profileRepository,
  })  : _chatService = chatService,
        _profileRepo = profileRepository,
        super(const OnboardingChatState()) {
    on<StartConversation>(_onStartConversation);
    on<SendMessage>(_onSendMessage);
    on<CreateProfile>(_onCreateProfile);
    on<RetryLastAction>(_onRetry);
  }

  final GeminiChatService _chatService;
  final ProfileRepository _profileRepo;

  /// The active Gemini chat session for multi-turn conversation.
  ChatSession? _chat;

  /// Tracks the last failed event so [RetryLastAction] can re-dispatch it.
  OnboardingChatEvent? _lastFailedEvent;

  // ---------------------------------------------------------------------------
  // Event handlers
  // ---------------------------------------------------------------------------

  Future<void> _onStartConversation(
    StartConversation event,
    Emitter<OnboardingChatState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: () => null));

    try {
      _chat = _chatService.startConversation();
      final greeting = await _chatService.getInitialGreeting(_chat!);

      final parsed = _parseAiResponse(greeting);

      emit(state.copyWith(
        messages: [ChatMessage.ai(parsed.displayText)],
        isLoading: false,
        progress: parsed.progress,
        isProfileReady: parsed.isProfileReady,
      ));
    } catch (e) {
      _lastFailedEvent = event;
      emit(state.copyWith(
        isLoading: false,
        error: () => _friendlyError(e),
      ));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<OnboardingChatState> emit,
  ) async {
    if (_chat == null || event.text.trim().isEmpty) return;

    final userMessage = ChatMessage.user(event.text.trim());
    final updatedMessages = [...state.messages, userMessage];

    emit(state.copyWith(
      messages: updatedMessages,
      isLoading: true,
      error: () => null,
    ));

    try {
      final response = await _chatService.sendMessage(_chat!, event.text);
      final parsed = _parseAiResponse(response);

      emit(state.copyWith(
        messages: [...updatedMessages, ChatMessage.ai(parsed.displayText)],
        isLoading: false,
        progress: parsed.progress,
        isProfileReady: parsed.isProfileReady,
      ));
    } catch (e) {
      _lastFailedEvent = event;
      emit(state.copyWith(
        isLoading: false,
        error: () => _friendlyError(e),
      ));
    }
  }

  Future<void> _onCreateProfile(
    CreateProfile event,
    Emitter<OnboardingChatState> emit,
  ) async {
    if (_chat == null) return;

    emit(state.copyWith(isCreatingProfile: true, error: () => null));

    try {
      final json = await _chatService.extractProfile(_chat!);
      final profile = ProductivityProfile.fromJson(json);

      // Save profile and conversation to Supabase
      await _profileRepo.saveProfile(profile);
      await _profileRepo.saveConversationHistory(state.messages);

      emit(state.copyWith(
        isCreatingProfile: false,
        profile: () => profile,
      ));
    } catch (e) {
      _lastFailedEvent = event;
      emit(state.copyWith(
        isCreatingProfile: false,
        error: () => _friendlyError(e),
      ));
    }
  }

  Future<void> _onRetry(
    RetryLastAction event,
    Emitter<OnboardingChatState> emit,
  ) async {
    final lastEvent = _lastFailedEvent;
    if (lastEvent != null) {
      _lastFailedEvent = null;
      add(lastEvent);
    }
  }

  // ---------------------------------------------------------------------------
  // Parsing helpers
  // ---------------------------------------------------------------------------

  /// Parse the AI response to extract the display text, progress marker,
  /// and profile-ready signal.
  _ParsedResponse _parseAiResponse(String raw) {
    var text = raw;
    var progress = state.progress;
    var isProfileReady = state.isProfileReady;

    // Extract [PROGRESS:X/Y]
    final progressMatch = RegExp(r'\[PROGRESS:(\d+)/(\d+)\]').firstMatch(text);
    if (progressMatch != null) {
      final current = int.parse(progressMatch.group(1)!);
      final total = int.parse(progressMatch.group(2)!);
      progress = total > 0 ? current / total : 0.0;
      text = text.replaceAll(progressMatch.group(0)!, '').trim();
    }

    // Extract [PROFILE_READY]
    if (text.contains('[PROFILE_READY]')) {
      isProfileReady = true;
      text = text.replaceAll('[PROFILE_READY]', '').trim();
    }

    return _ParsedResponse(
      displayText: text,
      progress: progress,
      isProfileReady: isProfileReady,
    );
  }

  String _friendlyError(Object error) {
    if (error is GeminiChatException) {
      return error.message;
    }
    // Show actual error for debugging
    return 'Error: $error';
  }
}

class _ParsedResponse {
  const _ParsedResponse({
    required this.displayText,
    required this.progress,
    required this.isProfileReady,
  });

  final String displayText;
  final double progress;
  final bool isProfileReady;
}
