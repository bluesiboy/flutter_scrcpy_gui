import 'dart:io';

class AdbService {
  final String? scrcpyPath;
  String? adbPath;

  AdbService({this.adbPath, this.scrcpyPath});

  Future<String> get _adbExecutable async {
    // 首先尝试从环境变量中查找 adb
    try {
      String command;
      List<String> args;

      if (Platform.isWindows) {
        command = 'where';
        args = ['adb'];
      } else {
        command = 'which';
        args = ['adb'];
      }

      final result = await Process.run(command, args);
      if (result.exitCode == 0 && result.stdout.toString().trim().isNotEmpty) {
        adbPath = result.stdout.toString().trim().split('\n')[0];
        return adbPath!;
      }
    } catch (_) {}

    // 如果环境变量中找不到，则使用缓存的值
    if (adbPath != null) return adbPath!;

    // 如果是 macOS，尝试查找默认路径
    if (Platform.isMacOS) {
      final path = await findAdbPath() ?? '';
      adbPath = path;
      return path;
    }
    return '';
  }

  String get _scrcpyExecutable {
    if (scrcpyPath != null) return scrcpyPath!;
    if (Platform.isWindows) return 'scrcpy.exe';
    return 'scrcpy';
  }

  Future<List<String>> getConnectedDevices() async {
    final adbPath = await _adbExecutable;
    if (!await File(adbPath).exists()) {
      throw Exception('adb 可执行文件不存在: $adbPath');
    }
    final result = await Process.run(adbPath, ['devices']);
    final lines = result.stdout.toString().split('\n');
    return lines
        .where((line) => line.trim().isNotEmpty && !line.startsWith('List'))
        .map((line) => line.split('\t')[0])
        .toList();
  }

  Future<bool> isDeviceConnected(String deviceId) async {
    try {
      final adbPath = await _adbExecutable;
      if (!await File(adbPath).exists()) {
        throw Exception('adb 可执行文件不存在: $adbPath');
      }
      final devices = await getConnectedDevices();
      return devices.contains(deviceId) == true;
    } catch (e) {
      return false;
    }
  }

