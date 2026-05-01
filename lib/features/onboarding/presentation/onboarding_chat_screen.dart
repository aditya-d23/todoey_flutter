import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/widgets/app_card.dart';

class OnboardingChatScreen extends StatefulWidget {
  const OnboardingChatScreen({super.key});

  @override
  State<OnboardingChatScreen> createState() => _OnboardingChatScreenState();
}

class _OnboardingChatScreenState extends State<OnboardingChatScreen> {
  final _messages = <_ChatMessage>[
    const _ChatMessage(
      text:
          'Hi. I will collect your yearly, monthly, and daily goals, then create your automated day plan.',
      isUser: false,
    ),
    const _ChatMessage(
      text: 'First, what do you want to achieve this year?',
      isUser: false,
    ),
  ];

  final _answers = [
    'This year I want to build my app, improve health, study consistently, and stop wasting evenings.',
    'This month I want to complete the demo, build Flutter screens, exercise 20 days, and study daily.',
    'Wake me at 6:15 AM, help me exercise, work on the app, study, and review my day.',
    'After lunch I scroll too much, and at night I delay important work.',
    'Use Done, Not done, Snooze, Reschedule, and ask why I am stuck.',
    'Add smaller tasks, recovery breaks, extra reminders, and move hard work to the morning.',
  ];

  final _questions = [
    'What is your monthly goal that supports this yearly goal?',
    'What should your ideal daily goal look like?',
    'Where do you usually lag or procrastinate?',
    'When a popup appears, what responses should it let you give?',
    'What should I add automatically if you are falling behind?',
    'Perfect. I can now create your profile and first full-day plan.',
  ];

  int _step = 0;

  @override
  Widget build(BuildContext context) {
    final complete = _step >= _answers.length;

    return Scaffold(
      appBar: AppBar(title: const Text('AI Goal Conversation')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: AppCard(
                color: const Color(0xFFEAF6F3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Automation profile progress',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: (_step + 1) / (_answers.length + 1),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) =>
                    _ChatBubble(message: _messages[index]),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemCount: _messages.length,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!complete)
                    AppCard(
                      child: Text(
                        _answers[_step],
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: complete ? _openProfile : _sendAnswer,
                    child: Text(complete ? 'Create profile' : 'Send answer'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendAnswer() {
    setState(() {
      _messages.add(_ChatMessage(text: _answers[_step], isUser: true));
      _messages.add(_ChatMessage(text: _questions[_step], isUser: false));
      _step++;
    });
  }

  void _openProfile() {
    Navigator.of(context).pushNamed(AppRoutes.profile);
  }
}

class _ChatMessage {
  const _ChatMessage({required this.text, required this.isUser});

  final String text;
  final bool isUser;
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 310),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: message.isUser
              ? Theme.of(context).colorScheme.primary
              : Colors.white,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: message.isUser ? const Radius.circular(4) : null,
            bottomLeft: message.isUser ? null : const Radius.circular(4),
          ),
          border: Border.all(color: const Color(0xFFDCE6E3)),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : const Color(0xFF172121),
            height: 1.35,
          ),
        ),
      ),
    );
  }
}
