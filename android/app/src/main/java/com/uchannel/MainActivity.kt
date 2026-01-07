package com.uchannel

import android.os.Bundle
import android.util.Log
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.uchannel.FCMTokenManager
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

/**
 * 主Activity
 */
class MainActivity : AppCompatActivity() {

    private lateinit var tokenManager: FCMTokenManager
    private lateinit var jsEngine: JSEngine
    private lateinit var editCode: EditText
    private lateinit var txtResult: TextView
    private lateinit var btnExecute: Button

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // 初始化UI组件
        editCode = findViewById(R.id.editCode)
        txtResult = findViewById(R.id.txtResult)
        btnExecute = findViewById(R.id.btnExecute)

        // 初始化 JavaScript 引擎
        jsEngine = JSEngine()
        try {
            jsEngine.initialize()  // initialize() 内部已调用 injectConsoleAPI()
            Log.d("MainActivity", "JavaScript 引擎初始化成功")
        } catch (e: Exception) {
            Log.e("MainActivity", "JavaScript 引擎初始化失败", e)
            txtResult.text = "JavaScript 引擎初始化失败: ${e.message}"
            btnExecute.isEnabled = false
        }

        // 设置执行按钮点击事件
        btnExecute.setOnClickListener {
            executeJavaScript()
        }

        // 初始化Token管理器（可选，用于推送通知）
        tokenManager = FCMTokenManager(this)

        // 获取并注册FCM Token
        tokenManager.getToken { token ->
            if (token != null) {
                Log.d("MainActivity", "FCM Token: $token")
                // TODO: 将Token发送到服务器
                // sendTokenToServer(token)
            } else {
                // 在没有 google-services.json 的临时构建中，这里会为 null（属于预期）
                Log.w("MainActivity", "未获取到 FCM Token（可能未配置 Firebase）")
            }
        }

        // 设置示例代码
        editCode.setText(getExampleCode())
    }

    /**
     * 执行 JavaScript 代码
     */
    private fun executeJavaScript() {
        val code = editCode.text.toString().trim()
        if (code.isEmpty()) {
            Toast.makeText(this, "请输入 JavaScript 代码", Toast.LENGTH_SHORT).show()
            return
        }

        txtResult.text = "执行中..."
        btnExecute.isEnabled = false

        // 在后台线程执行 JavaScript（避免阻塞UI）
        CoroutineScope(Dispatchers.Default).launch {
            try {
                val result = jsEngine.executeWithErrorHandling(code)
                
                withContext(Dispatchers.Main) {
                    btnExecute.isEnabled = true
                    if (result.success) {
                        txtResult.text = "✓ 执行成功:\n\n${result.result}"
                    } else {
                        txtResult.text = "✗ ${result.error}"
                    }
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    btnExecute.isEnabled = true
                    txtResult.text = "✗ 执行异常: ${e.message}\n${e.stackTraceToString()}"
                    Log.e("MainActivity", "执行 JavaScript 异常", e)
                }
            }
        }
    }

    /**
     * 获取示例代码
     */
    private fun getExampleCode(): String {
        return """
            // JavaScript 代码示例
            var a = 10;
            var b = 20;
            var sum = a + b;
            
            console.log('计算结果:', sum);
            
            // 返回值
            sum
        """.trimIndent()
    }

    override fun onDestroy() {
        super.onDestroy()
        // 释放 JavaScript 引擎资源
        jsEngine.release()
    }
}

