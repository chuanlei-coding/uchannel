/**
 * Audio Utilities 单元测试
 */

import {
  pcmFloat32ToBase64,
  base64ToPcmInt16,
  base64ToPcmFloat32,
  generateSineWave,
  validatePcmData,
  calculateRms,
  isSilence,
} from '../audioUtils';

describe('audioUtils', () => {
  describe('pcmFloat32ToBase64', () => {
    it('应该正确编码零值', () => {
      const samples = new Float32Array([0, 0, 0]);
      const base64 = pcmFloat32ToBase64(samples);

      // 解码并验证
      const decoded = base64ToPcmInt16(base64);
      expect(decoded.length).toBe(3);
      expect(decoded[0]).toBe(0);
      expect(decoded[1]).toBe(0);
      expect(decoded[2]).toBe(0);
    });

    it('应该正确编码最大正值', () => {
      const samples = new Float32Array([1.0]);
      const base64 = pcmFloat32ToBase64(samples);

      const decoded = base64ToPcmInt16(base64);
      expect(decoded[0]).toBe(32767); // 0x7FFF
    });

    it('应该正确编码最大负值', () => {
      const samples = new Float32Array([-1.0]);
      const base64 = pcmFloat32ToBase64(samples);

      const decoded = base64ToPcmInt16(base64);
      expect(decoded[0]).toBe(-32768); // 0x8000
    });

    it('应该 clamp 超出范围的值', () => {
      const samples = new Float32Array([2.0, -2.0]);
      const base64 = pcmFloat32ToBase64(samples);

      const decoded = base64ToPcmInt16(base64);
      expect(decoded[0]).toBe(32767); // 2.0 -> 1.0 -> 32767
      expect(decoded[1]).toBe(-32768); // -2.0 -> -1.0 -> -32768
    });

    it('应该正确编码 0.5 值', () => {
      const samples = new Float32Array([0.5]);
      const base64 = pcmFloat32ToBase64(samples);

      const decoded = base64ToPcmInt16(base64);
      expect(decoded[0]).toBe(16383); // 0.5 * 32767 ≈ 16383
    });

    it('应该正确编码 -0.5 值', () => {
      const samples = new Float32Array([-0.5]);
      const base64 = pcmFloat32ToBase64(samples);

      const decoded = base64ToPcmInt16(base64);
      expect(decoded[0]).toBe(-16384); // -0.5 * 32768 = -16384
    });
  });

  describe('base64ToPcmFloat32', () => {
    it('应该正确解码并保持数据一致性', () => {
      const original = new Float32Array([0, 0.5, -0.5, 1.0, -1.0, 0.25, -0.75]);
      const base64 = pcmFloat32ToBase64(original);
      const decoded = base64ToPcmFloat32(base64);

      expect(decoded.length).toBe(original.length);

      // 允许小误差（16-bit 量化误差）
      for (let i = 0; i < original.length; i++) {
        expect(Math.abs(decoded[i] - original[i])).toBeLessThan(0.0001);
      }
    });
  });

  describe('往返编码测试', () => {
    it('Float32 -> Base64 -> Int16 应该保持一致性', () => {
      const original = new Float32Array([0, 0.123, -0.456, 0.789, -0.999]);

      // 编码
      const base64 = pcmFloat32ToBase64(original);

      // 解码为 Int16
      const int16 = base64ToPcmInt16(base64);

      // 验证
      expect(int16.length).toBe(original.length);

      for (let i = 0; i < original.length; i++) {
        // 计算期望的 Int16 值
        const s = Math.max(-1, Math.min(1, original[i]));
        const expected = s < 0 ? Math.round(s * 0x8000) : Math.round(s * 0x7fff);

        expect(int16[i]).toBe(expected);
      }
    });

    it('Float32 -> Base64 -> Float32 应该保持数据特征', () => {
      const original = new Float32Array([0, 0.5, -0.5, 0.25, -0.75]);
      const base64 = pcmFloat32ToBase64(original);
      const decoded = base64ToPcmFloat32(base64);

      // 验证符号相同
      for (let i = 0; i < original.length; i++) {
        expect(Math.sign(decoded[i])).toBe(Math.sign(original[i]));
      }

      // 验证相对误差小于 0.01%
      for (let i = 0; i < original.length; i++) {
        if (original[i] !== 0) {
          const relativeError = Math.abs((decoded[i] - original[i]) / original[i]);
          expect(relativeError).toBeLessThan(0.0001);
        }
      }
    });
  });

  describe('generateSineWave', () => {
    it('应该生成正确长度的数据', () => {
      const samples = generateSineWave(440, 16000, 0.1);
      expect(samples.length).toBe(1600); // 16000 * 0.1
    });

    it('应该生成在 [-1, 1] 范围内的值', () => {
      const samples = generateSineWave(440, 16000, 0.1);

      for (let i = 0; i < samples.length; i++) {
        expect(samples[i]).toBeGreaterThanOrEqual(-1);
        expect(samples[i]).toBeLessThanOrEqual(1);
      }
    });

    it('应该生成正弦波数据', () => {
      const samples = generateSineWave(440, 16000, 0.1);

      // 正弦波应该在某个点达到峰值（接近 1 或 -1）
      const max = Math.max(...samples);
      const min = Math.min(...samples);

      expect(max).toBeGreaterThan(0.9);
      expect(min).toBeLessThan(-0.9);
    });

    it('生成的正弦波应该可以正确编码为 base64', () => {
      const samples = generateSineWave(440, 16000, 0.1);
      const base64 = pcmFloat32ToBase64(samples);

      expect(typeof base64).toBe('string');
      expect(base64.length).toBeGreaterThan(0);

      // 验证可以解码
      const decoded = base64ToPcmInt16(base64);
      expect(decoded.length).toBe(samples.length);
    });
  });

  describe('validatePcmData', () => {
    it('应该接受有效的 PCM 数据', () => {
      const samples = new Float32Array([0, 0.5, -0.5, 1.0, -1.0]);
      expect(validatePcmData(samples)).toBe(true);
    });

    it('应该拒绝空数据', () => {
      expect(validatePcmData(new Float32Array(0))).toBe(false);
    });

    it('应该拒绝 null/undefined', () => {
      expect(validatePcmData(null as any)).toBe(false);
      expect(validatePcmData(undefined as any)).toBe(false);
    });

    it('应该拒绝超出范围的值', () => {
      const samples = new Float32Array([0, 1.5]);
      expect(validatePcmData(samples)).toBe(false);
    });

    it('应该拒绝 NaN 和 Infinity', () => {
      const samples1 = new Float32Array([0, NaN]);
      expect(validatePcmData(samples1)).toBe(false);

      const samples2 = new Float32Array([0, Infinity]);
      expect(validatePcmData(samples2)).toBe(false);
    });
  });

  describe('calculateRms', () => {
    it('应该正确计算静音的 RMS', () => {
      const samples = new Float32Array([0, 0, 0, 0]);
      expect(calculateRms(samples)).toBe(0);
    });

    it('应该正确计算非静音的 RMS', () => {
      // 正弦波的 RMS = amplitude / sqrt(2)
      const samples = generateSineWave(440, 16000, 0.1);
      const rms = calculateRms(samples);

      // 正弦波的 RMS 应该接近 1/sqrt(2) ≈ 0.707
      expect(rms).toBeGreaterThan(0.6);
      expect(rms).toBeLessThan(0.8);
    });

    it('应该返回 0 对于空数组', () => {
      expect(calculateRms(new Float32Array(0))).toBe(0);
    });
  });

  describe('isSilence', () => {
    it('应该识别静音', () => {
      const samples = new Float32Array([0, 0, 0, 0.001, -0.001]);
      expect(isSilence(samples)).toBe(true);
    });

    it('应该识别非静音', () => {
      const samples = generateSineWave(440, 16000, 0.1);
      expect(isSilence(samples)).toBe(false);
    });

    it('应该支持自定义阈值', () => {
      const samples = new Float32Array([0.1, 0.1, 0.1]);

      expect(isSilence(samples, 0.05)).toBe(false); // RMS ≈ 0.1 > 0.05
      expect(isSilence(samples, 0.5)).toBe(true); // RMS ≈ 0.1 < 0.5
    });
  });

  describe('完整流程测试', () => {
    it('录音 -> 编码 -> 解码 -> 播放 数据应该保持一致', () => {
      // 模拟录音数据（1秒的 440Hz 正弦波）
      const recordedData = generateSineWave(440, 16000, 1.0);

      // 编码为 base64（模拟发送）
      const base64Data = pcmFloat32ToBase64(recordedData);

      // 解码（模拟播放）
      const decodedData = base64ToPcmFloat32(base64Data);

      // 验证数据一致性
      expect(decodedData.length).toBe(recordedData.length);

      // 计算相关系数（应该非常接近 1）
      let sumProducts = 0;
      let sumOriginalSq = 0;
      let sumDecodedSq = 0;

      for (let i = 0; i < recordedData.length; i++) {
        sumProducts += recordedData[i] * decodedData[i];
        sumOriginalSq += recordedData[i] * recordedData[i];
        sumDecodedSq += decodedData[i] * decodedData[i];
      }

      const correlation =
        sumProducts / Math.sqrt(sumOriginalSq * sumDecodedSq);

      // 相关系数应该非常接近 1（几乎完美相关）
      expect(correlation).toBeGreaterThan(0.9999);
    });
  });
});
