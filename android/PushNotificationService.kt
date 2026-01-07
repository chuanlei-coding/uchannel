package com.example.uchannel

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.media.RingtoneManager
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

/**
 * Firebase Cloud Messaging 服务
 * 
 * 处理接收到的推送消息
 */
class PushNotificationService : FirebaseMessagingService() {

    companion object {
        private const val TAG = "PushNotificationService"
        private const val CHANNEL_ID = "default_channel"
        private const val CHANNEL_NAME = "默认通知渠道"
    }

    /**
     * 当FCM Token刷新时调用
     * 需要将新Token发送到服务器
     */
    override fun onNewToken(token: String) {
        Log.d(TAG, "新的FCM Token: $token")
        
        // 将Token发送到服务器
        sendTokenToServer(token)
    }

    /**
     * 当收到推送消息时调用
     */
    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        Log.d(TAG, "收到推送消息，From: ${remoteMessage.from}")

        // 检查消息是否包含通知负载
        remoteMessage.notification?.let {
            Log.d(TAG, "通知标题: ${it.title}")
            Log.d(TAG, "通知内容: ${it.body}")
            
            // 显示通知
            showNotification(it.title ?: "", it.body ?: "")
        }

        // 检查消息是否包含数据负载
        if (remoteMessage.data.isNotEmpty()) {
            Log.d(TAG, "数据负载: ${remoteMessage.data}")
            
            // 处理自定义数据
            handleCustomData(remoteMessage.data)
        }
    }

    /**
     * 显示通知
     */
    private fun showNotification(title: String, messageBody: String) {
        val intent = Intent(this, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }
        
        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        // 创建通知渠道（Android 8.0+）
        createNotificationChannel()

        val defaultSoundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
        
        val notificationBuilder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification) // 需要添加通知图标
            .setContentTitle(title)
            .setContentText(messageBody)
            .setAutoCancel(true)
            .setSound(defaultSoundUri)
            .setContentIntent(pendingIntent)
            .setPriority(NotificationCompat.PRIORITY_HIGH)

        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(System.currentTimeMillis().toInt(), notificationBuilder.build())
    }

    /**
     * 创建通知渠道（Android 8.0+ 必需）
     */
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "默认通知渠道"
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 250, 250, 250)
            }

            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }

    /**
     * 处理自定义数据
     */
    private fun handleCustomData(data: Map<String, String>) {
        // 根据数据类型执行不同操作
        when (val type = data["type"]) {
            "message" -> {
                // 处理消息类型
                val messageId = data["id"]
                Log.d(TAG, "收到消息推送，ID: $messageId")
                // TODO: 更新UI或执行其他操作
            }
            "system" -> {
                // 处理系统通知
                Log.d(TAG, "收到系统通知")
                // TODO: 处理系统通知
            }
            else -> {
                Log.d(TAG, "未知数据类型: $type")
            }
        }
    }

    /**
     * 将Token发送到服务器
     */
    private fun sendTokenToServer(token: String) {
        // TODO: 实现API调用，将Token发送到服务器
        // 示例使用 Retrofit 或 OkHttp
        
        /*
        val apiService = RetrofitClient.apiService
        apiService.registerFCMToken(token).enqueue(object : Callback<ResponseBody> {
            override fun onResponse(call: Call<ResponseBody>, response: Response<ResponseBody>) {
                if (response.isSuccessful) {
                    Log.d(TAG, "Token已成功发送到服务器")
                } else {
                    Log.e(TAG, "Token发送失败: ${response.code()}")
                }
            }

            override fun onFailure(call: Call<ResponseBody>, t: Throwable) {
                Log.e(TAG, "Token发送失败", t)
            }
        })
        */
        
        // 或者使用 SharedPreferences 临时存储，稍后发送
        val prefs = getSharedPreferences("app_prefs", Context.MODE_PRIVATE)
        prefs.edit().putString("fcm_token", token).apply()
    }
}

