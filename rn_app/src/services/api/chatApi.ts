import apiClient from './client';
import { Message, messageFromJson, createAssistantMessage } from '../../models/Message';

/**
 * 聊天 API 服务
 */
class ChatApiService {
  private conversationId?: string;

  /**
   * 获取当前会话ID
   */
  get currentConversationId(): string | undefined {
    return this.conversationId;
  }

  /**
   * 发送消息
   */
  async sendMessage(content: string): Promise<Message | null> {
    try {
      const response = await apiClient.post('/chat/send', {
        message: content,
        conversationId: this.conversationId,
      });

      if (response.status === 200 && response.data.success) {
        const data = response.data.data;
        this.conversationId = data.conversationId;

        return createAssistantMessage(data.response ?? '');
      }
    } catch (error) {
      console.error('Failed to send message:', error);
    }
    return null;
  }

  /**
   * 获取历史消息
   */
  async getHistory(): Promise<Message[]> {
    if (!this.conversationId) return [];

    try {
      const response = await apiClient.get(`/chat/history/${this.conversationId}`);

      if (response.status === 200 && response.data.success) {
        const messages = response.data.messages as Array<Record<string, any>>;
        return messages.map(messageFromJson);
      }
    } catch (error) {
      console.error('Failed to get history:', error);
    }
    return [];
  }

  /**
   * 健康检查
   */
  async healthCheck(): Promise<boolean> {
    try {
      const response = await apiClient.get('/chat/health');
      return response.status === 200;
    } catch (error) {
      return false;
    }
  }

  /**
   * 清除会话
   */
  clearConversation(): void {
    this.conversationId = undefined;
  }
}

export default new ChatApiService();
