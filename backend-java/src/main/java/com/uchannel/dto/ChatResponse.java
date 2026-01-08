package com.uchannel.dto;

import java.util.HashMap;
import java.util.Map;

/**
 * 聊天响应DTO
 */
public class ChatResponse {
    
    private boolean success;
    private String message;
    private Map<String, Object> data;

    public ChatResponse() {
        this.data = new HashMap<>();
    }

    public ChatResponse(boolean success, String message) {
        this.success = success;
        this.message = message;
        this.data = new HashMap<>();
    }

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public Map<String, Object> getData() {
        return data;
    }

    public void setData(Map<String, Object> data) {
        this.data = data;
    }
}
