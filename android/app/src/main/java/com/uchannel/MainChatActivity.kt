package com.uchannel

import android.os.Bundle
import android.util.Log
import android.widget.LinearLayout
import androidx.appcompat.app.AppCompatActivity
import androidx.viewpager2.widget.ViewPager2
import com.google.android.material.tabs.TabLayout
import com.google.android.material.tabs.TabLayoutMediator
import com.uchannel.FCMTokenManager
import com.uchannel.adapter.MainPagerAdapter

/**
 * 主聊天Activity
 * 包含Tab导航：聊天和日程列表
 */
class MainChatActivity : AppCompatActivity() {

    private lateinit var viewPager: ViewPager2
    private lateinit var tabLayout: TabLayout
    private lateinit var tokenManager: FCMTokenManager

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // 隐藏ActionBar
        supportActionBar?.hide()
        
        setContentView(R.layout.activity_main_chat)

        // 设置系统状态栏透明
        window.statusBarColor = android.graphics.Color.TRANSPARENT

        initViews()
        setupViewPager()
        setupTabs()
        initFCMToken()
    }
    
    private fun initFCMToken() {
        // 初始化Token管理器（可选，用于推送通知）
        tokenManager = FCMTokenManager(this)

        // 获取并注册FCM Token
        tokenManager.getToken { token ->
            if (token != null) {
                Log.d("MainChatActivity", "FCM Token: $token")
                // TODO: 将Token发送到服务器
                // sendTokenToServer(token)
            } else {
                // 在没有 google-services.json 的临时构建中，这里会为 null（属于预期）
                Log.w("MainChatActivity", "未获取到 FCM Token（可能未配置 Firebase）")
            }
        }
    }

    private fun initViews() {
        viewPager = findViewById(R.id.viewPager)
        tabLayout = findViewById(R.id.tabLayout)
    }

    private fun setupViewPager() {
        val adapter = MainPagerAdapter(this)
        viewPager.adapter = adapter
    }

    private fun setupTabs() {
        TabLayoutMediator(tabLayout, viewPager) { tab, position ->
            tab.text = when (position) {
                0 -> "聊天"
                1 -> "日程"
                else -> ""
            }
        }.attach()
    }
}
