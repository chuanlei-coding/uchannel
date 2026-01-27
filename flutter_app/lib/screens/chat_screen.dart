import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/message.dart';
import '../theme/colors.dart';
import '../widgets/message_item.dart';

/// 聊天页面
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [];

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: '"岁序更替，步履轻盈。"',
        contentSecondary: '早安。今天你的行程看起来很宁静。需要我为你回顾一下下午的冥想预约吗？',
        sender: MessageSender.assistant,
        timestamp: DateTime.now(),
      ));
    });
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: text,
        sender: MessageSender.user,
        timestamp: DateTime.now(),
      ));
    });

    _inputController.clear();
    _scrollToBottom();

    // 模拟助手回复
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.add(Message(
            id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
            content: '我已经为您重新调整了后续行程。现在，您的节奏更加从容了。',
            sender: MessageSender.suggestion,
            timestamp: DateTime.now(),
            scheduleTitle: '下午冥想',
            scheduleTime: '15:00 - 15:30',
          ));
        });
        _scrollToBottom();
      }
    });
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
      backgroundColor: AppColors.charcoal,
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
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return MessageItem(message: _messages[index]);
                    },
                  ),
                ),

                // 输入框
                _buildInputBar(),

                // 底部导航
                _buildBottomNav(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundDecorations() {
    return Stack(
      children: [
        Positioned(
          top: -MediaQuery.of(context).size.height * 0.1,
          left: -MediaQuery.of(context).size.width * 0.1,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.brandSage.withValues(alpha: 0.05),
            ),
          ),
        ),
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.1,
          right: -MediaQuery.of(context).size.width * 0.1,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.4,
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.brandTeal.withValues(alpha: 0.05),
            ),
          ),
        ),
      ],
    );
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
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.glassGrey,
              border: Border.all(
                color: AppColors.white05,
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.more_horiz,
              color: AppColors.brandSage,
            ),
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
                  color: AppColors.brandSage.withValues(alpha: 0.8),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        '今天, ${now.month}月${now.day}日',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 3,
          color: AppColors.white30,
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.glassGrey,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.white10,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.add_circle_outline,
              color: AppColors.white40,
            ),
          ),
          Expanded(
            child: TextField(
              controller: _inputController,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                hintText: '与 Vita 交流...',
                hintStyle: TextStyle(
                  color: AppColors.white20,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brandSage,
              ),
              child: const Icon(
                Icons.arrow_upward,
                size: 18,
                color: AppColors.charcoal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 84,
      decoration: BoxDecoration(
        color: AppColors.charcoal.withValues(alpha: 0.85),
        border: Border(
          top: BorderSide(
            color: AppColors.white05,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_outlined, '概览', false, () {}),
          _buildNavItem(Icons.calendar_month_outlined, '日程', false, () {
            context.go('/schedule');
          }),
          _buildNavItem(Icons.chat_bubble, '助手', true, () {}),
          _buildNavItem(Icons.settings_outlined, '设置', false, () {
            context.go('/settings');
          }),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: isActive ? AppColors.brandSage : AppColors.white40,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
              color: isActive ? AppColors.brandSage : AppColors.white40,
            ),
          ),
        ],
      ),
    );
  }
}
