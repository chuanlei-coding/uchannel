/// 消息发送者类型
enum MessageSender {
  user,
  assistant,
  suggestion,
}

/// 聊天消息模型
class Message {
  final String id;
  final String content;
  final String? contentSecondary;
  final MessageSender sender;
  final DateTime timestamp;
  final String? scheduleTitle;
  final String? scheduleTime;

  Message({
    required this.id,
    required this.content,
    this.contentSecondary,
    required this.sender,
    required this.timestamp,
    this.scheduleTitle,
    this.scheduleTime,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      content: json['content'] ?? '',
      contentSecondary: json['contentSecondary'],
      sender: MessageSender.values.firstWhere(
        (e) => e.name == json['sender'],
        orElse: () => MessageSender.assistant,
      ),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      scheduleTitle: json['scheduleTitle'],
      scheduleTime: json['scheduleTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'contentSecondary': contentSecondary,
      'sender': sender.name,
      'timestamp': timestamp.toIso8601String(),
      'scheduleTitle': scheduleTitle,
      'scheduleTime': scheduleTime,
    };
  }
}
