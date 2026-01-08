package com.uchannel.api

import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import java.security.cert.X509Certificate
import javax.net.ssl.SSLContext
import javax.net.ssl.TrustManager
import javax.net.ssl.X509TrustManager

/**
 * API客户端
 */
object ApiClient {
    // 后端服务地址（HTTPS）
    // 开发环境：模拟器使用 10.0.2.2，真机使用电脑IP
    // 当前后端HTTPS运行在8080端口
    private const val BASE_URL = "https://10.0.2.2:8080/"

    // 创建信任所有证书的TrustManager（仅用于开发环境）
    private val trustAllCerts = arrayOf<TrustManager>(object : X509TrustManager {
        override fun checkClientTrusted(chain: Array<out X509Certificate>?, authType: String?) {}
        override fun checkServerTrusted(chain: Array<out X509Certificate>?, authType: String?) {}
        override fun getAcceptedIssuers(): Array<X509Certificate> = arrayOf()
    })

    // 创建OkHttpClient，配置SSL以信任自签名证书（开发环境）
    private val okHttpClient: OkHttpClient = run {
        val sslContext = SSLContext.getInstance("SSL")
        sslContext.init(null, trustAllCerts, java.security.SecureRandom())
        
        val loggingInterceptor = HttpLoggingInterceptor().apply {
            level = HttpLoggingInterceptor.Level.BODY
        }
        
        OkHttpClient.Builder()
            .sslSocketFactory(sslContext.socketFactory, trustAllCerts[0] as X509TrustManager)
            .hostnameVerifier { _, _ -> true } // 信任所有主机名（仅开发环境）
            .addInterceptor(loggingInterceptor)
            .build()
    }

    private val retrofit: Retrofit = Retrofit.Builder()
        .baseUrl(BASE_URL)
        .client(okHttpClient)
        .addConverterFactory(GsonConverterFactory.create())
        .build()

    val chatApiService: ChatApiService = retrofit.create(ChatApiService::class.java)
}
