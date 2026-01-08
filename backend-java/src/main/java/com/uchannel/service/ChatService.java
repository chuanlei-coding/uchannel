package com.uchannel.service;

import com.uchannel.dto.ChatResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.Pattern;

/**
 * 聊天服务
 * 使用通义千问-flash大模型处理日程安排指令
 */
@Service
public class ChatService {

    private static final Logger logger = LoggerFactory.getLogger(ChatService.class);
    
    @Autowired(required = false)
    private QwenFlashService qwenFlashService;

    /**
     * 处理用户消息
     * 使用通义千问-flash大模型处理日程安排指令
     */
    public ChatResponse processMessage(String userMessage) {
        try {
            logger.info("收到用户消息: {}", userMessage);

            String response;
            
            // 优先使用通义千问-flash大模型
            if (qwenFlashService != null) {
                response = qwenFlashService.chat(userMessage);
                
                // 如果大模型调用失败，使用备用逻辑
                if (response == null || response.trim().isEmpty()) {
                    logger.warn("通义千问调用失败，使用备用逻辑");
                    response = analyzeScheduleMessage(userMessage);
                }
            } else {
                // 如果服务未配置，使用简单逻辑
                logger.warn("通义千问服务未配置，使用简单逻辑");
                response = analyzeScheduleMessage(userMessage);
            }
            
            ChatResponse chatResponse = new ChatResponse(true, response);
            
            // 可以添加额外的数据，如解析出的日程信息
            Map<String, Object> scheduleInfo = extractScheduleInfo(userMessage);
            if (!scheduleInfo.isEmpty()) {
                chatResponse.getData().put("schedule", scheduleInfo);
            }
            
            return chatResponse;
            
        } catch (Exception e) {
            logger.error("处理消息时发生错误", e);
            return new ChatResponse(false, "处理您的消息时出现了错误，请稍后再试。");
        }
    }

    /**
     * 分析日程消息（简单实现，后续可用大模型替换）
     */
    private String analyzeScheduleMessage(String message) {
        String lowerMessage = message.toLowerCase();
        
        // 检测是否包含日程相关关键词
        if (containsScheduleKeywords(lowerMessage)) {
            // 尝试提取时间信息
            String timeInfo = extractTimeInfo(message);
            if (timeInfo != null) {
                return String.format("已记录您的日程安排：%s。时间：%s。我会在适当的时候提醒您。", 
                    message, timeInfo);
            }
            return String.format("已记录您的日程安排：%s。我会在适当的时候提醒您。", message);
        }
        
        // 问候语处理
        if (containsGreeting(lowerMessage)) {
            return "你好！我是日程安排助手。请告诉我你的日程安排，例如：明天下午3点开会、下周一上午10点面试等。";
        }
        
        // 默认回复
        return String.format("已收到您的消息：%s。我会帮您处理日程安排相关的事务。", message);
    }

    /**
     * 检测是否包含日程关键词
     */
    private boolean containsScheduleKeywords(String message) {
        String[] keywords = {"会议", "开会", "面试", "约会", "提醒", "日程", "安排", 
                            "明天", "后天", "下周", "下周一", "下周二", "下周三", 
                            "下周四", "下周五", "上午", "下午", "晚上", "点", "时"};
        for (String keyword : keywords) {
            if (message.contains(keyword)) {
                return true;
            }
        }
        return false;
    }

    /**
     * 检测是否包含问候语
     */
    private boolean containsGreeting(String message) {
        String[] greetings = {"你好", "您好", "hello", "hi", "在吗", "在", "help", "帮助"};
        for (String greeting : greetings) {
            if (message.contains(greeting)) {
                return true;
            }
        }
        return false;
    }

    /**
     * 提取时间信息（简单实现）
     */
    private String extractTimeInfo(String message) {
        // 简单的正则匹配时间
        Pattern timePattern = Pattern.compile("(\\d{1,2})[点:]?(\\d{0,2})");
        java.util.regex.Matcher matcher = timePattern.matcher(message);
        if (matcher.find()) {
            return matcher.group(0);
        }
        return null;
    }

    /**
     * 提取日程信息（用于后续处理）
     */
    private Map<String, Object> extractScheduleInfo(String message) {
        Map<String, Object> info = new HashMap<>();
        
        // 提取时间
        String timeInfo = extractTimeInfo(message);
        if (timeInfo != null) {
            info.put("time", timeInfo);
        }
        
        // 提取日期关键词
        if (message.contains("明天")) {
            info.put("date", "明天");
        } else if (message.contains("后天")) {
            info.put("date", "后天");
        } else if (message.contains("下周")) {
            info.put("date", "下周");
        }
        
        return info;
    }

    /**
     * 调用大模型处理消息（预留接口）
     * TODO: 实现大模型API调用
     */
    private String callLLM(String message) {
        // 示例：调用大模型API
        // 这里可以集成OpenAI、Claude、文心一言、通义千问等
        
        // 示例代码结构：
        // 1. 构建请求
        // 2. 调用API
        // 3. 解析响应
        // 4. 返回结果
        
        return null; // 暂时返回null，使用简单逻辑
    }
}
