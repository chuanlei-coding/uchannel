package com.uchannel.dto;

import java.time.LocalDateTime;

/**
 * 消息DTO（用于API响应）
 */
public class MessageDTO {
    
    private Long id;
    private String content;
    private String sender; // "USER" or "ASSISTANT"
    private String conversationId;
    private String timestamp; // ISO格式字符串
    
    public MessageDTO() {
    }
    
    public MessageDTO(Long id, String content, String sender, String conversationId, LocalDateTime timestamp) {
        this.id = id;
        this.content = content;
        this.sender = sender;
        this.conversationId = conversationId;
        // 转换为ISO格式字符串
        this.timestamp = timestamp.toString();
    }
    
    // Getters and Setters
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public String getContent() {
        return content;
    }
    
    public void setContent(String content) {
        this.content = content;
    }
    
    public String getSender() {
        return sender;
    }
    
    public void setSender(String sender) {
        this.sender = sender;
    }
    
    public String getConversationId() {
        return conversationId;
    }
    
    public void setConversationId(String conversationId) {
        this.conversationId = conversationId;
    }
    
    public String getTimestamp() {
        return timestamp;
    }
    
    public void setTimestamp(String timestamp) {
        this.timestamp = timestamp;
    }
}
