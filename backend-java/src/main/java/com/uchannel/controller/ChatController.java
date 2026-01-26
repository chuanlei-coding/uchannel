package com.uchannel.controller;

import com.uchannel.dto.ChatRequest;
import com.uchannel.dto.ChatResponse;
import com.uchannel.dto.MessageDTO;
import com.uchannel.service.ChatService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 聊天API控制器
 * 处理日程安排指令
 */
@RestController
@RequestMapping("/api/chat")
@CrossOrigin(origins = "*", maxAge = 3600)
public class ChatController {

    private static final Logger logger = LoggerFactory.getLogger(ChatController.class);

    @Autowired
    private ChatService chatService;

    /**
     * POST /api/chat/send
     * 发送聊天消息
     */
    @PostMapping("/send")
    public ResponseEntity<ChatResponse> sendMessage(
            @Valid @RequestBody ChatRequest request) {
        
        try {
            logger.info("收到聊天请求: {} (会话ID: {})", request.getMessage(), request.getConversationId());
            
            ChatResponse response = chatService.processMessage(
                request.getMessage(), 
                request.getConversationId()
            );
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            logger.error("处理聊天请求时发生错误", e);
            ChatResponse errorResponse = new ChatResponse(false, "服务器内部错误");
            return ResponseEntity.status(500).body(errorResponse);
        }
    }
    
    /**
     * GET /api/chat/history/{conversationId}
     * 获取会话历史消息
     */
    @GetMapping("/history/{conversationId}")
    public ResponseEntity<Map<String, Object>> getHistory(
            @PathVariable String conversationId) {
        
        try {
            logger.info("获取会话历史: {}", conversationId);
            
            List<MessageDTO> messages = chatService.getHistoryMessages(conversationId);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("conversationId", conversationId);
            response.put("messages", messages);
            response.put("count", messages.size());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            logger.error("获取历史消息时发生错误", e);
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("error", "获取历史消息失败");
            return ResponseEntity.status(500).body(errorResponse);
        }
    }

    /**
     * GET /api/chat/health
     * 健康检查
     */
    @GetMapping("/health")
    public ResponseEntity<ChatResponse> health() {
        ChatResponse response = new ChatResponse(true, "聊天服务运行正常");
        return ResponseEntity.ok(response);
    }
}
