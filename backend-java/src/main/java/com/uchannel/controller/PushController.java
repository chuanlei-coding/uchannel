package com.uchannel.controller;

import com.uchannel.dto.*;
import com.uchannel.service.PushNotificationService;
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
 * 推送消息API控制器
 */
@RestController
@RequestMapping("/api/push")
public class PushController {

    private static final Logger logger = LoggerFactory.getLogger(PushController.class);

    @Autowired
    private PushNotificationService pushNotificationService;

    /**
     * POST /api/push/send
     * 发送推送消息给指定用户
     */
    @PostMapping("/send")
    public ResponseEntity<Map<String, Object>> sendPush(
            @RequestParam String userId,
            @Valid @RequestBody PushRequest request) {
        
        try {
            // TODO: 从数据库获取用户的FCM Token
            // String token = userService.getFcmToken(userId);
            String token = request.getData() != null ? 
                    request.getData().get("token") : null; // 临时使用，实际应从数据库获取
            
            if (token == null || token.isEmpty()) {
                return ResponseEntity.badRequest().body(createErrorResponse("用户未注册FCM Token"));
            }

            PushResult result = pushNotificationService.sendToDevice(
                    token,
                    request.getTitle(),
                    request.getBody(),
                    request.getData(),
                    request.getPriority()
            );

            if (result.isSuccess()) {
                Map<String, Object> response = new HashMap<>();
                response.put("success", true);
                response.put("messageId", result.getMessageId());
                return ResponseEntity.ok(response);
            } else {
                return ResponseEntity.status(500).body(createErrorResponse(result.getError()));
            }

        } catch (Exception e) {
            logger.error("推送API错误", e);
            return ResponseEntity.status(500).body(createErrorResponse("服务器内部错误"));
        }
    }

    /**
     * POST /api/push/broadcast
     * 广播推送消息给多个用户
     */
    @PostMapping("/broadcast")
    public ResponseEntity<Map<String, Object>> broadcastPush(
            @Valid @RequestBody BroadcastRequest request) {
        
        try {
            // TODO: 从数据库批量获取用户的FCM Token
            // List<String> tokens = userService.getFcmTokens(request.getUserIds());
            List<String> tokens = request.getUserIds(); // 临时使用，实际应从数据库获取

            if (tokens == null || tokens.isEmpty()) {
                return ResponseEntity.badRequest().body(createErrorResponse("没有有效的FCM Token"));
            }

            PushResult result = pushNotificationService.sendToMultipleDevices(
                    tokens,
                    request.getTitle(),
                    request.getBody(),
                    request.getData()
            );

            Map<String, Object> response = new HashMap<>();
            response.put("success", result.isSuccess());
            response.put("successCount", result.getSuccessCount());
            response.put("failureCount", result.getFailureCount());
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            logger.error("广播推送API错误", e);
            return ResponseEntity.status(500).body(createErrorResponse("服务器内部错误"));
        }
    }

    /**
     * POST /api/push/topic
     * 主题推送
     */
    @PostMapping("/topic")
    public ResponseEntity<Map<String, Object>> topicPush(
            @Valid @RequestBody TopicPushRequest request) {
        
        try {
            PushResult result = pushNotificationService.sendToTopic(
                    request.getTopic(),
                    request.getTitle(),
                    request.getBody(),
                    request.getData()
            );

            if (result.isSuccess()) {
                Map<String, Object> response = new HashMap<>();
                response.put("success", true);
                response.put("messageId", result.getMessageId());
                return ResponseEntity.ok(response);
            } else {
                return ResponseEntity.status(500).body(createErrorResponse(result.getError()));
            }

        } catch (Exception e) {
            logger.error("主题推送API错误", e);
            return ResponseEntity.status(500).body(createErrorResponse("服务器内部错误"));
        }
    }

    /**
     * POST /api/push/register-token
     * 注册/更新用户的FCM Token
     */
    @PostMapping("/register-token")
    public ResponseEntity<Map<String, Object>> registerToken(
            @Valid @RequestBody TokenRegisterRequest request) {
        
        try {
            // TODO: 从认证信息中获取用户ID
            // String userId = getCurrentUserId();
            // userService.updateFcmToken(userId, request.getToken());

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Token注册成功");
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            logger.error("Token注册错误", e);
            return ResponseEntity.status(500).body(createErrorResponse("服务器内部错误"));
        }
    }

    /**
     * POST /api/push/subscribe
     * 订阅主题
     */
    @PostMapping("/subscribe")
    public ResponseEntity<Map<String, Object>> subscribeToTopic(
            @RequestParam String topic,
            @RequestBody List<String> tokens) {
        
        try {
            PushResult result = pushNotificationService.subscribeToTopic(tokens, topic);

            Map<String, Object> response = new HashMap<>();
            response.put("success", result.isSuccess());
            response.put("successCount", result.getSuccessCount());
            response.put("failureCount", result.getFailureCount());
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            logger.error("订阅主题错误", e);
            return ResponseEntity.status(500).body(createErrorResponse("服务器内部错误"));
        }
    }

    /**
     * POST /api/push/unsubscribe
     * 取消订阅主题
     */
    @PostMapping("/unsubscribe")
    public ResponseEntity<Map<String, Object>> unsubscribeFromTopic(
            @RequestParam String topic,
            @RequestBody List<String> tokens) {
        
        try {
            PushResult result = pushNotificationService.unsubscribeFromTopic(tokens, topic);

            Map<String, Object> response = new HashMap<>();
            response.put("success", result.isSuccess());
            response.put("successCount", result.getSuccessCount());
            response.put("failureCount", result.getFailureCount());
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            logger.error("取消订阅错误", e);
            return ResponseEntity.status(500).body(createErrorResponse("服务器内部错误"));
        }
    }

    /**
     * 创建错误响应
     */
    private Map<String, Object> createErrorResponse(String error) {
        Map<String, Object> response = new HashMap<>();
        response.put("success", false);
        response.put("error", error);
        return response;
    }
}

