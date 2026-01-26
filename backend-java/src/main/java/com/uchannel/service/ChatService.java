package com.uchannel.service;

import com.uchannel.dto.ChatResponse;
import com.uchannel.dto.MessageDTO;
import com.uchannel.model.Message;
import com.uchannel.repository.MessageRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
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
    
    @Autowired
    private MessageRepository messageRepository;

    /**
     * 处理用户消息
     * 使用通义千问-flash大模型处理日程安排指令
     * @param userMessage 用户消息
     * @param conversationId 会话ID，如果为null则创建新会话
     * @return 聊天响应
     */
    @Transactional
    public ChatResponse processMessage(String userMessage, String conversationId) {
        try {
            logger.info("收到用户消息: {} (会话ID: {})", userMessage, conversationId);
            
            // 如果没有会话ID，创建新会话
            if (conversationId == null || conversationId.trim().isEmpty()) {
                conversationId = UUID.randomUUID().toString();
                logger.info("创建新会话: {}", conversationId);
            }

            // 保存用户消息
            Message userMsg = new Message(userMessage, "USER", conversationId);
            messageRepository.save(userMsg);
            logger.debug("已保存用户消息: {}", userMsg.getId());

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
            
            // 保存助手回复
            Message assistantMsg = new Message(response, "ASSISTANT", conversationId);
            messageRepository.save(assistantMsg);
            logger.debug("已保存助手回复: {}", assistantMsg.getId());
            
            ChatResponse chatResponse = new ChatResponse(true, response);
            chatResponse.getData().put("conversationId", conversationId);
            
            // 从用户消息和助手回复中提取日程信息
            Map<String, Object> scheduleInfo = extractScheduleInfo(userMessage, response);
            if (!scheduleInfo.isEmpty()) {
                chatResponse.getData().put("schedule", scheduleInfo);
                logger.info("提取到日程信息: {}", scheduleInfo);
            }
            
            return chatResponse;
            
        } catch (Exception e) {
            logger.error("处理消息时发生错误", e);
            return new ChatResponse(false, "处理您的消息时出现了错误，请稍后再试。");
        }
    }
    
    /**
     * 获取会话的历史消息
     * @param conversationId 会话ID
     * @return 消息DTO列表
     */
    public java.util.List<MessageDTO> getHistoryMessages(String conversationId) {
        if (conversationId == null || conversationId.trim().isEmpty()) {
            return java.util.Collections.emptyList();
        }
        java.util.List<Message> messages = messageRepository.findByConversationIdOrderByTimestampAsc(conversationId);
        return messages.stream()
            .map(msg -> new MessageDTO(
                msg.getId(),
                msg.getContent(),
                msg.getSender(),
                msg.getConversationId(),
                msg.getTimestamp()
            ))
            .collect(java.util.stream.Collectors.toList());
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
     * 提取时间信息（支持中英文）
     */
    private String extractTimeInfo(String text) {
        String lowerText = text.toLowerCase();
        
        // 匹配中文时间格式：8点、8:00、8点30等
        Pattern chineseTimePattern = Pattern.compile("(\\d{1,2})[点:]?(\\d{0,2})");
        java.util.regex.Matcher matcher = chineseTimePattern.matcher(text);
        if (matcher.find()) {
            String hour = matcher.group(1);
            String minute = matcher.group(2);
            if (minute == null || minute.isEmpty()) {
                return hour + ":00";
            }
            return hour + ":" + (minute.length() == 1 ? "0" + minute : minute);
        }
        
        // 匹配英文时间格式：8 am、8:00 am、8pm等
        Pattern englishTimePattern = Pattern.compile("(\\d{1,2})\\s*:?(\\d{0,2})\\s*(am|pm|上午|下午|晚上)", Pattern.CASE_INSENSITIVE);
        matcher = englishTimePattern.matcher(lowerText);
        if (matcher.find()) {
            String hour = matcher.group(1);
            String minute = matcher.group(2);
            String period = matcher.group(3);
            
            int hourInt = Integer.parseInt(hour);
            // 转换为24小时制
            if (period.contains("pm") || period.contains("下午") || period.contains("晚上")) {
                if (hourInt < 12) {
                    hourInt += 12;
                }
            } else if (period.contains("am") || period.contains("上午")) {
                if (hourInt == 12) {
                    hourInt = 0;
                }
            }
            
            String minuteStr = (minute == null || minute.isEmpty()) ? "00" : 
                               (minute.length() == 1 ? "0" + minute : minute);
            return String.format("%02d:%s", hourInt, minuteStr);
        }
        
        // 匹配简单数字时间：8 am（假设是8点）
        Pattern simpleTimePattern = Pattern.compile("\\b(\\d{1,2})\\s*(am|pm|点|时|小时)", Pattern.CASE_INSENSITIVE);
        matcher = simpleTimePattern.matcher(lowerText);
        if (matcher.find()) {
            String hour = matcher.group(1);
            String period = matcher.group(2);
            
            int hourInt = Integer.parseInt(hour);
            if (period != null) {
                if (period.contains("pm") || period.contains("下午") || period.contains("晚上")) {
                    if (hourInt < 12) {
                        hourInt += 12;
                    }
                } else if (period.contains("am") || period.contains("上午")) {
                    if (hourInt == 12) {
                        hourInt = 0;
                    }
                }
            }
            
            return String.format("%02d:00", hourInt);
        }
        
        return null;
    }

    /**
     * 提取日程信息（从用户消息和助手回复中提取）
     */
    private Map<String, Object> extractScheduleInfo(String userMessage, String assistantResponse) {
        Map<String, Object> info = new HashMap<>();
        String combinedText = (userMessage + " " + assistantResponse).toLowerCase();
        
        // 检查是否包含日程确认关键词（助手确认了日程）
        boolean isConfirmed = assistantResponse.contains("安排") || 
                             assistantResponse.contains("记录") ||
                             assistantResponse.contains("提醒") ||
                             assistantResponse.contains("设置") ||
                             assistantResponse.contains("确认");
        
        if (!isConfirmed) {
            return info; // 如果没有确认，不提取日程信息
        }
        
        // 提取时间（支持多种格式）
        String timeInfo = extractTimeInfo(userMessage + " " + assistantResponse);
        if (timeInfo != null) {
            info.put("time", timeInfo);
        }
        
        // 提取日期
        String dateInfo = extractDateInfo(userMessage + " " + assistantResponse);
        if (dateInfo != null) {
            info.put("date", dateInfo);
        }
        
        // 提取地点
        String location = extractLocation(userMessage + " " + assistantResponse);
        if (location != null) {
            info.put("location", location);
        }
        
        // 提取事件标题
        String title = extractTitle(userMessage, assistantResponse);
        if (title != null) {
            info.put("title", title);
        }
        
        // 如果提取到了关键信息，标记为有效日程
        if (info.containsKey("time") || info.containsKey("date") || info.containsKey("title")) {
            info.put("valid", true);
        }
        
        return info;
    }
    
    /**
     * 提取日期信息
     */
    private String extractDateInfo(String text) {
        // 明天
        if (text.contains("明天")) {
            return "明天";
        }
        // 后天
        if (text.contains("后天")) {
            return "后天";
        }
        // 今天
        if (text.contains("今天")) {
            return "今天";
        }
        // 下周
        if (text.contains("下周")) {
            return "下周";
        }
        // 具体日期格式：YYYY-MM-DD
        Pattern datePattern = Pattern.compile("(\\d{4})[-/](\\d{1,2})[-/](\\d{1,2})");
        java.util.regex.Matcher matcher = datePattern.matcher(text);
        if (matcher.find()) {
            return matcher.group(0);
        }
        return null;
    }
    
    /**
     * 提取地点信息（支持中英文）
     */
    private String extractLocation(String text) {
        String lowerText = text.toLowerCase();
        
        // 常见地点关键词
        String[] locationKeywords = {"教室", "classroom", "会议室", "办公室", "地点", "location", "room", "at"};
        for (String keyword : locationKeywords) {
            int index = lowerText.indexOf(keyword.toLowerCase());
            if (index != -1) {
                // 提取关键词后的内容
                String afterKeyword = text.substring(index + keyword.length()).trim();
                
                // 提取房间号（如807、room 807、classroom 807）
                Pattern roomPattern = Pattern.compile("(\\d{3,4}|[a-z]\\d{3,4})", Pattern.CASE_INSENSITIVE);
                java.util.regex.Matcher matcher = roomPattern.matcher(afterKeyword);
                if (matcher.find()) {
                    String roomNum = matcher.group(1);
                    // 如果关键词是"at"，只返回房间号
                    if (keyword.equalsIgnoreCase("at")) {
                        return roomNum;
                    }
                    return keyword + " " + roomNum;
                }
                
                // 如果没有找到房间号，提取前20个字符作为地点
                if (afterKeyword.length() > 0) {
                    String[] parts = afterKeyword.split("[，,。.\\s]+");
                    if (parts.length > 0) {
                        String location = parts[0];
                        if (location.length() > 0 && location.length() <= 20) {
                            return location;
                        }
                    }
                }
            }
        }
        
        // 直接匹配房间号模式（如"807"、"room 807"）
        Pattern directRoomPattern = Pattern.compile("(room|教室|classroom)?\\s*(\\d{3,4})", Pattern.CASE_INSENSITIVE);
        java.util.regex.Matcher matcher = directRoomPattern.matcher(text);
        if (matcher.find()) {
            String prefix = matcher.group(1);
            String roomNum = matcher.group(2);
            if (prefix != null && !prefix.trim().isEmpty()) {
                return prefix.trim() + " " + roomNum;
            }
            return roomNum;
        }
        
        return null;
    }
    
    /**
     * 提取事件标题（支持中英文）
     */
    private String extractTitle(String userMessage, String assistantResponse) {
        String lowerMessage = userMessage.toLowerCase();
        
        // 从用户消息中提取主要事件关键词
        String[] eventKeywords = {"开会", "会议", "meeting", "面试", "interview", "谈话", "talk", 
                                 "约会", "appointment", "课程", "class", "考试", "exam", "one on one"};
        for (String keyword : eventKeywords) {
            if (lowerMessage.contains(keyword.toLowerCase())) {
                // 提取包含关键词的短语
                int index = lowerMessage.indexOf(keyword.toLowerCase());
                int start = Math.max(0, index - 15);
                int end = Math.min(userMessage.length(), index + keyword.length() + 15);
                String title = userMessage.substring(start, end).trim();
                
                // 清理标题：移除多余空格和标点
                title = title.replaceAll("[，,。.\\s]+", " ").trim();
                
                // 如果标题太长，截取关键词附近的内容
                if (title.length() > 50) {
                    int keywordPos = title.toLowerCase().indexOf(keyword.toLowerCase());
                    if (keywordPos > 0) {
                        int newStart = Math.max(0, keywordPos - 15);
                        int newEnd = Math.min(title.length(), keywordPos + keyword.length() + 15);
                        title = title.substring(newStart, newEnd).trim();
                    } else {
                        title = title.substring(0, 50).trim();
                    }
                }
                
                if (title.length() >= 3 && title.length() <= 50) {
                    return title;
                }
            }
        }
        
        // 如果没有找到关键词，尝试从用户消息中提取主要部分作为标题
        // 移除时间、地点等，保留事件描述
        String title = userMessage.trim();
        // 移除常见的时间、地点模式
        title = title.replaceAll("\\d{1,2}\\s*(am|pm|点|:)", "").trim();
        title = title.replaceAll("(classroom|room|教室)\\s*\\d+", "").trim();
        title = title.replaceAll("[，,。.\\s]+", " ").trim();
        
        if (title.length() >= 3) {
            // 限制长度
            if (title.length() > 50) {
                title = title.substring(0, 50).trim();
            }
            return title;
        }
        
        // 最后备用：使用"日程安排"
        return "日程安排";
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
