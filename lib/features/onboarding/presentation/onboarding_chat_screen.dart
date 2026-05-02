import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/app_routes.dart';
import '../../../core/ai/gemini_chat_service.dart';
import '../data/profile_repository.dart';
import '../domain/onboarding_chat_bloc.dart';
import '../domain/onboarding_chat_event.dart';
import '../domain/onboarding_chat_state.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/topic_progress_bar.dart';

class OnboardingChatScreen extends StatelessWidget {
  const OnboardingChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingChatBloc(
        chatService: GeminiChatService()..initialize(),
        profileRepository: ProfileRepository(),
      )..add(const StartConversation()),
      child: const _OnboardingChatView(),
    );
  }
}

class _OnboardingChatView extends StatefulWidget {
  const _OnboardingChatView();

  @override
  State<_OnboardingChatView> createState() => _OnboardingChatViewState();
}

class _OnboardingChatViewState extends State<_OnboardingChatView> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingChatBloc, OnboardingChatState>(
      listenWhen: (previous, current) =>
          current.profile != null && previous.profile == null,
      listener: (context, state) {
        // Navigate to profile summary when profile is created
        if (state.profile != null) {
          Navigator.of(context).pushNamed(AppRoutes.profile);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('AI Goal Conversation')),
          body: SafeArea(
            child: Column(
              children: [
                TopicProgressBar(progress: state.progress),
                Expanded(child: _buildChatList(state)),
                _buildBottomArea(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatList(OnboardingChatState state) {
    // Auto-scroll when messages change
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    final itemCount =
        state.messages.length + (state.isLoading ? 1 : 0);

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index < state.messages.length) {
          return ChatBubble(message: state.messages[index]);
        }
        // Show typing indicator as the last item while loading
        return const TypingIndicator();
      },
    );
  }

  Widget _buildBottomArea(BuildContext context, OnboardingChatState state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Error banner
          if (state.error != null) ...[
            _ErrorBanner(
              message: state.error!,
              onRetry: () => context
                  .read<OnboardingChatBloc>()
                  .add(const RetryLastAction()),
            ),
            const SizedBox(height: 12),
          ],

          // Create profile button (when AI signals PROFILE_READY)
          if (state.isProfileReady && state.profile == null) ...[
            ElevatedButton(
              onPressed: state.isCreatingProfile
                  ? null
                  : () => context
                      .read<OnboardingChatBloc>()
                      .add(const CreateProfile()),
              child: state.isCreatingProfile
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create profile'),
            ),
          ]
          // Chat input (during conversation)
          else if (!state.isProfileReady) ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    enabled: !state.isLoading,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(context),
                    decoration: const InputDecoration(
                      hintText: 'Type your answer...',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed:
                      state.isLoading ? null : () => _sendMessage(context),
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _sendMessage(BuildContext context) {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    context.read<OnboardingChatBloc>().add(SendMessage(text));
    _textController.clear();
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF2D3A2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(message, style: const TextStyle(height: 1.35)),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
