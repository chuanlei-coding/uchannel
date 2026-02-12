import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';
import 'api_service.dart';

/// 聊天服务
/// 负责管理聊天记录的本地存储和服务器同步
class ChatService extends ChangeNotifier {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final ApiService _apiService = ApiService();

  // 本地存储键名
  static const String _keyMessages = 'chat_messages';
  static const String _keyConversationId = 'conversation_id';

  // 本地消息列表
  final List<Message> _messages = [];

  // 会话ID
  String? _conversationId;

  // 是否正在加载
  bool _isLoading = false;

  // 是否已初始化
  bool _isInitialized = false;

  // Getters
  List<Message> get messages => List.unmodifiable(_messages);
  String? get conversationId => _conversationId;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  int get messageCount => _messages.length;

  /// 初始化聊天服务
  Future<void> init() async {
    _isLoading = true;
    _isInitialized = true;
    notifyListeners();

    // 加载本地消息
    await _loadLocalMessages();

    // 尝试从服务器获取历史消息
    await _syncFromServer();

    _isLoading = false;
    notifyListeners();
  }

  /// 从本地存储加载消息
  Future<void> _loadLocalMessages() async {
    final prefs = await SharedPreferences.getInstance();
    _conversationId = prefs.getString(_keyConversationId);

    final messagesJson = prefs.getString(_keyMessages);
    if (messagesJson != null) {
      try {
        final List<dynamic> decoded = json.decode(messagesJson);
        _messages.clear();
        for (var item in decoded) {
          _messages.add(Message.fromJson(item));
        }
      } catch (e) {
        // 解析失败，清空消息
        _messages.clear();
      }
    }
  }

  /// 保存消息到本地存储
  Future<void> _saveLocalMessages() async {
    final prefs = await SharedPreferences.getInstance();

    // 保存会话ID
    if (_conversationId != null) {
      await prefs.setString(_keyConversationId, _conversationId!);
    }

    // 保存消息列表
    final messagesJson = json.encode(
      _messages.map((m) => m.toJson()).toList(),
    );
    await prefs.setString(_keyMessages, messagesJson);
  }

  /// 从服务器同步消息
  Future<void> _syncFromServer() async {
    try {
      final historyMessages = await _apiService.getHistory();
      if (historyMessages.isNotEmpty) {
        _messages.clear();
        _messages.addAll(historyMessages);
        await _saveLocalMessages();
      }
    } catch (e) {
      // 服务器同步失败，使用本地缓存
    }
  }

  /// 发送消息
  ///
  /// 同时保存到本地和发送到服务器
  Future<Message?> sendMessage(String content) async {
    if (content.trim().isEmpty) return null;

    // 创建用户消息
    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    // 添加到本地列表
    _messages.add(userMessage);
    await _saveLocalMessages();
    notifyListeners();

    // 发送到服务器
    try {
      final response = await _apiService.sendMessage(content);
      if (response != null) {
        // 更新会话ID
        _conversationId = _apiService.conversationId;

        // 添加助手回复
        _messages.add(response);
        await _saveLocalMessages();
        notifyListeners();
        return response;
      }
    } catch (e) {
      // 发送失败，添加错误提示消息
      final errorMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: '抱歉，发送失败。请检查网络连接后重试。',
        sender: MessageSender.assistant,
        timestamp: DateTime.now(),
      );
      _messages.add(errorMessage);
      await _saveLocalMessages();
      notifyListeners();
      return null;
    }

    return null;
  }

  /// 添加本地消息（不发送到服务器）
  Future<void> addLocalMessage(Message message) async {
    _messages.add(message);
    await _saveLocalMessages();
    notifyListeners();
  }

  /// 清空聊天记录
  Future<void> clearMessages() async {
    _messages.clear();
    _conversationId = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyMessages);
    await prefs.remove(_keyConversationId);

    notifyListeners();
  }

  /// 删除指定消息
  Future<void> deleteMessage(String messageId) async {
    _messages.removeWhere((m) => m.id == messageId);
    await _saveLocalMessages();
    notifyListeners();
  }

  /// 获取最后一条消息
  Message? get lastMessage {
    if (_messages.isEmpty) return null;
    return _messages.last;
  }

  /// 获取用户发送的消息数量
  int get userMessageCount {
    return _messages.where((m) => m.sender == MessageSender.user).length;
  }

  /// 搜索消息
  List<Message> searchMessages(String keyword) {
    if (keyword.trim().isEmpty) return messages;

    final lowerKeyword = keyword.toLowerCase();
    return _messages.where((m) =>
      m.content.toLowerCase().contains(lowerKeyword) ||
      (m.contentSecondary?.toLowerCase().contains(lowerKeyword) ?? false)
    ).toList();
  }

  /// 获取指定日期范围内的消息
  List<Message> getMessagesInRange(DateTime start, DateTime end) {
    return _messages.where((m) =>
      m.timestamp.isAfter(start) && m.timestamp.isBefore(end)
    ).toList();
  }

  /// 重新发送消息
  Future<Message?> resendMessage(String messageId) async {
    final message = _messages.firstWhere(
      (m) => m.id == messageId,
      orElse: () => Message(
        id: '',
        content: '',
        sender: MessageSender.user,
        timestamp: DateTime.now(),
      ),
    );

    if (message.sender != MessageSender.user || message.content.isEmpty) {
      return null;
    }

    // 删除原消息
    await deleteMessage(messageId);

    // 重新发送
    return sendMessage(message.content);
  }

  /// 刷新历史消息（从服务器）
  Future<void> refreshHistory() async {
    _isLoading = true;
    notifyListeners();

    await _syncFromServer();

    _isLoading = false;
    notifyListeners();
  }
}
