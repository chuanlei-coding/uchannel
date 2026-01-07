package com.uchannel

import android.os.Bundle
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import com.uchannel.FCMTokenManager

/**
 * 主Activity
 */
class MainActivity : AppCompatActivity() {

    private lateinit var tokenManager: FCMTokenManager

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // 初始化Token管理器
        tokenManager = FCMTokenManager(this)

        // 获取并注册FCM Token
        tokenManager.getToken { token ->
            if (token != null) {
                Log.d("MainActivity", "FCM Token: $token")
                // TODO: 将Token发送到服务器
                // sendTokenToServer(token)
            } else {
                Log.e("MainActivity", "获取FCM Token失败")
            }
        }
    }
}

