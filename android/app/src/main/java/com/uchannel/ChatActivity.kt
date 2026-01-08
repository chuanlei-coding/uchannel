package com.uchannel

import android.os.Bundle
import android.util.Log
import android.widget.Button
import android.widget.EditText
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.uchannel.adapter.MessageAdapter
import com.uchannel.api.ApiClient
import com.uchannel.api.ChatRequest
import com.uchannel.api.ChatResponse
import com.uchannel.model.Message
import com.uchannel.model.MessageSender
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import java.util.*

/**
 * 聊天Activity
 * 使用原生Android UI实现类似微信的对话框界面
 */
class ChatActivity : AppCompatActivity() {

    private lateinit var recyclerView: RecyclerView
    private lateinit var inputEditText: EditText
    private lateinit var sendButton: Button
    private lateinit var messageAdapter: MessageAdapter
    private val messages = mutableListOf<Message>()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // 隐藏ActionBar
        supportActionBar?.hide()
        
        setContentView(R.layout.activity_chat)

        // 设置系统状态栏透明，让布局延伸到状态栏
        window.statusBarColor = android.graphics.Color.TRANSPARENT
        
        initViews()
        setupRecyclerView()
        setupInputArea()
        
        // 添加欢迎消息
        addWelcomeMessage()
    }

    private fun initViews() {
        recyclerView = findViewById(R.id.recyclerViewMessages)
        inputEditText = findViewById(R.id.editTextInput)
        sendButton = findViewById(R.id.buttonSend)
    }

    private fun setupRecyclerView() {
        messageAdapter = MessageAdapter(messages)
        recyclerView.layoutManager = LinearLayoutManager(this).apply {
            stackFromEnd = true  // 从底部开始显示
        }
        recyclerView.adapter = messageAdapter
    }

    private fun setupInputArea() {
        sendButton.setOnClickListener {
            sendMessage()
        }

        // 支持回车发送
        inputEditText.setOnEditorActionListener { _, _, _ ->
            sendMessage()
            true
        }
    }

    private fun addWelcomeMessage() {
        val welcomeMessage = Message(
            id = UUID.randomUUID().toString(),
            content = "你好！我是日程安排助手，可以帮你管理日程。请告诉我你的安排。",
            sender = MessageSender.ASSISTANT,
            timestamp = Date()
        )
        messages.add(welcomeMessage)
        messageAdapter.notifyItemInserted(messages.size - 1)
        scrollToBottom()
    }

    private fun sendMessage() {
        val content = inputEditText.text.toString().trim()
        if (content.isEmpty()) {
            return
        }

        // 清空输入框
        inputEditText.setText("")

        // 添加用户消息
        val userMessage = Message(
            id = UUID.randomUUID().toString(),
            content = content,
            sender = MessageSender.USER,
            timestamp = Date()
        )
        messages.add(userMessage)
        messageAdapter.notifyItemInserted(messages.size - 1)
        scrollToBottom()

        // 显示加载中的消息
        val loadingMessage = Message(
            id = UUID.randomUUID().toString(),
            content = "正在处理...",
            sender = MessageSender.ASSISTANT,
            timestamp = Date()
        )
        messages.add(loadingMessage)
        val loadingIndex = messages.size - 1
        messageAdapter.notifyItemInserted(loadingIndex)
        scrollToBottom()

        // 发送到后端
        sendToBackend(content, loadingMessage.id)
    }

    private fun sendToBackend(content: String, loadingMessageId: String) {
        val request = ChatRequest(message = content)
        val call = ApiClient.chatApiService.sendMessage(request)

        call.enqueue(object : Callback<ChatResponse> {
            override fun onResponse(call: Call<ChatResponse>, response: Response<ChatResponse>) {
                if (response.isSuccessful && response.body() != null) {
                    val chatResponse = response.body()!!
                    if (chatResponse.success) {
                        // 移除加载消息，添加实际回复
                        val loadingIndex = messages.indexOfFirst { it.id == loadingMessageId }
                        if (loadingIndex != -1) {
                            messages.removeAt(loadingIndex)
                            messageAdapter.notifyItemRemoved(loadingIndex)
                        }

                        val assistantMessage = Message(
                            id = UUID.randomUUID().toString(),
                            content = chatResponse.message,
                            sender = MessageSender.ASSISTANT,
                            timestamp = Date()
                        )
                        messages.add(assistantMessage)
                        messageAdapter.notifyItemInserted(messages.size - 1)
                        scrollToBottom()
                    } else {
                        handleError(loadingMessageId, chatResponse.error ?: "处理失败")
                    }
                } else {
                    handleError(loadingMessageId, "服务器响应错误")
                }
            }

            override fun onFailure(call: Call<ChatResponse>, t: Throwable) {
                Log.e("ChatActivity", "网络请求失败", t)
                handleError(loadingMessageId, "网络连接失败，请检查网络设置")
            }
        })
    }

    private fun handleError(loadingMessageId: String, errorMessage: String) {
        val loadingIndex = messages.indexOfFirst { it.id == loadingMessageId }
        if (loadingIndex != -1) {
            messages.removeAt(loadingIndex)
            messageAdapter.notifyItemRemoved(loadingIndex)
        }

        val errorMsg = Message(
            id = UUID.randomUUID().toString(),
            content = "抱歉，处理您的消息时出现了错误：$errorMessage",
            sender = MessageSender.ASSISTANT,
            timestamp = Date()
        )
        messages.add(errorMsg)
        messageAdapter.notifyItemInserted(messages.size - 1)
        scrollToBottom()

        Toast.makeText(this, errorMessage, Toast.LENGTH_SHORT).show()
    }

    private fun scrollToBottom() {
        recyclerView.post {
            if (messages.isNotEmpty()) {
                recyclerView.smoothScrollToPosition(messages.size - 1)
            }
        }
    }
}
