package com.uchannel.api

import retrofit2.Call
import retrofit2.http.Body
import retrofit2.http.POST

/**
 * 聊天API服务接口
 */
interface ChatApiService {
    
    @POST("api/chat/send")
    fun sendMessage(@Body request: ChatRequest): Call<ChatResponse>
}

/**
 * 聊天请求
 */
data class ChatRequest(
    val message: String
)

/**
 * 聊天响应
 */
data class ChatResponse(
    val success: Boolean,
    val message: String,
    val data: Map<String, Any>? = null,
    val error: String? = null
)
