package com.example.uchannel

import android.content.Context
import android.util.Log
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

