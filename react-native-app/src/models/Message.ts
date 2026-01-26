export enum MessageSender {
  USER = 'USER',
  ASSISTANT = 'ASSISTANT',
  SUGGESTION = 'SUGGESTION',
}

export interface Message {
  id: string;
  content: string;
  contentSecondary?: string;
  sender: MessageSender;
  timestamp: number;
  scheduleTitle?: string;
  scheduleTime?: string;
  scheduleLocation?: string;
}
