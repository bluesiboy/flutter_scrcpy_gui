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
  final String? recordDirectory;
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
    this.recordDirectory,
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
      'recordDirectory': recordDirectory,
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
      recordDirectory: json['recordDirectory'] as String?,
      recordFormat: json['recordFormat'] as String?,
    );
  }

  DeviceConfig copyWith({
    String? deviceId,
    Object? adbPath = const Object(),
    Object? scrcpyPath = const Object(),
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
    Object? encoder = const Object(),
    Object? crop = const Object(),
    Object? lockVideoOrientation = const Object(),
    Object? maxFps = const Object(),
    Object? renderDriver = const Object(),
    Object? windowTitle = const Object(),
    Object? windowX = const Object(),
    Object? windowY = const Object(),
    Object? windowWidth = const Object(),
    Object? windowHeight = const Object(),
    Object? keyRepeat = const Object(),
    Object? keyRepeatDelay = const Object(),
    Object? shortcutMod = const Object(),
    Object? record = const Object(),
    Object? recordDirectory = const Object(),
    Object? recordFormat = const Object(),
  }) {
    return DeviceConfig(
      deviceId: deviceId ?? this.deviceId,
      adbPath: adbPath == const Object() ? this.adbPath : adbPath as String?,
      scrcpyPath: scrcpyPath == const Object() ? this.scrcpyPath : scrcpyPath as String?,
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
      encoder: encoder == const Object() ? this.encoder : encoder as String?,
      crop: crop == const Object() ? this.crop : crop as String?,
      lockVideoOrientation:
          lockVideoOrientation == const Object() ? this.lockVideoOrientation : lockVideoOrientation as int?,
      maxFps: maxFps == const Object() ? this.maxFps : maxFps as int?,
      renderDriver: renderDriver == const Object() ? this.renderDriver : renderDriver as String?,
      windowTitle: windowTitle == const Object() ? this.windowTitle : windowTitle as String?,
      windowX: windowX == const Object() ? this.windowX : windowX as int?,
      windowY: windowY == const Object() ? this.windowY : windowY as int?,
      windowWidth: windowWidth == const Object() ? this.windowWidth : windowWidth as int?,
      windowHeight: windowHeight == const Object() ? this.windowHeight : windowHeight as int?,
      keyRepeat: keyRepeat == const Object() ? this.keyRepeat : keyRepeat as int?,
      keyRepeatDelay: keyRepeatDelay == const Object() ? this.keyRepeatDelay : keyRepeatDelay as int?,
      shortcutMod: shortcutMod == const Object() ? this.shortcutMod : shortcutMod as String?,
      record: record == const Object() ? this.record : record as String?,
      recordDirectory: recordDirectory == const Object() ? this.recordDirectory : recordDirectory as String?,
      recordFormat: recordFormat == const Object() ? this.recordFormat : recordFormat as String?,
    );
  }
}
