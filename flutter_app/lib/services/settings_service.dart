import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 应用设置服务
/// 使用 SharedPreferences 持久化存储配置
class SettingsService extends ChangeNotifier {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  // ==================== 配置键名 ====================
  static const String _keyDarkMode = 'dark_mode';
  static const String _keyThemeColor = 'theme_color';
  static const String _keyFontSize = 'font_size';
  static const String _keyAiSensitivity = 'ai_sensitivity';
  static const String _keyNotificationFrequency = 'notification_frequency';
  static const String _keyUserName = 'user_name';

  // ==================== 默认值 ====================
  static const bool _defaultDarkMode = false;
  static const String _defaultThemeColor = 'Sage & Slate';
  static const String _defaultFontSize = 'medium';
  static const String _defaultAiSensitivity = 'medium';
  static const String _defaultNotificationFrequency = 'important';
  static const String _defaultUserName = '林之境';

  // ==================== 当前值 ====================
  bool _darkMode = _defaultDarkMode;
  String _themeColor = _defaultThemeColor;
  String _fontSize = _defaultFontSize;
  String _aiSensitivity = _defaultAiSensitivity;
  String _notificationFrequency = _defaultNotificationFrequency;
  String _userName = _defaultUserName;
  bool _initialized = false;

  // ==================== Getters ====================
  bool get darkMode => _darkMode;
  String get themeColor => _themeColor;
  String get fontSize => _fontSize;
  String get aiSensitivity => _aiSensitivity;
  String get notificationFrequency => _notificationFrequency;
  String get userName => _userName;
  bool get isInitialized => _initialized;

  // ==================== 初始化 ====================
  Future<void> init() async {
    if (_initialized) return;

    final prefs = await SharedPreferences.getInstance();
    _darkMode = prefs.getBool(_keyDarkMode) ?? _defaultDarkMode;
    _themeColor = prefs.getString(_keyThemeColor) ?? _defaultThemeColor;
    _fontSize = prefs.getString(_keyFontSize) ?? _defaultFontSize;
    _aiSensitivity = prefs.getString(_keyAiSensitivity) ?? _defaultAiSensitivity;
    _notificationFrequency = prefs.getString(_keyNotificationFrequency) ?? _defaultNotificationFrequency;
    _userName = prefs.getString(_keyUserName) ?? _defaultUserName;
    _initialized = true;
    notifyListeners();
  }

  // ==================== 保存方法 ====================
  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  // ==================== 设置方法 ====================

  /// 设置暗色模式
  Future<void> setDarkMode(bool value) async {
    if (_darkMode == value) return;
    _darkMode = value;
    await _saveBool(_keyDarkMode, value);
    notifyListeners();
  }

  /// 设置主题颜色
  Future<void> setThemeColor(String value) async {
    if (_themeColor == value) return;
    _themeColor = value;
    await _saveString(_keyThemeColor, value);
    notifyListeners();
  }

  /// 设置字体大小
  Future<void> setFontSize(String value) async {
    if (_fontSize == value) return;
    _fontSize = value;
    await _saveString(_keyFontSize, value);
    notifyListeners();
  }

  /// 设置 AI 助手灵敏度
  Future<void> setAiSensitivity(String value) async {
    if (_aiSensitivity == value) return;
    _aiSensitivity = value;
    await _saveString(_keyAiSensitivity, value);
    notifyListeners();
  }

  /// 设置通知频率
  Future<void> setNotificationFrequency(String value) async {
    if (_notificationFrequency == value) return;
    _notificationFrequency = value;
    await _saveString(_keyNotificationFrequency, value);
    notifyListeners();
  }

  /// 设置用户名
  Future<void> setUserName(String value) async {
    if (_userName == value) return;
    _userName = value;
    await _saveString(_keyUserName, value);
    notifyListeners();
  }

  // ==================== 选项列表 ====================

  /// 主题颜色选项
  static const List<String> themeColorOptions = [
    'Sage & Slate',
    'Ocean Blue',
    'Sunset Orange',
    'Forest Green',
    'Royal Purple',
  ];

  /// 主题颜色对应的色值
  static const Map<String, Color> themeColorMap = {
    'Sage & Slate': Color(0xFF9DC695),
    'Ocean Blue': Color(0xFF5B8CB9),
    'Sunset Orange': Color(0xFFE8985E),
    'Forest Green': Color(0xFF4A7C59),
    'Royal Purple': Color(0xFF7B68A8),
  };

  /// 字体大小选项
  static const List<String> fontSizeOptions = [
    'small',
    'medium',
    'large',
  ];

  /// 字体大小显示名称
  static const Map<String, String> fontSizeDisplayNames = {
    'small': '小',
    'medium': '中',
    'large': '大',
  };

  /// AI 灵敏度选项
  static const List<String> aiSensitivityOptions = [
    'low',
    'medium',
    'high',
  ];

  /// AI 灵敏度显示名称
  static const Map<String, String> aiSensitivityDisplayNames = {
    'low': '保守',
    'medium': '沉浸式',
    'high': '积极',
  };

  /// 通知频率选项
  static const List<String> notificationFrequencyOptions = [
    'all',
    'important',
    'none',
  ];

  /// 通知频率显示名称
  static const Map<String, String> notificationFrequencyDisplayNames = {
    'all': '全部',
    'important': '仅重要事项',
    'none': '关闭',
  };

  // ==================== 重置 ====================
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _darkMode = _defaultDarkMode;
    _themeColor = _defaultThemeColor;
    _fontSize = _defaultFontSize;
    _aiSensitivity = _defaultAiSensitivity;
    _notificationFrequency = _defaultNotificationFrequency;
    _userName = _defaultUserName;
    notifyListeners();
  }
}
