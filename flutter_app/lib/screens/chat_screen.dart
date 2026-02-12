import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/message.dart';
import '../services/chat_service.dart';
import '../theme/colors.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/message_item.dart';
import '../widgets/page_background.dart';

/// 聊天页面
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // 获取聊天服务
  ChatService get _chatService => context.read<ChatService>();

  // 是否正在发送消息
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    // 初始化聊天服务（如果还没初始化）
    if (!_chatService.isInitialized) {
      await _chatService.init();
    }

    // 如果没有消息，添加欢迎消息
    if (_chatService.messageCount == 0) {
      await _addWelcomeMessage();
    }

    _scrollToBottom();
  }

  Future<void> _addWelcomeMessage() async {
    await _chatService.addLocalMessage(Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: '"岁序更替，步履轻盈。"',
      contentSecondary: '早安。今天你的行程看起来很宁静。需要我为你回顾一下下午的冥想预约吗？',
      sender: MessageSender.assistant,
      timestamp: DateTime.now(),
    ));
  }

  void _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    _inputController.clear();
    _scrollToBottom();

    // 发送消息（同时保存到本地和服务器）
    await _chatService.sendMessage(text);

    setState(() {
      _isSending = false;
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBg,
      body: Stack(
        children: [
          // 背景装饰
          _buildBackgroundDecorations(),

          // 主内容
          SafeArea(
            child: Column(
              children: [
                // 头部
                _buildHeader(),

                // 日期标签
                _buildDateLabel(),

                // 消息列表
                Expanded(
                  child: Consumer<ChatService>(
                    builder: (context, chatService, child) {
                      final messages = chatService.messages;

                      if (chatService.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(color: AppColors.brandSage),
                        );
                      }

                      if (messages.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color: AppColors.softGrey.withValues(alpha: 0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '开始与 Vita 对话',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.softGrey.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        key: const ValueKey('message_list'),
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          return MessageItem(
                            key: ValueKey(messages[index].id),
                            message: messages[index],
                          );
                        },
                      );
                    },
                  ),
                ),

                // 输入框
                _buildInputBar(),

                // 底部导航
                _buildBottomNav(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundDecorations() {
    return PageBackground.defaultDecorations();
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildLogo(),
              const SizedBox(width: 12),
              const Text(
                'Vita Assistant',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.5,
                  color: AppColors.darkGrey,
                ),
              ),
            ],
          ),
          // 清空聊天记录按钮
          GestureDetector(
            onTap: () => _showClearDialog(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: AppColors.borderLightAlt,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.delete_outline,
                color: AppColors.softGrey,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('清空聊天记录'),
        content: const Text('确定要清空所有聊天记录吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _chatService.clearMessages();
              await _addWelcomeMessage();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('聊天记录已清空'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('清空'),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return SizedBox(
      width: 32,
      height: 32,
      child: Stack(
        children: [
          Positioned.fill(
            child: Transform.rotate(
              angle: -0.26,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.brandSage.withValues(alpha: 0.6),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Transform.scale(
              scale: 1.1,
              child: Transform.rotate(
                angle: 0.785,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border(
                      top: BorderSide(
                        color: AppColors.brandTeal.withValues(alpha: 0.6),
                        width: 2,
                      ),
                      right: BorderSide(
                        color: AppColors.brandTeal.withValues(alpha: 0.6),
                        width: 2,
                      ),
                      bottom: BorderSide.none,
                      left: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateLabel() {
    final now = DateTime.now();
    const weekdays = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        '${now.month}月${now.day}日 · ${weekdays[now.weekday - 1]}',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 3,
          color: AppColors.softGrey.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.borderLightAlt.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.terracotta.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.add_circle,
              color: AppColors.softGrey.withValues(alpha: 0.6),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _inputController,
              enabled: !_isSending,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.darkGrey,
              ),
              decoration: InputDecoration(
                hintText: _isSending ? '发送中...' : '与 Vita 交流...',
                hintStyle: TextStyle(
                  color: AppColors.softGrey.withValues(alpha: 0.4),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          GestureDetector(
            onTap: _isSending ? null : _sendMessage,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isSending
                    ? AppColors.softGrey.withValues(alpha: 0.5)
                    : AppColors.brandSage,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _isSending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(
                      Icons.arrow_upward,
                      size: 18,
                      color: Colors.white,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNav.defaultNav(currentRoute: '/chat');
  }
}
