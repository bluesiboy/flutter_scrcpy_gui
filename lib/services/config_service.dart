import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_scrcpy_gui/models/device_config.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';

class ConfigService {
  static const String _configPrefix = 'device_config_';
  static const String _compactModeKey = 'compact_mode';
  static const String _windowWidthKey = 'window_width';
  static const String _windowHeightKey = 'window_height';
  static const String _windowLeftKey = 'window_left';
  static const String _windowTopKey = 'window_top';
  static const String _themeModeKey = 'theme_mode';
  static const String _adbPathKey = 'adb_path';
  static const String _scrcpyPathKey = 'scrcpy_path';
  final SharedPreferences _prefs;

  ConfigService(this._prefs);

  Future<void> saveDeviceConfig(DeviceConfig config) async {
    final json = config.toJson();
    await _prefs.setString('${_configPrefix}${config.deviceId}', jsonEncode(json));
  }

  DeviceConfig? getDeviceConfig(String deviceId) {
    final jsonStr = _prefs.getString('${_configPrefix}$deviceId');
    if (jsonStr == null) return null;
    return DeviceConfig.fromJson(jsonDecode(jsonStr));
  }

  Future<void> deleteDeviceConfig(String deviceId) async {
    await _prefs.remove('${_configPrefix}$deviceId');
  }

  List<String> getAllDeviceIds() {
    return _prefs
        .getKeys()
        .where((key) => key.startsWith(_configPrefix))
        .map((key) => key.substring(_configPrefix.length))
        .toList();
  }

  // 保存显示模式
  Future<void> saveCompactMode(bool isCompact) async {
    await _prefs.setBool(_compactModeKey, isCompact);
  }

  // 获取显示模式
  bool getCompactMode() {
    return _prefs.getBool(_compactModeKey) ?? false;
  }

  // 保存窗口大小
  Future<void> saveWindowSize(Size size) async {
    await _prefs.setDouble(_windowWidthKey, size.width);
    await _prefs.setDouble(_windowHeightKey, size.height);
  }

  // 获取保存的窗口大小
  Size getWindowSize() {
    final width = _prefs.getDouble(_windowWidthKey) ?? 460.0;
    final height = _prefs.getDouble(_windowHeightKey) ?? 700.0;
    return Size(width, height);
  }

  // 保存窗口位置
  Future<void> saveWindowPosition(Offset position) async {
    await _prefs.setDouble(_windowLeftKey, position.dx);
    await _prefs.setDouble(_windowTopKey, position.dy);
  }

  // 获取保存的窗口位置
  Offset getWindowPosition() {
    final left = _prefs.getDouble(_windowLeftKey);
    final top = _prefs.getDouble(_windowTopKey);
    return Offset(left ?? 0, top ?? 0);
  }

  // 保存主题模式
  Future<void> saveThemeMode(ThemeMode mode) async {
    await _prefs.setInt(_themeModeKey, mode.index);
  }

  // 获取主题模式
  ThemeMode getThemeMode() {
    final index = _prefs.getInt(_themeModeKey);
    return index != null ? ThemeMode.values[index] : ThemeMode.system;
  }

  // 保存 ADB 路径
  Future<void> saveAdbPath(String path) async {
    await _prefs.setString(_adbPathKey, path);
  }

  // 获取 ADB 路径
  String? getAdbPath() {
    return _prefs.getString(_adbPathKey);
  }

  // 保存 Scrcpy 路径
  Future<void> saveScrcpyPath(String path) async {
    await _prefs.setString(_scrcpyPathKey, path);
  }

  // 获取 Scrcpy 路径
  String? getScrcpyPath() {
    return _prefs.getString(_scrcpyPathKey);
  }
}
