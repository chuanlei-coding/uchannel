import 'package:flutter/material.dart';
import '../models/message.dart';
import '../theme/colors.dart';

/// 消息项组件
class MessageItem extends StatelessWidget {
  final Message message;

  const MessageItem({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    switch (message.sender) {
      case MessageSender.user:
        return _buildUserMessage();
      case MessageSender.assistant:
        return _buildAssistantMessage();
      case MessageSender.suggestion:
        return _buildSuggestionMessage();
    }
  }

  /// 用户消息
  Widget _buildUserMessage() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.glassGrey,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(0),
              ),
              border: Border.all(
                color: AppColors.white10,
                width: 1,
              ),
            ),
            child: Text(
              message.content,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.white90,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatTime(message.timestamp),
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.white20,
            ),
          ),
        ],
      ),
    );
  }

  /// 助手消息
  Widget _buildAssistantMessage() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, right: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.glassSage,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(
                color: AppColors.brandSage.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.content.isNotEmpty)
                  Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      color: AppColors.brandSage.withValues(alpha: 0.9),
                      height: 1.5,
                    ),
                  ),
                if (message.contentSecondary != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    message.contentSecondary!,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.white80,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatTime(message.timestamp),
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.white20,
            ),
          ),
        ],
      ),
    );
  }

  /// 建议操作消息
  Widget _buildSuggestionMessage() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, right: 30),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.glassSage,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(
            color: AppColors.brandSage.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题行
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 16,
                  color: AppColors.brandSage,
                ),
                const SizedBox(width: 8),
                Text(
                  '建议操作',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    color: AppColors.brandSage.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 日程卡片
            if (message.scheduleTitle != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.charcoal.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.white05,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.scheduleTitle!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.white90,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message.scheduleTime ?? '',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.white40,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.schedule,
                      size: 20,
                      color: AppColors.brandSage,
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 12),

            // 内容
            Text(
              message.content,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.white70,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:$minute $period';
  }
}
