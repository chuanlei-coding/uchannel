package com.uchannel.fragment

import android.Manifest
import android.content.pm.PackageManager
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.EditText
import android.widget.ImageButton
import android.widget.Toast
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.uchannel.R
import com.uchannel.adapter.MessageAdapter
import com.uchannel.api.ApiClient
import com.uchannel.api.AliyunAsrService
import com.uchannel.api.ChatRequest
import com.uchannel.api.ChatResponse
import com.uchannel.model.Message
import com.uchannel.model.MessageSender
import com.uchannel.service.AudioRecorder
import com.uchannel.util.AsrConfig
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import java.util.*

/**
 * 聊天Fragment
 * 使用原生Android UI实现类似微信的对话框界面
 */
class ChatFragment : Fragment() {

    private lateinit var recyclerView: RecyclerView
    private lateinit var inputEditText: EditText
    private lateinit var sendButton: Button
    private lateinit var buttonVoice: ImageButton
    private lateinit var messageAdapter: MessageAdapter
    private val messages = mutableListOf<Message>()
    
    private lateinit var audioRecorder: AudioRecorder
    private var asrService: AliyunAsrService? = null
    private var isRecording = false
    private var currentAudioFile: String? = null
    
    companion object {
        private const val REQUEST_RECORD_AUDIO_PERMISSION = 200
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(R.layout.fragment_chat, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        initViews(view)
        setupRecyclerView()
        setupInputArea()
        
        // 添加欢迎消息
        addWelcomeMessage()
    }

    private fun initViews(view: View) {
        recyclerView = view.findViewById(R.id.recyclerViewMessages)
        inputEditText = view.findViewById(R.id.editTextInput)
        sendButton = view.findViewById(R.id.buttonSend)
        buttonVoice = view.findViewById(R.id.buttonVoice)
        
        // 初始化录音器
        audioRecorder = AudioRecorder(requireContext())
        
        // 初始化ASR服务
        val apiKey = AsrConfig.getApiKey(requireContext())
        val apiSecret = AsrConfig.getApiSecret(requireContext())
        if (apiKey.isNotEmpty()) {
            asrService = AliyunAsrService(apiKey, apiSecret)
        }
    }

    private fun setupRecyclerView() {
        messageAdapter = MessageAdapter(messages)
        recyclerView.layoutManager = LinearLayoutManager(requireContext()).apply {
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
        
        // 语音输入按钮
        buttonVoice.setOnClickListener {
            handleVoiceInput()
        }
    }
    
    private fun handleVoiceInput() {
        if (!checkAudioPermission()) {
            requestAudioPermission()
            return
        }
        
        if (isRecording) {
            // 停止录音并识别
            stopRecordingAndRecognize()
        } else {
            // 开始录音
            startRecording()
        }
    }
    
    private fun checkAudioPermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            requireContext(),
            Manifest.permission.RECORD_AUDIO
        ) == PackageManager.PERMISSION_GRANTED
    }
    
    private fun requestAudioPermission() {
        ActivityCompat.requestPermissions(
            requireActivity(),
            arrayOf(Manifest.permission.RECORD_AUDIO),
            REQUEST_RECORD_AUDIO_PERMISSION
        )
    }
    
    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQUEST_RECORD_AUDIO_PERMISSION) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                handleVoiceInput()
            } else {
                Toast.makeText(requireContext(), "需要录音权限才能使用语音输入", Toast.LENGTH_SHORT).show()
            }
        }
    }
    
    private fun startRecording() {
        if (asrService == null) {
            Toast.makeText(requireContext(), "请先配置阿里云ASR API密钥", Toast.LENGTH_LONG).show()
            return
        }
        
        isRecording = true
        buttonVoice.setImageResource(R.drawable.ic_voice_recording)
        buttonVoice.isEnabled = false
        
        // 在后台线程录音
        CoroutineScope(Dispatchers.IO).launch {
            currentAudioFile = audioRecorder.recordToFile(30000) // 最长30秒
            
            withContext(Dispatchers.Main) {
                isRecording = false
                buttonVoice.setImageResource(R.drawable.ic_voice)
                buttonVoice.isEnabled = true
                
                if (currentAudioFile != null) {
                    // 识别语音
                    recognizeAudio(currentAudioFile!!)
                } else {
                    Toast.makeText(requireContext(), "录音失败", Toast.LENGTH_SHORT).show()
                }
            }
        }
    }
    
    private fun stopRecordingAndRecognize() {
        isRecording = false
        buttonVoice.setImageResource(R.drawable.ic_voice)
        buttonVoice.isEnabled = true
        
        audioRecorder.stopRecording()
        
        if (currentAudioFile != null) {
            recognizeAudio(currentAudioFile!!)
        }
    }
    
    private fun recognizeAudio(audioFilePath: String) {
        val service = asrService ?: run {
            Toast.makeText(requireContext(), "ASR服务未配置", Toast.LENGTH_SHORT).show()
            return
        }
        
        // 显示识别中提示
        inputEditText.hint = "正在识别语音..."
        inputEditText.isEnabled = false
        
        service.transcribe(
            audioFilePath,
            onSuccess = { text ->
                // 识别成功，填充到输入框
                inputEditText.setText(text)
                inputEditText.hint = "输入日程安排指令..."
                inputEditText.isEnabled = true
                inputEditText.setSelection(text.length) // 光标移到末尾
                
                // 删除临时文件
                try {
                    java.io.File(audioFilePath).delete()
                } catch (e: Exception) {
                    Log.e("ChatFragment", "删除临时文件失败", e)
                }
            },
            onError = { error ->
                // 识别失败
                inputEditText.hint = "输入日程安排指令..."
                inputEditText.isEnabled = true
                Toast.makeText(requireContext(), "语音识别失败: $error", Toast.LENGTH_SHORT).show()
                
                // 删除临时文件
                try {
                    java.io.File(audioFilePath).delete()
                } catch (e: Exception) {
                    Log.e("ChatFragment", "删除临时文件失败", e)
                }
            }
        )
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
                        
                        // TODO: 从回复中提取日程信息，通知ScheduleFragment更新
                    } else {
                        handleError(loadingMessageId, chatResponse.error ?: "处理失败")
                    }
                } else {
                    handleError(loadingMessageId, "服务器响应错误")
                }
            }

            override fun onFailure(call: Call<ChatResponse>, t: Throwable) {
                Log.e("ChatFragment", "网络请求失败", t)
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

        Toast.makeText(requireContext(), errorMessage, Toast.LENGTH_SHORT).show()
    }

    private fun scrollToBottom() {
        recyclerView.post {
            if (messages.isNotEmpty()) {
                recyclerView.smoothScrollToPosition(messages.size - 1)
            }
        }
    }
    
    override fun onDestroyView() {
        super.onDestroyView()
        // 释放录音器资源
        if (isRecording) {
            audioRecorder.stopRecording()
        }
        audioRecorder.release()
    }
}
