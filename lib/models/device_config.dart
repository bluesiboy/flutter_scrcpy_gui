class DeviceConfig {
  final String deviceId;
  final String? adbPath;
  final String? scrcpyPath;
  final int maxSize;
  final int bitRate;
  final bool stayAwake;
  final bool turnScreenOff;
  final bool showTouches;
  final bool fullscreen;
  final bool alwaysOnTop;
  final bool disableScreensaver;
  final bool noAudio;
  final bool noVideo;
  final bool noControl;
  final bool noDisplay;
  final String? encoder;
  final String? crop;
  final int? lockVideoOrientation;
  final int? maxFps;
  final String? renderDriver;
  final String? windowTitle;
  final int? windowX;
  final int? windowY;
  final int? windowWidth;
  final int? windowHeight;
  final int? keyRepeat;
  final int? keyRepeatDelay;
  final String? shortcutMod;
  final String? record;
  final String? recordFormat;

  DeviceConfig({
    required this.deviceId,
    this.adbPath,
    this.scrcpyPath,
    this.maxSize = 1920,
    this.bitRate = 0,
    this.stayAwake = false,
    this.turnScreenOff = false,
    this.showTouches = false,
    this.fullscreen = false,
    this.alwaysOnTop = false,
    this.disableScreensaver = false,
    this.noAudio = false,
    this.noVideo = false,
    this.noControl = false,
    this.noDisplay = false,
    this.encoder,
    this.crop,
    this.lockVideoOrientation,
    this.maxFps,
    this.renderDriver,
    this.windowTitle,
    this.windowX,
    this.windowY,
    this.windowWidth,
    this.windowHeight,
    this.keyRepeat,
    this.keyRepeatDelay,
    this.shortcutMod,
    this.record,
    this.recordFormat,
  });

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'adbPath': adbPath,
      'scrcpyPath': scrcpyPath,
      'maxSize': maxSize,
      'bitRate': bitRate,
      'stayAwake': stayAwake,
      'turnScreenOff': turnScreenOff,
      'showTouches': showTouches,
      'fullscreen': fullscreen,
      'alwaysOnTop': alwaysOnTop,
      'disableScreensaver': disableScreensaver,
      'noAudio': noAudio,
      'noVideo': noVideo,
      'noControl': noControl,
      'noDisplay': noDisplay,
      'encoder': encoder,
      'crop': crop,
      'lockVideoOrientation': lockVideoOrientation,
      'maxFps': maxFps,
      'renderDriver': renderDriver,
      'windowTitle': windowTitle,
      'windowX': windowX,
      'windowY': windowY,
      'windowWidth': windowWidth,
      'windowHeight': windowHeight,
      'keyRepeat': keyRepeat,
      'keyRepeatDelay': keyRepeatDelay,
      'shortcutMod': shortcutMod,
      'record': record,
      'recordFormat': recordFormat,
    };
  }

  factory DeviceConfig.fromJson(Map<String, dynamic> json) {
    return DeviceConfig(
      deviceId: json['deviceId'] as String,
      adbPath: json['adbPath'] as String?,
      scrcpyPath: json['scrcpyPath'] as String?,
      maxSize: json['maxSize'] as int? ?? 1920,
      bitRate: json['bitRate'] as int? ?? 0,
      stayAwake: json['stayAwake'] as bool? ?? false,
      turnScreenOff: json['turnScreenOff'] as bool? ?? false,
      showTouches: json['showTouches'] as bool? ?? false,
      fullscreen: json['fullscreen'] as bool? ?? false,
      alwaysOnTop: json['alwaysOnTop'] as bool? ?? false,
      disableScreensaver: json['disableScreensaver'] as bool? ?? false,
      noAudio: json['noAudio'] as bool? ?? false,
      noVideo: json['noVideo'] as bool? ?? false,
      noControl: json['noControl'] as bool? ?? false,
      noDisplay: json['noDisplay'] as bool? ?? false,
      encoder: json['encoder'] as String?,
      crop: json['crop'] as String?,
      lockVideoOrientation: json['lockVideoOrientation'] as int?,
      maxFps: json['maxFps'] as int?,
      renderDriver: json['renderDriver'] as String?,
      windowTitle: json['windowTitle'] as String?,
      windowX: json['windowX'] as int?,
      windowY: json['windowY'] as int?,
      windowWidth: json['windowWidth'] as int?,
      windowHeight: json['windowHeight'] as int?,
      keyRepeat: json['keyRepeat'] as int?,
      keyRepeatDelay: json['keyRepeatDelay'] as int?,
      shortcutMod: json['shortcutMod'] as String?,
      record: json['record'] as String?,
      recordFormat: json['recordFormat'] as String?,
    );
  }

  DeviceConfig copyWith({
    String? deviceId,
    String? adbPath,
    String? scrcpyPath,
    int? maxSize,
    int? bitRate,
    bool? stayAwake,
    bool? turnScreenOff,
    bool? showTouches,
    bool? fullscreen,
    bool? alwaysOnTop,
    bool? disableScreensaver,
    bool? noAudio,
    bool? noVideo,
    bool? noControl,
    bool? noDisplay,
    String? encoder,
    String? crop,
    int? lockVideoOrientation,
    int? maxFps,
    String? renderDriver,
    String? windowTitle,
    int? windowX,
    int? windowY,
    int? windowWidth,
    int? windowHeight,
    int? keyRepeat,
    int? keyRepeatDelay,
    String? shortcutMod,
    String? record,
    String? recordFormat,
  }) {
    return DeviceConfig(
      deviceId: deviceId ?? this.deviceId,
      adbPath: adbPath ?? this.adbPath,
      scrcpyPath: scrcpyPath ?? this.scrcpyPath,
      maxSize: maxSize ?? this.maxSize,
      bitRate: bitRate ?? this.bitRate,
      stayAwake: stayAwake ?? this.stayAwake,
      turnScreenOff: turnScreenOff ?? this.turnScreenOff,
      showTouches: showTouches ?? this.showTouches,
      fullscreen: fullscreen ?? this.fullscreen,
      alwaysOnTop: alwaysOnTop ?? this.alwaysOnTop,
      disableScreensaver: disableScreensaver ?? this.disableScreensaver,
      noAudio: noAudio ?? this.noAudio,
      noVideo: noVideo ?? this.noVideo,
      noControl: noControl ?? this.noControl,
      noDisplay: noDisplay ?? this.noDisplay,
      encoder: encoder ?? this.encoder,
      crop: crop ?? this.crop,
      lockVideoOrientation: lockVideoOrientation ?? this.lockVideoOrientation,
      maxFps: maxFps ?? this.maxFps,
      renderDriver: renderDriver ?? this.renderDriver,
      windowTitle: windowTitle ?? this.windowTitle,
      windowX: windowX ?? this.windowX,
      windowY: windowY ?? this.windowY,
      windowWidth: windowWidth ?? this.windowWidth,
      windowHeight: windowHeight ?? this.windowHeight,
      keyRepeat: keyRepeat ?? this.keyRepeat,
      keyRepeatDelay: keyRepeatDelay ?? this.keyRepeatDelay,
      shortcutMod: shortcutMod ?? this.shortcutMod,
      record: record ?? this.record,
      recordFormat: recordFormat ?? this.recordFormat,
    );
  }
}