  Future<void> startScrcpy(String deviceId, Map<String, dynamic> options) async {
    final scrcpyPath = options['scrcpyPath'] as String? ?? _scrcpyExecutable;
    final adbPath = await _adbExecutable;

    if (!await File(adbPath).exists()) {
      throw Exception('adb 可执行文件不存在: $adbPath');
    }
    if (!await File(scrcpyPath).exists()) {
      throw Exception('scrcpy 可执行文件不存在: $scrcpyPath');
    }

    final args = [
      '-s',
      deviceId,
    ];

    // 基本参数
    if (options['maxSize'] != null) {
      args.add('--max-size');
      args.add(options['maxSize'].toString());
    }
    if (options['bitRate'] != null && options['bitRate'] > 0) {
      args.add('--video-bit-rate');
      args.add('${options['bitRate']}M');
    }

    // 编码相关参数
    if (options['encoder'] != null && options['encoder'].toString().isNotEmpty) {
      // 根据编码器类型设置对应的编码器
      if (options['encoder'].toString().toLowerCase() == 'h265') {
        args.add('--video-codec');
        args.add('h265');
        args.add('--video-encoder');
        args.add('OMX.qcom.video.encoder.hevc'); // 优先使用硬件编码器
      } else if (options['encoder'].toString().toLowerCase() == 'h264') {
        args.add('--video-codec');
        args.add('h264');
        args.add('--video-encoder');
        args.add('OMX.qcom.video.encoder.avc'); // 优先使用硬件编码器
      }
    }
    if (options['crop'] != null && options['crop'].toString().isNotEmpty) {
      args.add('--crop');
      args.add(options['crop']);
    }
    if (options['lockVideoOrientation'] != null) {
      args.add('--lock-video-orientation');
      args.add(options['lockVideoOrientation'].toString());
    }
    if (options['maxFps'] != null) {
      args.add('--max-fps');
      args.add(options['maxFps'].toString());
    }

    // 窗口相关参数
    if (options['renderDriver'] != null && options['renderDriver'].toString().isNotEmpty) {
      args.add('--render-driver');
      args.add(options['renderDriver']);
    }
    if (options['windowTitle'] != null && options['windowTitle'].toString().isNotEmpty) {
      args.add('--window-title');
      args.add(options['windowTitle']);
    }
    if (options['windowX'] != null) {
      args.add('--window-x');
      args.add(options['windowX'].toString());
    }
    if (options['windowY'] != null) {
      args.add('--window-y');
      args.add(options['windowY'].toString());
    }
    if (options['windowWidth'] != null) {
      args.add('--window-width');
      args.add(options['windowWidth'].toString());
    }
    if (options['windowHeight'] != null) {
      args.add('--window-height');
      args.add(options['windowHeight'].toString());
    }

    // 控制相关参数
    if (options['keyRepeat'] != null) {
      args.add('--key-repeat');
      args.add(options['keyRepeat'].toString());
    }
    if (options['keyRepeatDelay'] != null) {
      args.add('--key-repeat-delay');
      args.add(options['keyRepeatDelay'].toString());
    }
    if (options['shortcutMod'] != null && options['shortcutMod'].toString().isNotEmpty) {
      args.add('--shortcut-mod');
      args.add(options['shortcutMod']);
    }

    // 录制相关参数
    if (options['record'] != null && options['record'].toString().isNotEmpty) {
      args.add('--record');
      args.add(options['record']);
    }
    if (options['recordFormat'] != null && options['recordFormat'].toString().isNotEmpty) {
      args.add('--record-format');
      args.add(options['recordFormat']);
    }

    // 开关参数
    if (options['stayAwake'] == true) args.add('--stay-awake');
    if (options['turnScreenOff'] == true) args.add('--turn-screen-off');
    if (options['showTouches'] == true) args.add('--show-touches');
    if (options['fullscreen'] == true) args.add('--fullscreen');
    if (options['alwaysOnTop'] == true) args.add('--always-on-top');
    if (options['disableScreensaver'] == true) args.add('--disable-screensaver');
    if (options['noAudio'] == true) args.add('--no-audio');
    if (options['noVideo'] == true) args.add('--no-video');
    if (options['noControl'] == true) args.add('--no-control');
    if (options['noDisplay'] == true) args.add('--no-display');

    try {
      print('执行命令: $scrcpyPath ${args.join(' ')}');
      var result = await Process.run(scrcpyPath, args);
      if (result.exitCode != 0) {
        throw Exception('scrcpy 执行失败: ${result.stderr}');
      }
    } catch (e) {
      var es = e.toString();
      if (es.contains('for h265 not found')) {
        // 找到编码器参数的位置
        final encoderIndex = args.indexOf('--video-encoder');
        if (encoderIndex != -1) {
          // 移除当前编码器参数
          args.removeAt(encoderIndex + 1); // 移除编码器名称
          args.removeAt(encoderIndex); // 移除 --video-encoder
          // 添加 MTK 编码器
          args.add('--video-encoder');
          // args.add('OMX.MTK.VIDEO.ENCODER.HEVC');
          args.add('c2.mtk.hevc.encoder');
          // 重试执行命令
          print('重试命令: $scrcpyPath ${args.join(' ')}');
          final retryResult = await Process.run(scrcpyPath, args);
          if (retryResult.exitCode != 0) {
            throw Exception('scrcpy 执行失败: ${retryResult.stderr}');
          }
        } else {
          throw Exception('启动 scrcpy 失败: $e');
        }
      } else if (es.contains('for h264 not found')) {
        // 找到编码器参数的位置
        final encoderIndex = args.indexOf('--video-encoder');
        if (encoderIndex != -1) {
          // 移除当前编码器参数
          args.removeAt(encoderIndex + 1); // 移除编码器名称
          args.removeAt(encoderIndex); // 移除 --video-encoder
          // 添加 MTK 编码器
          args.add('--video-encoder');
          args.add('OMX.MTK.VIDEO.ENCODER.AVC');
          // 重试执行命令
          print('重试命令: $scrcpyPath ${args.join(' ')}');
          final retryResult = await Process.run(scrcpyPath, args);
          if (retryResult.exitCode != 0) {
            throw Exception('scrcpy 执行失败: ${retryResult.stderr}');
          }
        } else {
          throw Exception('启动 scrcpy 失败: $e');
        }
      } else {
        throw Exception('启动 scrcpy 失败: $e');
      }
    }
  }

  Future<String> getDeviceName(String deviceId) async {
    try {
      final adbPath = await _adbExecutable;
      if (!await File(adbPath).exists()) {
        throw Exception('adb 可执行文件不存在: $adbPath');
      }
      final result = await Process.run(adbPath, ['-s', deviceId, 'shell', 'getprop', 'ro.product.model']);
      if (result.exitCode == 0 && result.stdout.toString().trim().isNotEmpty) {
        return result.stdout.toString().trim();
      }
      return deviceId;
    } catch (e) {
      return deviceId;
    }
  }

  /// 返回第一个找到的 adb 路径
  Future<String?> findAdbPath() async {
    final candidates = [
      '${Platform.environment['HOME']}/Library/Android/sdk/platform-tools/adb',
      '/usr/local/bin/adb',
      '/opt/homebrew/bin/adb',
      if (Platform.environment['ANDROID_HOME'] != null) '${Platform.environment['ANDROID_HOME']}/platform-tools/adb',
      if (Platform.environment['ANDROID_SDK_ROOT'] != null)
        '${Platform.environment['ANDROID_SDK_ROOT']}/platform-tools/adb',
    ];

    for (var path in candidates) {
      final file = File(path);
      if (await file.exists()) {
        return file.path;
      }
    }

    // 尝试使用 which 查找 adb
    try {
      final result = await Process.run('which', ['adb']);
      if (result.exitCode == 0) {
        return (result.stdout as String).trim();
      }
    } catch (_) {}

    return null; // 未找到
  }
}
