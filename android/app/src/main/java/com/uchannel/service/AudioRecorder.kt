package com.uchannel.service

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.util.Log
import androidx.core.content.ContextCompat
import java.io.File
import java.io.FileOutputStream
import java.io.IOException

/**
 * 音频录制服务
 */
class AudioRecorder(private val context: Context) {

    private var audioRecord: AudioRecord? = null
    private var isRecording = false
    private var recordingThread: Thread? = null

    // 录音参数
    private val sampleRate = 16000  // 16kHz采样率（阿里云ASR推荐）
    private val channelConfig = AudioFormat.CHANNEL_IN_MONO
    private val audioFormat = AudioFormat.ENCODING_PCM_16BIT
    private val bufferSize = AudioRecord.getMinBufferSize(sampleRate, channelConfig, audioFormat)

    /**
     * 检查录音权限
     */
    fun hasPermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            context,
            Manifest.permission.RECORD_AUDIO
        ) == PackageManager.PERMISSION_GRANTED
    }

    /**
     * 开始录音
     * @param onDataAvailable 音频数据回调
     */
    fun startRecording(onDataAvailable: (ByteArray) -> Unit) {
        if (!hasPermission()) {
            Log.e("AudioRecorder", "没有录音权限")
            return
        }

        if (isRecording) {
            Log.w("AudioRecorder", "已经在录音中")
            return
        }

        try {
            audioRecord = AudioRecord(
                MediaRecorder.AudioSource.MIC,
                sampleRate,
                channelConfig,
                audioFormat,
                bufferSize * 2
            )

            if (audioRecord?.state != AudioRecord.STATE_INITIALIZED) {
                Log.e("AudioRecorder", "AudioRecord初始化失败")
                return
            }

            audioRecord?.startRecording()
            isRecording = true

            // 启动录音线程
            recordingThread = Thread {
                val buffer = ByteArray(bufferSize)
                while (isRecording && audioRecord != null) {
                    try {
                        val readSize = audioRecord?.read(buffer, 0, buffer.size) ?: 0
                        if (readSize > 0) {
                            onDataAvailable(buffer.copyOf(readSize))
                        }
                    } catch (e: Exception) {
                        Log.e("AudioRecorder", "读取音频数据失败", e)
                        break
                    }
                }
            }
            recordingThread?.start()

            Log.d("AudioRecorder", "开始录音")
        } catch (e: Exception) {
            Log.e("AudioRecorder", "启动录音失败", e)
            isRecording = false
        }
    }

    /**
     * 停止录音并保存为文件
     * @return 录音文件路径，失败返回null
     */
    fun stopRecording(): String? {
        if (!isRecording) {
            return null
        }

        isRecording = false

        try {
            audioRecord?.stop()
            audioRecord?.release()
            audioRecord = null

            recordingThread?.join(1000)
            recordingThread = null

            Log.d("AudioRecorder", "停止录音")
            
            // 返回临时文件路径（实际使用时需要保存音频数据）
            return null
        } catch (e: Exception) {
            Log.e("AudioRecorder", "停止录音失败", e)
            return null
        }
    }

    /**
     * 录制音频到文件（用于一次性录音）
     * @param durationMs 录音时长（毫秒），0表示不限制
     * @return 录音文件路径
     */
    fun recordToFile(durationMs: Long = 0): String? {
        if (!hasPermission()) {
            Log.e("AudioRecorder", "没有录音权限")
            return null
        }

        val audioFile = File(context.cacheDir, "audio_${System.currentTimeMillis()}.pcm")
        var outputStream: FileOutputStream? = null

        try {
            audioRecord = AudioRecord(
                MediaRecorder.AudioSource.MIC,
                sampleRate,
                channelConfig,
                audioFormat,
                bufferSize * 2
            )

            if (audioRecord?.state != AudioRecord.STATE_INITIALIZED) {
                Log.e("AudioRecorder", "AudioRecord初始化失败")
                return null
            }

            outputStream = FileOutputStream(audioFile)
            audioRecord?.startRecording()

            val buffer = ByteArray(bufferSize)
            var totalBytes = 0L
            val maxBytes = if (durationMs > 0) {
                (sampleRate * 2 * durationMs / 1000) // 16位 = 2字节
            } else {
                Long.MAX_VALUE
            }

            while (totalBytes < maxBytes) {
                val readSize = audioRecord?.read(buffer, 0, buffer.size) ?: 0
                if (readSize > 0) {
                    outputStream.write(buffer, 0, readSize)
                    totalBytes += readSize
                } else {
                    break
                }
            }

            audioRecord?.stop()
            audioRecord?.release()
            audioRecord = null
            outputStream.close()

            Log.d("AudioRecorder", "录音完成: ${audioFile.absolutePath}")
            return audioFile.absolutePath
        } catch (e: Exception) {
            Log.e("AudioRecorder", "录音失败", e)
            audioRecord?.release()
            audioRecord = null
            outputStream?.close()
            audioFile.delete()
            return null
        }
    }

    /**
     * 检查是否正在录音
     */
    fun isRecording(): Boolean = isRecording

    /**
     * 释放资源
     */
    fun release() {
        if (isRecording) {
            stopRecording()
        }
    }
}
