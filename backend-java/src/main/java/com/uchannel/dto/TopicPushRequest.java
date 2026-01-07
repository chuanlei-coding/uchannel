package com.uchannel.dto;

import jakarta.validation.constraints.NotBlank;
import java.util.Map;

/**
 * 主题推送请求DTO
 */
public class TopicPushRequest {
    
    @NotBlank(message = "主题不能为空")
    private String topic;
    
    @NotBlank(message = "标题不能为空")
    private String title;
    
    @NotBlank(message = "内容不能为空")
    private String body;
    
    private Map<String, String> data;

    // Getters and Setters
    public String getTopic() {
        return topic;
    }

    public void setTopic(String topic) {
        this.topic = topic;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getBody() {
        return body;
    }

    public void setBody(String body) {
        this.body = body;
    }

    public Map<String, String> getData() {
        return data;
    }

    public void setData(Map<String, String> data) {
        this.data = data;
    }
}

