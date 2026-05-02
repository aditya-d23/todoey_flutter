import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  final String text;
  final bool isUser;
  final DateTime timestamp;

  factory ChatMessage.user(String text) => ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      );

  factory ChatMessage.ai(String text) => ChatMessage(
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        text: json['text'] as String,
        isUser: json['isUser'] as bool,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  @override
  List<Object?> get props => [text, isUser, timestamp];
}
