package com.uchannel

import android.content.Context
import android.util.Log
import com.google.firebase.FirebaseApp
import com.google.firebase.messaging.FirebaseMessaging

/**
 * FCM Token 管理器
 * 
 * 负责获取和管理FCM Token
 */
class FCMTokenManager(private val context: Context) {

    companion object {
        private const val TAG = "FCMTokenManager"
        private const val PREFS_NAME = "fcm_prefs"
        private const val KEY_TOKEN = "fcm_token"
    }

    /**
     * 获取当前FCM Token
     */
    fun getToken(callback: (String?) -> Unit) {
        // 如果没有 google-services.json（或未初始化 FirebaseApp），直接跳过，避免启动闪退
        if (!isFirebaseConfigured()) {
            Log.w(TAG, "Firebase 未配置（缺少 google-services.json 或未初始化），跳过获取 FCM Token")
            callback(null)
            return
        }

        try {
            FirebaseMessaging.getInstance().token.addOnCompleteListener { task ->
                if (!task.isSuccessful) {
                    Log.w(TAG, "获取FCM Token失败", task.exception)
                    callback(null)
                    return@addOnCompleteListener
                }

                val token = task.result
                Log.d(TAG, "FCM Token: $token")

                // 保存Token到本地
                saveTokenLocally(token)

                // 发送到服务器
                sendTokenToServer(token)

                callback(token)
            }
        } catch (e: Throwable) {
            // 常见：Default FirebaseApp is not initialized
            Log.w(TAG, "Firebase 未就绪，跳过获取 FCM Token: ${e.message}", e)
            callback(null)
        }
    }

    /**
     * 判断 Firebase 是否已配置（用于没有 google-services.json 的临时构建场景）
     */
    private fun isFirebaseConfigured(): Boolean {
        // 1) 通过 FirebaseApp 判断
        return try {
            if (FirebaseApp.getApps(context).isNotEmpty()) return true
            // 2) 如果尚未初始化，尝试初始化（无配置时会返回 null）
            FirebaseApp.initializeApp(context) != null
        } catch (_: Throwable) {
            false
        }
    }

    /**
     * 保存Token到本地SharedPreferences
     */
    private fun saveTokenLocally(token: String) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        prefs.edit().putString(KEY_TOKEN, token).apply()
    }

    /**
     * 从本地获取Token
     */
    fun getLocalToken(): String? {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        return prefs.getString(KEY_TOKEN, null)
    }

    /**
     * 将Token发送到服务器
     */
    private fun sendTokenToServer(token: String) {
        // TODO: 实现API调用
        // 检查Token是否已发送过，避免重复发送
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val lastSentToken = prefs.getString("last_sent_token", null)
        
        if (lastSentToken == token) {
            Log.d(TAG, "Token未变化，跳过发送")
            return
        }

        // 调用API发送Token
        // ApiService.registerFCMToken(token).enqueue(...)
        
        // 成功后更新记录
        prefs.edit().putString("last_sent_token", token).apply()
    }

    /**
     * 订阅主题
     */
    fun subscribeToTopic(topic: String) {
        if (!isFirebaseConfigured()) {
            Log.w(TAG, "Firebase 未配置，跳过订阅主题: $topic")
            return
        }

        FirebaseMessaging.getInstance().subscribeToTopic(topic)
            .addOnCompleteListener { task ->
                if (task.isSuccessful) {
                    Log.d(TAG, "成功订阅主题: $topic")
                } else {
                    Log.e(TAG, "订阅主题失败: $topic", task.exception)
                }
            }
    }

    /**
     * 取消订阅主题
     */
    fun unsubscribeFromTopic(topic: String) {
        if (!isFirebaseConfigured()) {
            Log.w(TAG, "Firebase 未配置，跳过取消订阅主题: $topic")
            return
        }

        FirebaseMessaging.getInstance().unsubscribeFromTopic(topic)
            .addOnCompleteListener { task ->
                if (task.isSuccessful) {
                    Log.d(TAG, "成功取消订阅主题: $topic")
                } else {
                    Log.e(TAG, "取消订阅失败: $topic", task.exception)
                }
            }
    }
}

