package com.uchannel.service;

import com.google.firebase.messaging.*;
import com.uchannel.dto.PushResult;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

/**
 * 推送通知服务
 * 提供各种推送消息的方法
 */
@Service
public class PushNotificationService {

    private static final Logger logger = LoggerFactory.getLogger(PushNotificationService.class);
    private static final int MAX_BATCH_SIZE = 1000; // FCM批量推送最大数量

    @Autowired
    private FirebaseMessaging firebaseMessaging;

    /**
     * 发送单个推送消息
     *
     * @param token FCM Token
     * @param title 通知标题
     * @param body 通知内容
     * @param data 自定义数据
     * @param priority 优先级 (high/normal)
     * @return 推送结果
     */
    public PushResult sendToDevice(String token, String title, String body, 
                                    Map<String, String> data, String priority) {
        try {
            Message.Builder messageBuilder = Message.builder()
                    .setToken(token)
                    .setNotification(Notification.builder()
                            .setTitle(title)
                            .setBody(body)
                            .build());

            // 添加自定义数据
            if (data != null && !data.isEmpty()) {
                messageBuilder.putAllData(data);
            }
            messageBuilder.putData("timestamp", String.valueOf(System.currentTimeMillis()));

            // Android配置
            AndroidConfig.Builder androidConfigBuilder = AndroidConfig.builder()
                    .setPriority("high".equalsIgnoreCase(priority) ? 
                            AndroidConfig.Priority.HIGH : AndroidConfig.Priority.NORMAL);

            AndroidNotification.Builder androidNotificationBuilder = AndroidNotification.builder()
                    .setSound("default")
                    .setChannelId("default_channel");

            androidConfigBuilder.setNotification(androidNotificationBuilder.build());
            messageBuilder.setAndroidConfig(androidConfigBuilder.build());

            Message message = messageBuilder.build();
            String messageId = firebaseMessaging.send(message);

            logger.info("✅ 推送成功，MessageId: {}", messageId);
            return PushResult.success(messageId);

        } catch (FirebaseMessagingException e) {
            logger.error("❌ 推送失败: {}", e.getMessage(), e);
            
            // 处理无效Token
            if (isInvalidTokenError(e)) {
                handleInvalidToken(token);
            }
            
            return PushResult.failure(e.getMessage());
        } catch (Exception e) {
            logger.error("❌ 推送异常: {}", e.getMessage(), e);
            return PushResult.failure("推送异常: " + e.getMessage());
        }
    }

    /**
     * 批量发送推送消息
     *
     * @param tokens FCM Token列表
     * @param title 通知标题
     * @param body 通知内容
     * @param data 自定义数据
     * @return 推送结果
     */
    public PushResult sendToMultipleDevices(List<String> tokens, String title, 
                                            String body, Map<String, String> data) {
        if (tokens == null || tokens.isEmpty()) {
            return PushResult.failure("Token列表为空");
        }

        // 如果超过最大批量数量，分批发送
        if (tokens.size() > MAX_BATCH_SIZE) {
            return sendInBatches(tokens, title, body, data);
        }

        try {
            MulticastMessage.Builder messageBuilder = MulticastMessage.builder()
                    .addAllTokens(tokens)
                    .setNotification(Notification.builder()
                            .setTitle(title)
                            .setBody(body)
                            .build());

            // 添加自定义数据
            if (data != null && !data.isEmpty()) {
                messageBuilder.putAllData(data);
            }
            messageBuilder.putData("timestamp", String.valueOf(System.currentTimeMillis()));

            // Android配置
            AndroidConfig androidConfig = AndroidConfig.builder()
                    .setPriority(AndroidConfig.Priority.HIGH)
                    .setNotification(AndroidNotification.builder()
                            .setSound("default")
                            .setChannelId("default_channel")
                            .build())
                    .build();

            messageBuilder.setAndroidConfig(androidConfig);

            MulticastMessage message = messageBuilder.build();
            BatchResponse response = firebaseMessaging.sendEachForMulticast(message);

            // 处理失败的Token
            if (response.getFailureCount() > 0) {
                List<String> failedTokens = new ArrayList<>();
                List<SendResponse> responses = response.getResponses();
                
                for (int i = 0; i < responses.size(); i++) {
                    SendResponse sendResponse = responses.get(i);
                    if (!sendResponse.isSuccessful()) {
                        failedTokens.add(tokens.get(i));
                        logger.error("Token {} 发送失败: {}", tokens.get(i), 
                                sendResponse.getException().getMessage());
                    }
                }
                handleFailedTokens(failedTokens);
            }

            logger.info("✅ 批量推送完成: 成功 {}, 失败 {}", 
                    response.getSuccessCount(), response.getFailureCount());

            return PushResult.batchResult(
                    response.getSuccessCount(), 
                    response.getFailureCount()
            );

        } catch (Exception e) {
            logger.error("❌ 批量推送失败: {}", e.getMessage(), e);
            return PushResult.failure("批量推送失败: " + e.getMessage());
        }
    }

    /**
     * 分批发送（处理超过1000个设备的情况）
     */
    private PushResult sendInBatches(List<String> tokens, String title, 
                                     String body, Map<String, String> data) {
        int totalSuccess = 0;
        int totalFailure = 0;

        for (int i = 0; i < tokens.size(); i += MAX_BATCH_SIZE) {
            int end = Math.min(i + MAX_BATCH_SIZE, tokens.size());
            List<String> batch = tokens.subList(i, end);

            PushResult result = sendToMultipleDevices(batch, title, body, data);
            if (result.isSuccess()) {
                totalSuccess += result.getSuccessCount();
                totalFailure += result.getFailureCount();
            }

            // 避免请求过快，添加小延迟
            try {
                TimeUnit.MILLISECONDS.sleep(100);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                logger.warn("分批发送被中断");
            }
        }

        return PushResult.batchResult(totalSuccess, totalFailure);
    }

