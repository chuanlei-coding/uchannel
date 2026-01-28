import 'package:flutter/material.dart';
import '../models/message.dart';
import '../theme/colors.dart';

/// 消息项组件 - 柔和版
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

  /// 用户消息 - 陶土色
  Widget _buildUserMessage() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.terracotta,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(0),
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
            child: Text(
              message.content,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatTime(message.timestamp),
            style: TextStyle(
              fontSize: 10,
              color: AppColors.softGrey.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  /// 助手消息 - 白色气泡
  Widget _buildAssistantMessage() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, right: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(16),
              ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.content.isNotEmpty)
                  Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                      color: AppColors.accentGreen,
                      height: 1.5,
                    ),
                  ),
                if (message.contentSecondary != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    message.contentSecondary!,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.darkGrey.withValues(alpha: 0.9),
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
            style: TextStyle(
              fontSize: 10,
              color: AppColors.softGrey.withValues(alpha: 0.5),
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
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(16),
          ),
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
          ],
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
                  color: AppColors.terracotta,
                ),
                const SizedBox(width: 8),
                Text(
                  '建议操作',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: AppColors.terracotta.withValues(alpha: 0.8),
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
                  color: AppColors.creamBg.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.brandSage.withValues(alpha: 0.2),
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
                            fontWeight: FontWeight.w500,
                            color: AppColors.darkGrey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message.scheduleTime ?? '',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.softGrey,
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
              style: TextStyle(
                fontSize: 14,
                color: AppColors.darkGrey.withValues(alpha: 0.8),
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
