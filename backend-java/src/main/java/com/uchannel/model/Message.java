package com.uchannel.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

/**
 * 消息实体类
 */
@Entity
@Table(name = "messages")
public class Message {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, length = 500)
    private String content;
    
    @Column(nullable = false, length = 50)
    private String sender; // "USER" or "ASSISTANT"
    
    @Column(nullable = false, length = 100)
    private String conversationId;
    
    @Column(nullable = false)
    private LocalDateTime timestamp;
    
    public Message() {
        this.timestamp = LocalDateTime.now();
    }
    
    public Message(String content, String sender, String conversationId) {
        this.content = content;
        this.sender = sender;
        this.conversationId = conversationId;
        this.timestamp = LocalDateTime.now();
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
    
    public LocalDateTime getTimestamp() {
        return timestamp;
    }
    
    public void setTimestamp(LocalDateTime timestamp) {
        this.timestamp = timestamp;
    }
}
