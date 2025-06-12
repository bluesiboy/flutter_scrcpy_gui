import 'dart:io';

class AdbService {
  final String? adbPath;
  final String? scrcpyPath;

  AdbService({this.adbPath, this.scrcpyPath});

  String get _adbExecutable {
    if (adbPath != null) return adbPath!;
    if (Platform.isWindows) return 'adb.exe';
    return 'adb';
  }

  String get _scrcpyExecutable {
    if (scrcpyPath != null) return scrcpyPath!;
    if (Platform.isWindows) return 'scrcpy.exe';
    return 'scrcpy';
  }

  Future<List<String>> getConnectedDevices() async {
    try {
      final result = await Process.run(_adbExecutable, ['devices']);
      final lines = result.stdout.toString().split('\n');
      return lines
          .where((line) => line.trim().isNotEmpty && !line.startsWith('List'))
          .map((line) => line.split('\t')[0])
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> isDeviceConnected(String deviceId) async {
    final devices = await getConnectedDevices();
    return devices.contains(deviceId);
  }

  Future<void> startScrcpy(String deviceId, Map<String, dynamic> options) async {
    final scrcpyPath = options['scrcpyPath'] as String? ?? _scrcpyExecutable;

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
      final result = await Process.run(_adbExecutable, ['-s', deviceId, 'shell', 'getprop', 'ro.product.model']);
      if (result.exitCode == 0 && result.stdout.toString().trim().isNotEmpty) {
        return result.stdout.toString().trim();
      }
      return deviceId;
    } catch (e) {
      return deviceId;
    }
  }
}
