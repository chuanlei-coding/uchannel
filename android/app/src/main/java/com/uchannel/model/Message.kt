package com.uchannel.model

import java.util.Date

/**
 * 消息数据类
 */
data class Message(
    val id: String,
    val content: String,
    val sender: MessageSender,
    val timestamp: Date = Date()
)

enum class MessageSender {
    USER,      // 用户消息
    ASSISTANT  // 助手消息
}
