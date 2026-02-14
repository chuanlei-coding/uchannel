/**
 * 消息发送者类型
 */
export enum MessageSender {
  user = 'user',
  assistant = 'assistant',
  suggestion = 'suggestion',
}

/**
 * 消息类型
 */
export enum MessageType {
  text = 'text',
  image = 'image',
  voice = 'voice',
}

/**
 * 聊天消息模型
 */
export interface Message {
  id: string;
  content: string;
  contentSecondary?: string;
  sender: MessageSender;
  timestamp: Date;
  scheduleTitle?: string;
  scheduleTime?: string;
  // 图片相关
  type?: MessageType;
  imageUri?: string;  // 本地图片路径
  imageName?: string; // 图片文件名
  // 语音相关
  voiceUri?: string;       // 语音文件路径
  voiceDuration?: number;  // 语音时长（秒）
}

/**
 * 从JSON创建消息
 */
export function messageFromJson(json: Record<string, any>): Message {
  return {
    id: json.id?.toString() ?? Date.now().toString(),
    content: json.content ?? '',
    contentSecondary: json.contentSecondary,
    sender: Object.values(MessageSender).find((s) => s === json.sender) || MessageSender.assistant,
    timestamp: json.timestamp ? new Date(json.timestamp) : new Date(),
    scheduleTitle: json.scheduleTitle,
    scheduleTime: json.scheduleTime,
    type: json.type || MessageType.text,
    imageUri: json.imageUri,
    imageName: json.imageName,
    voiceUri: json.voiceUri,
    voiceDuration: json.voiceDuration,
  };
}

/**
 * 消息转换为JSON
 */
export function messageToJson(message: Message): Record<string, any> {
  return {
    id: message.id,
    content: message.content,
    contentSecondary: message.contentSecondary,
    sender: message.sender,
    timestamp: message.timestamp.toISOString(),
    scheduleTitle: message.scheduleTitle,
    scheduleTime: message.scheduleTime,
    type: message.type,
    imageUri: message.imageUri,
    imageName: message.imageName,
    voiceUri: message.voiceUri,
    voiceDuration: message.voiceDuration,
  };
}

/**
 * 创建用户消息
 */
export function createUserMessage(content: string): Message {
  return {
    id: Date.now().toString(),
    content,
    sender: MessageSender.user,
    timestamp: new Date(),
    type: MessageType.text,
  };
}

/**
 * 创建图片消息
 */
export function createImageMessage(uri: string, fileName?: string): Message {
  return {
    id: Date.now().toString(),
    content: '[图片]',
    sender: MessageSender.user,
    timestamp: new Date(),
    type: MessageType.image,
    imageUri: uri,
    imageName: fileName,
  };
}

/**
 * 创建语音消息
 */
export function createVoiceMessage(uri: string, duration: number): Message {
  return {
    id: Date.now().toString(),
    content: '[语音]',
    sender: MessageSender.user,
    timestamp: new Date(),
    type: MessageType.voice,
    voiceUri: uri,
    voiceDuration: duration,
  };
}

/**
 * 创建助手消息
 */
export function createAssistantMessage(content: string): Message {
  return {
    id: (Date.now() + 1).toString(),
    content,
    sender: MessageSender.assistant,
    timestamp: new Date(),
    type: MessageType.text,
  };
}
