package com.uchannel.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 通义千问-flash大模型服务
 * 使用阿里云百炼平台API
 */
@Service
public class QwenFlashService {

    private static final Logger logger = LoggerFactory.getLogger(QwenFlashService.class);
    
    private static final String API_URL = "https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation";
    
    @Value("${qwen.api-key:sk-bbdf41fb73044d66b46976a1df35abbe}")
    private String apiKey;
    
    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;
    
    public QwenFlashService() {
        this.restTemplate = new RestTemplate();
        this.objectMapper = new ObjectMapper();
    }

    /**
     * 调用通义千问-flash处理用户消息
     * @param userMessage 用户消息
     * @return 模型回复
     */
    public String chat(String userMessage) {
        try {
            logger.info("调用通义千问-flash处理消息: {}", userMessage);
            
            // 构建请求
            Map<String, Object> requestBody = buildRequest(userMessage);
            
            // 设置请求头
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.set("Authorization", "Bearer " + apiKey);
            headers.set("X-DashScope-SSE", "disable");
            
            HttpEntity<Map<String, Object>> request = new HttpEntity<>(requestBody, headers);
            
            // 发送请求
            ResponseEntity<String> response = restTemplate.exchange(
                API_URL,
                HttpMethod.POST,
                request,
                String.class
            );
            
            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                return parseResponse(response.getBody());
            } else {
                logger.error("通义千问API调用失败: {}", response.getStatusCode());
                return null;
            }
            
        } catch (Exception e) {
            logger.error("调用通义千问-flash时发生错误", e);
            return null;
        }
    }

    /**
     * 构建请求体
     */
    private Map<String, Object> buildRequest(String userMessage) {
        Map<String, Object> request = new HashMap<>();
        
        // 模型名称 - 使用qwen-turbo（通义千问-flash）
        request.put("model", "qwen-turbo");
        
        // 构建消息列表
        List<Map<String, String>> messages = new ArrayList<>();
        
        // 系统提示词
        Map<String, String> systemMessage = new HashMap<>();
        systemMessage.put("role", "system");
        systemMessage.put("content", "你是一个专业的日程安排助手。你的任务是帮助用户管理日程安排。" +
            "当用户提供日程信息时，你需要：\n" +
            "1. 理解用户的日程安排意图\n" +
            "2. 提取关键信息（时间、地点、事件等）\n" +
            "3. 给出友好的确认，并告知用户日程已添加（不要说'我会帮你添加'，而是说'已为您添加'）\n" +
            "4. 如果信息不完整，礼貌地询问缺失的信息\n" +
            "5. 提醒用户可以在'日程'Tab中查看和管理日程\n" +
            "请用简洁、友好的语言回复用户。");
        messages.add(systemMessage);
        
        // 用户消息
        Map<String, String> userMsg = new HashMap<>();
        userMsg.put("role", "user");
        userMsg.put("content", userMessage);
        messages.add(userMsg);
        
        // 构建input对象
        Map<String, Object> input = new HashMap<>();
        input.put("messages", messages);
        request.put("input", input);
        
        // 生成参数
        Map<String, Object> parameters = new HashMap<>();
        parameters.put("temperature", 0.7);
        parameters.put("max_tokens", 1000);
        parameters.put("top_p", 0.8);
        request.put("parameters", parameters);
        
        return request;
    }

    /**
     * 解析API响应
     */
    private String parseResponse(String responseBody) {
        try {
            JsonNode root = objectMapper.readTree(responseBody);
            
            // 检查是否有错误
            if (root.has("code") && !root.get("code").asText().equals("Success")) {
                String errorMsg = root.has("message") ? root.get("message").asText() : "未知错误";
                logger.error("通义千问API返回错误: {}", errorMsg);
                return null;
            }
            
            // 提取输出内容
            JsonNode output = root.path("output");
            if (output.has("choices") && output.get("choices").isArray()) {
                JsonNode choices = output.get("choices");
                if (choices.size() > 0) {
                    JsonNode firstChoice = choices.get(0);
                    JsonNode message = firstChoice.path("message");
                    if (message.has("content")) {
                        return message.get("content").asText();
                    }
                }
            }
            
            // 兼容其他可能的响应格式
            if (output.has("text")) {
                return output.get("text").asText();
            }
            
            logger.warn("无法解析通义千问响应: {}", responseBody);
            return null;
            
        } catch (Exception e) {
            logger.error("解析通义千问响应失败", e);
            return null;
        }
    }
}