    /**
     * 主题推送
     *
     * @param topic 主题名称
     * @param title 通知标题
     * @param body 通知内容
     * @param data 自定义数据
     * @return 推送结果
     */
    public PushResult sendToTopic(String topic, String title, String body, 
                                   Map<String, String> data) {
        try {
            Message.Builder messageBuilder = Message.builder()
                    .setTopic(topic)
                    .setNotification(Notification.builder()
                            .setTitle(title)
                            .setBody(body)
                            .build());

            // 添加自定义数据
            if (data != null && !data.isEmpty()) {
                messageBuilder.putAllData(data);
            }
            messageBuilder.putData("timestamp", String.valueOf(System.currentTimeMillis()));

            // Android配置
            AndroidConfig androidConfig = AndroidConfig.builder()
                    .setPriority(AndroidConfig.Priority.HIGH)
                    .setNotification(AndroidNotification.builder()
                            .setSound("default")
                            .setChannelId("default_channel")
                            .build())
                    .build();

            messageBuilder.setAndroidConfig(androidConfig);

            Message message = messageBuilder.build();
            String messageId = firebaseMessaging.send(message);

            logger.info("✅ 主题推送成功，MessageId: {}", messageId);
            return PushResult.success(messageId);

        } catch (Exception e) {
            logger.error("❌ 主题推送失败: {}", e.getMessage(), e);
            return PushResult.failure("主题推送失败: " + e.getMessage());
        }
    }

    /**
     * 订阅主题
     *
     * @param tokens FCM Token列表
     * @param topic 主题名称
     * @return 推送结果
     */
    public PushResult subscribeToTopic(List<String> tokens, String topic) {
        try {
            TopicManagementResponse response = firebaseMessaging.subscribeToTopic(tokens, topic);
            
            logger.info("✅ 订阅主题 {} 成功: 成功 {}, 失败 {}", 
                    topic, response.getSuccessCount(), response.getFailureCount());
            
            return PushResult.batchResult(
                    response.getSuccessCount(), 
                    response.getFailureCount()
            );
        } catch (Exception e) {
            logger.error("❌ 订阅主题失败: {}", e.getMessage(), e);
            return PushResult.failure("订阅主题失败: " + e.getMessage());
        }
    }

    /**
     * 取消订阅主题
     *
     * @param tokens FCM Token列表
     * @param topic 主题名称
     * @return 推送结果
     */
    public PushResult unsubscribeFromTopic(List<String> tokens, String topic) {
        try {
            TopicManagementResponse response = firebaseMessaging.unsubscribeFromTopic(tokens, topic);
            
            logger.info("✅ 取消订阅主题 {} 成功: 成功 {}, 失败 {}", 
                    topic, response.getSuccessCount(), response.getFailureCount());
            
            return PushResult.batchResult(
                    response.getSuccessCount(), 
                    response.getFailureCount()
            );
        } catch (Exception e) {
            logger.error("❌ 取消订阅失败: {}", e.getMessage(), e);
            return PushResult.failure("取消订阅失败: " + e.getMessage());
        }
    }

    /**
     * 发送数据消息（不显示通知，由应用处理）
     *
     * @param token FCM Token
     * @param data 数据
     * @return 推送结果
     */
    public PushResult sendDataMessage(String token, Map<String, String> data) {
        try {
            Message.Builder messageBuilder = Message.builder()
                    .setToken(token);

            if (data != null && !data.isEmpty()) {
                messageBuilder.putAllData(data);
            }
            messageBuilder.putData("timestamp", String.valueOf(System.currentTimeMillis()));

            // Android配置
            AndroidConfig androidConfig = AndroidConfig.builder()
                    .setPriority(AndroidConfig.Priority.HIGH)
                    .build();

            messageBuilder.setAndroidConfig(androidConfig);

            Message message = messageBuilder.build();
            String messageId = firebaseMessaging.send(message);

            logger.info("✅ 数据消息发送成功，MessageId: {}", messageId);
            return PushResult.success(messageId);

        } catch (Exception e) {
            logger.error("❌ 数据消息发送失败: {}", e.getMessage(), e);
            return PushResult.failure("数据消息发送失败: " + e.getMessage());
        }
    }

    /**
     * 判断是否为无效Token错误
     */
    private boolean isInvalidTokenError(FirebaseMessagingException e) {
        String errorCode = e.getErrorCode();
        return "invalid-registration-token".equals(errorCode) ||
               "registration-token-not-registered".equals(errorCode);
    }

    /**
     * 处理无效Token（从数据库删除）
     */
    private void handleInvalidToken(String token) {
        logger.warn("⚠️  检测到无效Token，应从数据库删除: {}", token);
        // TODO: 实现从数据库删除Token的逻辑
        // userRepository.removeFcmToken(token);
    }

    /**
     * 处理失败的Token
     */
    private void handleFailedTokens(List<String> tokens) {
        logger.warn("⚠️  检测到 {} 个失败Token，应从数据库删除", tokens.size());
        // TODO: 实现批量删除失败Token的逻辑
        // userRepository.removeFcmTokens(tokens);
    }
}

