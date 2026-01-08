package com.uchannel.util

/**
 * 阿里云ASR配置
 * 已配置API Key: sk-bbdf41fb73044d66b46976a1df35abbe
 */
object AsrConfig {
    // 阿里云百炼API Key
    // 百炼API使用Bearer token认证，只需要API Key
    const val API_KEY = "sk-bbdf41fb73044d66b46976a1df35abbe"
    const val API_SECRET = "" // 百炼API不需要Secret
    
    // 或者从SharedPreferences读取
    fun getApiKey(context: android.content.Context): String {
        val prefs = context.getSharedPreferences("asr_config", android.content.Context.MODE_PRIVATE)
        return prefs.getString("api_key", API_KEY) ?: API_KEY
    }
    
    fun getApiSecret(context: android.content.Context): String {
        val prefs = context.getSharedPreferences("asr_config", android.content.Context.MODE_PRIVATE)
        return prefs.getString("api_secret", API_SECRET) ?: API_SECRET
    }
    
    fun setApiKey(context: android.content.Context, key: String) {
        val prefs = context.getSharedPreferences("asr_config", android.content.Context.MODE_PRIVATE)
        prefs.edit().putString("api_key", key).apply()
    }
    
    fun setApiSecret(context: android.content.Context, secret: String) {
        val prefs = context.getSharedPreferences("asr_config", android.content.Context.MODE_PRIVATE)
        prefs.edit().putString("api_secret", secret).apply()
    }
}
