package com.uchannel.dto;

import jakarta.validation.constraints.NotBlank;

/**
 * 聊天请求DTO
 */
public class ChatRequest {
    
    @NotBlank(message = "消息内容不能为空")
    private String message;
    
    private String conversationId; // 会话ID，可选

    public ChatRequest() {
    }

    public ChatRequest(String message) {
        this.message = message;
    }
    
    public ChatRequest(String message, String conversationId) {
        this.message = message;
        this.conversationId = conversationId;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
    
    public String getConversationId() {
        return conversationId;
    }
    
    public void setConversationId(String conversationId) {
        this.conversationId = conversationId;
    }
}
