package com.uchannel.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.messaging.FirebaseMessaging;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;

import javax.annotation.PostConstruct;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

/**
 * Firebase配置类
 * 初始化Firebase Admin SDK
 */
@Configuration
public class FirebaseConfig {

    private static final Logger logger = LoggerFactory.getLogger(FirebaseConfig.class);

    @Value("${firebase.service-account-key:serviceAccountKey.json}")
    private String serviceAccountKeyPath;

    @Value("${firebase.database-url:}")
    private String databaseUrl;

    @PostConstruct
    public void initialize() {
        try {
            if (FirebaseApp.getApps().isEmpty()) {
                InputStream serviceAccount = getServiceAccountInputStream();
                
                FirebaseOptions.Builder optionsBuilder = FirebaseOptions.builder()
                        .setCredentials(GoogleCredentials.fromStream(serviceAccount));
                
                if (databaseUrl != null && !databaseUrl.isEmpty()) {
                    optionsBuilder.setDatabaseUrl(databaseUrl);
                }
                
                FirebaseOptions options = optionsBuilder.build();
                FirebaseApp.initializeApp(options);
                
                logger.info("✅ Firebase Admin SDK 初始化成功");
            } else {
                logger.info("Firebase App 已存在，跳过初始化");
            }
        } catch (IOException e) {
            logger.error("❌ Firebase初始化失败", e);
            throw new RuntimeException("无法初始化Firebase", e);
        }
    }

    /**
     * 获取服务账号密钥输入流
     * 优先从类路径加载，如果不存在则从文件系统加载
     */
    private InputStream getServiceAccountInputStream() throws IOException {
        // 尝试从类路径加载
        try {
            ClassPathResource resource = new ClassPathResource(serviceAccountKeyPath);
            if (resource.exists()) {
                logger.info("从类路径加载服务账号密钥: {}", serviceAccountKeyPath);
                return resource.getInputStream();
            }
        } catch (Exception e) {
            logger.debug("无法从类路径加载服务账号密钥: {}", e.getMessage());
        }

        // 尝试从文件系统加载
        try {
            logger.info("从文件系统加载服务账号密钥: {}", serviceAccountKeyPath);
            return new FileInputStream(serviceAccountKeyPath);
        } catch (Exception e) {
            logger.error("无法从文件系统加载服务账号密钥: {}", e.getMessage());
            throw new IOException("无法加载Firebase服务账号密钥文件: " + serviceAccountKeyPath, e);
        }
    }

    @Bean
    public FirebaseMessaging firebaseMessaging() {
        return FirebaseMessaging.getInstance();
    }
}

