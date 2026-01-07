package com.uchannel

import android.util.Log
import org.mozilla.javascript.BaseFunction
import org.mozilla.javascript.Context
import org.mozilla.javascript.Scriptable
import org.mozilla.javascript.ScriptableObject

/**
 * JavaScript 引擎（基于 Rhino）
 * 
 * 用于执行用户提供的 JavaScript 代码
 * 注：Rhino 是 Mozilla 开发的纯 Java JavaScript 引擎，完全兼容 ECMAScript 5.1+
 * 
 * 重要：Rhino 的 Context 是线程本地的，每个执行线程都需要自己的 Context
 */
class JSEngine {

    companion object {
        private const val TAG = "JSEngine"
        private var consoleInjected = false  // 标记 console API 是否已注入到全局作用域
    }

    /**
     * 初始化 JavaScript 引擎
     * 注意：Rhino 的 Context 是线程本地的，实际的初始化会在每个执行线程中进行
     */
    fun initialize() {
        try {
            // 只做基本检查，实际的 Context 创建在每个执行线程中进行
            Log.d(TAG, "JavaScript 引擎（Rhino）初始化成功（延迟初始化）")
        } catch (e: Exception) {
            Log.e(TAG, "JavaScript 引擎初始化失败", e)
            throw e
        }
    }

    /**
     * 在当前线程创建 Context 和 Scope
     */
    private fun createContextAndScope(): Pair<Context, Scriptable> {
        val ctx = Context.enter()
        ctx.optimizationLevel = -1  // 禁用优化以获得更好的错误信息
        val scope = ctx.initStandardObjects()
        
        // 只在第一次创建时注入 console API
        if (!consoleInjected) {
            injectConsoleAPI(ctx, scope)
            consoleInjected = true
        }
        
        return Pair(ctx, scope)
    }

    /**
     * 执行 JavaScript 代码
     * 
     * @param code JavaScript 代码
     * @return 执行结果（如果代码有返回值）
     */
    fun execute(code: String): String {
        val (ctx, scope) = createContextAndScope()
        
        return try {
            Log.d(TAG, "执行 JavaScript 代码:\n$code")
            val result = ctx.evaluateString(scope, code, "script", 1, null)
            val resultStr = Context.toString(result)
            Log.d(TAG, "执行结果: $resultStr")
            resultStr
        } catch (e: Exception) {
            val errorMsg = "执行失败: ${e.message}"
            Log.e(TAG, errorMsg, e)
            errorMsg
        } finally {
            Context.exit()
        }
    }

    /**
     * 执行 JavaScript 代码并捕获详细的错误信息
     */
    fun executeWithErrorHandling(code: String): ExecutionResult {
        val (ctx, scope) = createContextAndScope()
        
        return try {
            Log.d(TAG, "执行 JavaScript 代码:\n$code")
            val result = ctx.evaluateString(scope, code, "script", 1, null)
            val resultStr = Context.toString(result)
            Log.d(TAG, "执行成功，结果: $resultStr")
            ExecutionResult.success(resultStr)
        } catch (e: Exception) {
            val errorMsg = when {
                e.message?.contains("SyntaxError") == true -> "语法错误: ${e.message}"
                e.message?.contains("ReferenceError") == true -> "引用错误: ${e.message}"
                e.message?.contains("TypeError") == true -> "类型错误: ${e.message}"
                e.message?.contains("RangeError") == true -> "范围错误: ${e.message}"
                else -> "执行错误: ${e.message}"
            }
            Log.e(TAG, errorMsg, e)
            ExecutionResult.error(errorMsg)
        } finally {
            Context.exit()
        }
    }

    /**
     * 注入预定义的 JavaScript 函数库（如 console.log）
     */
    private fun injectConsoleAPI(ctx: Context, scope: Scriptable) {
        try {
            val consoleCode = """
                (function() {
                    var console = {
                        log: function() {
                            var args = Array.prototype.slice.call(arguments);
                            __android_log('log', args.map(String).join(' '));
                        },
                        info: function() {
                            var args = Array.prototype.slice.call(arguments);
                            __android_log('info', args.map(String).join(' '));
                        },
                        warn: function() {
                            var args = Array.prototype.slice.call(arguments);
                            __android_log('warn', args.map(String).join(' '));
                        },
                        error: function() {
                            var args = Array.prototype.slice.call(arguments);
                            __android_log('error', args.map(String).join(' '));
                        }
                    };
                    
                    // 将 console 设为全局对象
                    this.console = console;
                })();
            """.trimIndent()
            
            // 创建 Android 日志函数（使用 BaseFunction 类）
            val androidLog = object : BaseFunction() {
                override fun call(cx: Context?, scope: Scriptable?, thisObj: Scriptable?, args: Array<out Any>?): Any? {
                    if (args != null && args.size >= 2) {
                        val level = args[0]?.toString() ?: "log"
                        val message = args[1]?.toString() ?: ""
                        when (level) {
                            "log", "info" -> Log.i(TAG, "[console.$level] $message")
                            "warn" -> Log.w(TAG, "[console.$level] $message")
                            "error" -> Log.e(TAG, "[console.$level] $message")
                            else -> Log.d(TAG, "[console] $message")
                        }
                    }
                    return null
                }
                
                override fun getFunctionName(): String = "__android_log"
            }
            
            // 将函数注册到作用域
            ScriptableObject.putProperty(scope, "__android_log", androidLog)
            
            // 执行 console 定义代码
            ctx.evaluateString(scope, consoleCode, "console_init", 1, null)
            
            Log.d(TAG, "已注入 console API")
        } catch (e: Exception) {
            Log.e(TAG, "注入 console API 失败", e)
        }
    }

    /**
     * 释放 JavaScript 引擎资源
     * 注意：Rhino 使用线程本地的 Context，不需要显式释放
     */
    fun release() {
        try {
            // Rhino 的 Context 是线程本地的，退出当前线程的 Context（如果有）
            if (Context.getCurrentContext() != null) {
                Context.exit()
            }
            consoleInjected = false
            Log.d(TAG, "JavaScript 引擎已释放")
        } catch (e: Exception) {
            Log.e(TAG, "释放 JavaScript 引擎失败", e)
        }
    }

    /**
     * 执行结果
     */
    data class ExecutionResult(
        val success: Boolean,
        val result: String? = null,
        val error: String? = null
    ) {
        companion object {
            fun success(result: String) = ExecutionResult(true, result = result)
            fun error(error: String) = ExecutionResult(false, error = error)
        }

        override fun toString(): String {
            return if (success) {
                result ?: "undefined"
            } else {
                "错误: $error"
            }
        }
    }
}
