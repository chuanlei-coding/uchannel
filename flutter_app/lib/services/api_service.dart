import 'package:dio/dio.dart';
import '../models/message.dart';

/// API 服务
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:8080/api',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  String? _conversationId;

  /// 发送消息
  Future<Message?> sendMessage(String content) async {
    try {
      final response = await _dio.post('/chat/send', data: {
        'message': content,
        'conversationId': _conversationId,
      });

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        _conversationId = data['conversationId'];

        return Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: data['response'] ?? '',
          sender: MessageSender.assistant,
          timestamp: DateTime.now(),
        );
      }
    } catch (e) {
      print('API Error: $e');
    }
    return null;
  }

  /// 获取历史消息
  Future<List<Message>> getHistory() async {
    if (_conversationId == null) return [];

    try {
      final response = await _dio.get('/chat/history/$_conversationId');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final messages = response.data['messages'] as List;
        return messages.map((m) => Message.fromJson(m)).toList();
      }
    } catch (e) {
      print('API Error: $e');
    }
    return [];
  }

  /// 健康检查
  Future<bool> healthCheck() async {
    try {
      final response = await _dio.get('/chat/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
