package com.uchannel.dto;

import jakarta.validation.constraints.NotBlank;

/**
 * Token注册请求DTO
 */
public class TokenRegisterRequest {
    
    @NotBlank(message = "FCM Token不能为空")
    private String token;

    // Getters and Setters
    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }
}

