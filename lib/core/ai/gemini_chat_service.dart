import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'onboarding_system_prompt.dart';

/// Prompt sent to the same chat session after the conversation is complete
/// to extract structured profile data as JSON.
const String _profileExtractionPrompt = '''
Based on our entire conversation, extract the user's productivity profile as a JSON object with this exact schema. Use only information the user explicitly shared — never invent data.

{
  "annualGoals": ["goal 1", "goal 2"],
  "monthlyMilestones": ["milestone 1", "milestone 2"],
  "dailyHabits": ["habit 1", "habit 2"],
  "focusWindows": [
    {"startTime": "9:00 AM", "endTime": "12:00 PM", "label": "Deep work"}
  ],
  "weakHours": ["2:00 PM - 4:00 PM"],
  "procrastinationTriggers": ["trigger 1", "trigger 2"],
  "wakeTime": "6:00 AM",
  "sleepTime": "10:30 PM",
  "coachingTone": "motivational",
  "recommendedAlarms": ["6:00 AM wake", "9:00 AM focus block"]
}

Return ONLY the raw JSON object — no markdown code fences, no explanation, no extra text.
''';

/// Service that wraps Google Generative AI (Gemini) for the onboarding chat.
///
/// This service is stateless — the [ChatSession] is managed by the caller
/// (the BLoC) so the service can be reused or replaced easily.
class GeminiChatService {
  GeminiChatService();

  GenerativeModel? _model;

  /// Initialize the Gemini model using the API key from .env.
  void initialize() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw const GeminiChatException(
        'GEMINI_API_KEY not found in .env file.',
      );
    }

    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.system(onboardingSystemPrompt),
    );
  }

  /// Start a new multi-turn chat session.
  ChatSession startConversation() {
    _ensureInitialized();
    return _model!.startChat();
  }

  /// Send a user message and return the AI response text.
  ///
  /// Throws [GeminiChatException] if the response is empty or an error occurs.
  Future<String> sendMessage(ChatSession chat, String userMessage) async {
    try {
      final response = await chat.sendMessage(Content.text(userMessage));

      final text = response.text;
      if (text == null || text.trim().isEmpty) {
        throw const GeminiChatException(
          'The AI returned an empty response. Please try again.',
        );
      }

      return text;
    } on GenerativeAIException catch (e) {
      throw GeminiChatException('AI error: ${e.message}');
    }
  }

  /// Request the AI to generate the opening message (no user input needed).
  ///
  /// We send a minimal trigger so the model responds with its greeting.
  Future<String> getInitialGreeting(ChatSession chat) async {
    return sendMessage(chat, 'Hello, I want to set up my productivity plan.');
  }

  /// Send the extraction prompt to the existing chat session and parse
  /// the response as a JSON map.
  ///
  /// This should be called only after the conversation is complete
  /// (i.e. the AI has sent [PROFILE_READY]).
  Future<Map<String, dynamic>> extractProfile(ChatSession chat) async {
    final raw = await sendMessage(chat, _profileExtractionPrompt);

    // Strip markdown code fences if the model wraps the JSON
    final cleaned = _stripCodeFences(raw).trim();

    try {
      final decoded = jsonDecode(cleaned);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      throw const GeminiChatException(
        'AI returned unexpected format. Expected a JSON object.',
      );
    } on FormatException {
      throw GeminiChatException(
        'Could not parse AI response as JSON.\n\nRaw response:\n$cleaned',
      );
    }
  }

  void _ensureInitialized() {
    if (_model == null) {
      throw const GeminiChatException(
        'GeminiChatService not initialized. Call initialize() first.',
      );
    }
  }

  /// Remove ```json ... ``` or ``` ... ``` wrappers that Gemini sometimes adds.
  static String _stripCodeFences(String text) {
    var result = text.trim();

    // Remove opening fence: ```json or ```
    final openPattern = RegExp(r'^```(?:json)?\s*\n?');
    result = result.replaceFirst(openPattern, '');

    // Remove closing fence: ```
    final closePattern = RegExp(r'\n?```\s*$');
    result = result.replaceFirst(closePattern, '');

    return result;
  }
}

/// Exception thrown by [GeminiChatService] when an AI operation fails.
class GeminiChatException implements Exception {
  const GeminiChatException(this.message);

  final String message;

  @override
  String toString() => message;
}
