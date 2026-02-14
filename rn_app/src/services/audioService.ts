/**
 * 音频服务模块
 *
 * 使用 react-native-nitro-sound 实现录音和播放功能
 * 保留 react-native-audio-api 的实现作为备份（等稳定后删除）
 */

import { Platform, PermissionsAndroid, Alert, Linking } from 'react-native';
import Sound, {
  AudioSet,
  RecordBackType,
  PlayBackType,
  PlaybackEndType,
} from 'react-native-nitro-sound';

// ============== Nitro Sound 实现 (当前使用) ==============

/**
 * 请求录音权限
 */
export async function requestRecordingPermission(): Promise<boolean> {
  if (Platform.OS === 'android') {
    try {
      const granted = await PermissionsAndroid.request(
        PermissionsAndroid.PERMISSIONS.RECORD_AUDIO,
        {
          title: '麦克风权限',
          message: '需要麦克风权限才能录制语音消息',
          buttonNeutral: '稍后询问',
          buttonNegative: '取消',
          buttonPositive: '确定',
        }
      );
      return granted === PermissionsAndroid.RESULTS.GRANTED;
    } catch (err) {
      console.error('Permission request error:', err);
      return false;
    }
  }
  // iOS 权限由系统自动处理
  return true;
}

/**
 * 检查并请求录音权限，如果被拒绝则显示提示
 */
export async function ensureRecordingPermission(): Promise<boolean> {
  const granted = await requestRecordingPermission();
  if (!granted) {
    Alert.alert(
      '需要麦克风权限',
      '请在系统设置中开启麦克风权限以使用语音消息功能。',
      [
        { text: '取消', style: 'cancel' },
        { text: '去设置', onPress: () => Linking.openSettings() },
      ]
    );
    return false;
  }
  return true;
}

/**
 * 录音配置 - 高质量语音
 */
const getRecordingConfig = (): AudioSet => ({
  AudioSamplingRate: 16000,
  AudioEncodingBitRate: 64000,
  AudioChannels: 1,
});

/**
 * 开始录音
 * @returns 录音文件路径
 */
export async function startRecording(): Promise<string | null> {
  try {
    const uri = await Sound.startRecorder(
      undefined, // 使用默认路径
      getRecordingConfig(),
      true // 启用音量表计，用于显示波形
    );
    console.log('[NitroSound] Recording started:', uri);
    return uri;
  } catch (error) {
    console.error('[NitroSound] Start recording error:', error);
    return null;
  }
}

/**
 * 停止录音
 * @returns 录音文件路径
 */
export async function stopRecording(): Promise<string | null> {
  try {
    const uri = await Sound.stopRecorder();
    console.log('[NitroSound] Recording stopped:', uri);
    return uri;
  } catch (error) {
    console.error('[NitroSound] Stop recording error:', error);
    return null;
  }
}

/**
 * 添加录音进度监听
 */
export function addRecordingListener(
  callback: (event: RecordBackType) => void
): void {
  Sound.addRecordBackListener(callback);
}

/**
 * 移除录音进度监听
 */
export function removeRecordingListener(): void {
  Sound.removeRecordBackListener();
}

/**
 * 开始播放
 */
export async function startPlayback(
  uri: string,
  onProgress?: (position: number, duration: number) => void,
  onEnd?: () => void
): Promise<string | null> {
  try {
    const result = await Sound.startPlayer(uri);
    console.log('[NitroSound] Playback started:', result);

    if (onProgress) {
      Sound.addPlayBackListener((e: PlayBackType) => {
        onProgress(e.currentPosition, e.duration);
      });
    }

    if (onEnd) {
      Sound.addPlaybackEndListener(() => {
        onEnd();
        Sound.removePlayBackListener();
        Sound.removePlaybackEndListener();
      });
    }

    return result;
  } catch (error) {
    console.error('[NitroSound] Start playback error:', error);
    return null;
  }
}

/**
 * 停止播放
 */
export async function stopPlayback(): Promise<string | null> {
  try {
    const result = await Sound.stopPlayer();
    Sound.removePlayBackListener();
    Sound.removePlaybackEndListener();
    return result;
  } catch (error) {
    console.error('[NitroSound] Stop playback error:', error);
    return null;
  }
}

/**
 * 暂停播放
 */
export async function pausePlayback(): Promise<string | null> {
  try {
    return await Sound.pausePlayer();
  } catch (error) {
    console.error('[NitroSound] Pause playback error:', error);
    return null;
  }
}

/**
 * 恢复播放
 */
export async function resumePlayback(): Promise<string | null> {
  try {
    return await Sound.resumePlayer();
  } catch (error) {
    console.error('[NitroSound] Resume playback error:', error);
    return null;
  }
}

/**
 * 格式化时间 (mm:ss)
 */
export function formatTime(seconds: number): string {
  return Sound.mmss(Math.floor(seconds));
}

/**
 * 格式化时间 (mm:ss:ms)
 */
export function formatTimeMs(seconds: number): string {
  return Sound.mmssss(Math.floor(seconds));
}

// ============== 旧的 react-native-audio-api 实现 (备份，等稳定后删除) ==============

/*
 * 注意：以下是使用 react-native-audio-api 的旧实现
 * 保留作为参考，等该库稳定后可以切换回来
 *
 * 问题：录音播放时出现杂音，可能是 PCM 编码/解码问题
 * 相关 GitHub Issue: https://github.com/software-mansion/react-native-audio-api/issues/809
 */

// 延迟加载 react-native-audio-api（避免在 JSI 未就绪时触发模块初始化）
let _audioApi: any = null;
function getAudioApi() {
  if (!_audioApi) {
    _audioApi = require('react-native-audio-api');
  }
  return _audioApi;
}

// 延迟初始化录音器
let _recorder: any = null;
function getRecorder() {
  if (!_recorder) {
    const { AudioRecorder, AudioManager } = getAudioApi();
    AudioManager.setAudioSessionOptions({
      iosCategory: 'playAndRecord',
      iosMode: 'default',
      iosOptions: [],
    });
    _recorder = new AudioRecorder({
      sampleRate: 16000,
      bufferLengthInSamples: 4096,
    });
  }
  return _recorder;
}

// 获取 AudioManager（延迟加载）
function getAudioManager() {
  return getAudioApi().AudioManager;
}

export {
  // 导出旧实现的引用，以便在需要时使用
  getAudioApi as _getAudioApi,
  getRecorder as _getRecorder,
  getAudioManager as _getAudioManager,
};

// ============== 类型导出 ==============

export type { RecordBackType, PlayBackType, PlaybackEndType };
