package com.uchannel.api

import android.util.Base64
import android.util.Log
import okhttp3.*
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject
import java.io.File
import java.io.FileInputStream
import java.io.IOException
import java.util.concurrent.TimeUnit

/**
 * 阿里云ASR服务
 * 使用qwen3-asr-flash进行语音识别
 */
class AliyunAsrService(
    private val apiKey: String,
    private val apiSecret: String
) {
    
    companion object {
        private const val TAG = "AliyunAsrService"
        private const val BASE_URL = "https://dashscope.aliyuncs.com/api/v1/services/audio/asr/transcription"
        private const val TIMEOUT = 30L
    }

    private val client = OkHttpClient.Builder()
        .connectTimeout(TIMEOUT, TimeUnit.SECONDS)
        .readTimeout(TIMEOUT, TimeUnit.SECONDS)
        .writeTimeout(TIMEOUT, TimeUnit.SECONDS)
        .build()

    /**
     * 识别音频文件
     * @param audioFilePath PCM音频文件路径
     * @param onSuccess 成功回调
     * @param onError 错误回调
     */
    fun transcribe(
        audioFilePath: String,
        onSuccess: (String) -> Unit,
        onError: (String) -> Unit
    ) {
        try {
            val audioFile = File(audioFilePath)
            if (!audioFile.exists()) {
                onError("音频文件不存在")
                return
            }

            // 读取音频文件并转换为Base64
            val audioBytes = FileInputStream(audioFile).use { it.readBytes() }
            val audioBase64 = Base64.encodeToString(audioBytes, Base64.NO_WRAP)

            // 构建请求体
            val requestBody = JSONObject().apply {
                put("model", "qwen3-asr-flash")
                put("format", "pcm")
                put("sample_rate", 16000)
                put("channels", 1)
                put("bit_depth", 16)
                put("audio", audioBase64)
            }

            val mediaType = "application/json".toMediaType()
            val body = requestBody.toString().toRequestBody(mediaType)

            // 构建请求
            // 阿里云百炼API使用Bearer token认证
            val request = Request.Builder()
                .url(BASE_URL)
                .post(body)
                .addHeader("Authorization", "Bearer $apiKey")
                .addHeader("Content-Type", "application/json")
                .addHeader("X-DashScope-SSE", "disable") // 禁用SSE
                .build()

            // 异步执行请求
            client.newCall(request).enqueue(object : Callback {
                override fun onFailure(call: Call, e: IOException) {
                    Log.e(TAG, "ASR请求失败", e)
                    onError("网络请求失败: ${e.message}")
                }

                override fun onResponse(call: Call, response: Response) {
                    try {
                        val responseBody = response.body?.string()
                        Log.d(TAG, "ASR响应: $responseBody")
                        
                        if (response.isSuccessful && responseBody != null) {
                            val json = JSONObject(responseBody)
                            
                            // 尝试多种可能的响应格式
                            val text = when {
                                json.has("output") -> {
                                    val output = json.get("output")
                                    when {
                                        output is String -> output
                                        output is JSONObject -> output.optString("text", "")
                                        else -> ""
                                    }
                                }
                                json.has("text") -> json.optString("text", "")
                                json.has("result") -> json.optString("result", "")
                                else -> ""
                            }
                            
                            if (text.isNotEmpty()) {
                                onSuccess(text.trim())
                            } else {
                                Log.w(TAG, "识别结果为空，完整响应: $responseBody")
                                onError("识别结果为空")
                            }
                        } else {
                            val errorMsg = try {
                                val errorJson = JSONObject(responseBody ?: "{}")
                                errorJson.optString("message", errorJson.optString("error", "识别失败"))
                            } catch (e: Exception) {
                                "识别失败: HTTP ${response.code}"
                            }
                            Log.e(TAG, "ASR请求失败: $errorMsg")
                            onError(errorMsg)
                        }
                    } catch (e: Exception) {
                        Log.e(TAG, "解析响应失败", e)
                        onError("解析响应失败: ${e.message}")
                    }
                }
            })

        } catch (e: Exception) {
            Log.e(TAG, "语音识别失败", e)
            onError("识别失败: ${e.message}")
        }
    }
}
