/**
 * Audio Utilities - PCM 编码/解码工具
 *
 * 处理 Float32 PCM 数据与 Base64 编码的 16-bit PCM 之间的转换
 */

/**
 * 将 Float32Array PCM 数据编码为 Base64 字符串
 *
 * 转换流程:
 * 1. Float32 样本 (-1.0 ~ 1.0) -> 16-bit 有符号整数 (-32768 ~ 32767)
 * 2. 16-bit 整数以 little-endian 字节序写入 ArrayBuffer
 * 3. 字节数组转换为 Base64 字符串
 *
 * @param samples Float32Array PCM 样本数据
 * @returns Base64 编码的 16-bit PCM 数据
 */
export function pcmFloat32ToBase64(samples: Float32Array): string {
  const buffer = new ArrayBuffer(samples.length * 2);
  const view = new DataView(buffer);

  for (let i = 0; i < samples.length; i++) {
    // Clamp 值到 [-1, 1] 范围
    const s = Math.max(-1, Math.min(1, samples[i]));
    // 转换为 16-bit 有符号整数
    // 负数: -1.0 -> -32768 (0x8000)
    // 正数: 1.0 -> 32767 (0x7FFF)
    const int16 = s < 0 ? s * 0x8000 : s * 0x7fff;
    // Little-endian 字节序
    view.setInt16(i * 2, int16, true);
  }

  // 转换为 Base64
  const bytes = new Uint8Array(buffer);
  let binary = '';
  for (let i = 0; i < bytes.length; i++) {
    binary += String.fromCharCode(bytes[i]);
  }
  return btoa(binary);
}

/**
 * 将 Base64 编码的 16-bit PCM 数据解码为 Int16Array
 *
 * @param base64 Base64 编码的 16-bit PCM 数据
 * @returns Int16Array PCM 数据
 */
export function base64ToPcmInt16(base64: string): Int16Array {
  const binary = atob(base64);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }

  const buffer = bytes.buffer;
  return new Int16Array(buffer);
}

/**
 * 将 Base64 编码的 16-bit PCM 数据解码为 Float32Array
 *
 * @param base64 Base64 编码的 16-bit PCM 数据
 * @returns Float32Array PCM 数据 (-1.0 ~ 1.0)
 */
export function base64ToPcmFloat32(base64: string): Float32Array {
  const int16Data = base64ToPcmInt16(base64);
  const float32Data = new Float32Array(int16Data.length);

  for (let i = 0; i < int16Data.length; i++) {
    const sample = int16Data[i];
    // 反向转换: 16-bit 整数 -> Float32
    if (sample < 0) {
      float32Data[i] = sample / 0x8000;
    } else {
      float32Data[i] = sample / 0x7fff;
    }
  }

  return float32Data;
}

/**
 * 生成正弦波 PCM 数据（用于测试）
 *
 * @param frequency 频率 (Hz)
 * @param sampleRate 采样率 (Hz)
 * @param durationSec 持续时间 (秒)
 * @returns Float32Array PCM 数据
 */
export function generateSineWave(
  frequency: number,
  sampleRate: number,
  durationSec: number,
): Float32Array {
  const numSamples = Math.floor(sampleRate * durationSec);
  const samples = new Float32Array(numSamples);

  for (let i = 0; i < numSamples; i++) {
    const t = i / sampleRate;
    samples[i] = Math.sin(2 * Math.PI * frequency * t);
  }

  return samples;
}

/**
 * 验证 PCM 数据的有效性
 *
 * @param samples Float32Array PCM 数据
 * @returns 是否有效
 */
export function validatePcmData(samples: Float32Array): boolean {
  if (!samples || samples.length === 0) {
    return false;
  }

  // 检查是否所有值都在 [-1, 1] 范围内
  for (let i = 0; i < samples.length; i++) {
    if (samples[i] < -1 || samples[i] > 1 || !Number.isFinite(samples[i])) {
      return false;
    }
  }

  return true;
}

/**
 * 计算 PCM 数据的 RMS 音量（用于调试）
 *
 * @param samples Float32Array PCM 数据
 * @returns RMS 值 (0 ~ 1)
 */
export function calculateRms(samples: Float32Array): number {
  if (samples.length === 0) return 0;

  let sumSquares = 0;
  for (let i = 0; i < samples.length; i++) {
    sumSquares += samples[i] * samples[i];
  }

  return Math.sqrt(sumSquares / samples.length);
}

/**
 * 检查 PCM 数据是否为静音
 *
 * @param samples Float32Array PCM 数据
 * @param threshold 阈值 (默认 0.01)
 * @returns 是否为静音
 */
export function isSilence(samples: Float32Array, threshold = 0.01): boolean {
  const rms = calculateRms(samples);
  return rms < threshold;
}
