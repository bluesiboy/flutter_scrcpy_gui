// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DeviceConfigImpl _$$DeviceConfigImplFromJson(Map<String, dynamic> json) =>
    _$DeviceConfigImpl(
      deviceId: json['deviceId'] as String,
      adbPath: json['adbPath'] as String?,
      scrcpyPath: json['scrcpyPath'] as String?,
      maxSize: (json['maxSize'] as num?)?.toInt() ?? 1920,
      bitRate: (json['bitRate'] as num?)?.toInt() ?? 0,
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
      lockVideoOrientation: (json['lockVideoOrientation'] as num?)?.toInt(),
      maxFps: (json['maxFps'] as num?)?.toInt(),
      renderDriver: json['renderDriver'] as String?,
      windowTitle: json['windowTitle'] as String?,
      windowX: (json['windowX'] as num?)?.toInt(),
      windowY: (json['windowY'] as num?)?.toInt(),
      windowWidth: (json['windowWidth'] as num?)?.toInt(),
      windowHeight: (json['windowHeight'] as num?)?.toInt(),
      keyRepeat: (json['keyRepeat'] as num?)?.toInt(),
      keyRepeatDelay: (json['keyRepeatDelay'] as num?)?.toInt(),
      shortcutMod: json['shortcutMod'] as String?,
      record: json['record'] as String?,
      recordFormat: json['recordFormat'] as String?,
      noPowerOn: json['noPowerOn'] as bool? ?? false,
      noPowerOff: json['noPowerOff'] as bool? ?? false,
      noPowerOffOnClose: json['noPowerOffOnClose'] as bool? ?? false,
      noPowerOffOnDisconnect: json['noPowerOffOnDisconnect'] as bool? ?? false,
      noPowerOffOnError: json['noPowerOffOnError'] as bool? ?? false,
      noPowerOffOnExit: json['noPowerOffOnExit'] as bool? ?? false,
      noPowerOffOnStop: json['noPowerOffOnStop'] as bool? ?? false,
      noPowerOffOnSuspend: json['noPowerOffOnSuspend'] as bool? ?? false,
      noPowerOffOnResume: json['noPowerOffOnResume'] as bool? ?? false,
      noPowerOffOnLock: json['noPowerOffOnLock'] as bool? ?? false,
      noPowerOffOnUnlock: json['noPowerOffOnUnlock'] as bool? ?? false,
      noPowerOffOnScreenOff: json['noPowerOffOnScreenOff'] as bool? ?? false,
      noPowerOffOnScreenOn: json['noPowerOffOnScreenOn'] as bool? ?? false,
      noPowerOffOnBatteryLow: json['noPowerOffOnBatteryLow'] as bool? ?? false,
      noPowerOffOnBatteryCritical:
          json['noPowerOffOnBatteryCritical'] as bool? ?? false,
      noPowerOffOnBatteryFull:
          json['noPowerOffOnBatteryFull'] as bool? ?? false,
      noPowerOffOnBatteryCharging:
          json['noPowerOffOnBatteryCharging'] as bool? ?? false,
      noPowerOffOnBatteryDischarging:
          json['noPowerOffOnBatteryDischarging'] as bool? ?? false,
      noPowerOffOnBatteryNotCharging:
          json['noPowerOffOnBatteryNotCharging'] as bool? ?? false,
      noPowerOffOnBatteryUnknown:
          json['noPowerOffOnBatteryUnknown'] as bool? ?? false,
      noPowerOffOnBatteryNotPresent:
          json['noPowerOffOnBatteryNotPresent'] as bool? ?? false,
      noPowerOffOnBatteryPresent:
          json['noPowerOffOnBatteryPresent'] as bool? ?? false,
      noPowerOffOnBatteryChargingAC:
          json['noPowerOffOnBatteryChargingAC'] as bool? ?? false,
      noPowerOffOnBatteryChargingUSB:
          json['noPowerOffOnBatteryChargingUSB'] as bool? ?? false,
      noPowerOffOnBatteryChargingWireless:
          json['noPowerOffOnBatteryChargingWireless'] as bool? ?? false,
      noPowerOffOnBatteryChargingUnknown:
          json['noPowerOffOnBatteryChargingUnknown'] as bool? ?? false,
      noPowerOffOnBatteryChargingNotCharging:
          json['noPowerOffOnBatteryChargingNotCharging'] as bool? ?? false,
      noPowerOffOnBatteryChargingDischarging:
          json['noPowerOffOnBatteryChargingDischarging'] as bool? ?? false,
      noPowerOffOnBatteryChargingFull:
          json['noPowerOffOnBatteryChargingFull'] as bool? ?? false,
      noPowerOffOnBatteryChargingLow:
          json['noPowerOffOnBatteryChargingLow'] as bool? ?? false,
      noPowerOffOnBatteryChargingCritical:
          json['noPowerOffOnBatteryChargingCritical'] as bool? ?? false,
      noPowerOffOnBatteryChargingNotPresent:
          json['noPowerOffOnBatteryChargingNotPresent'] as bool? ?? false,
      noPowerOffOnBatteryChargingPresent:
          json['noPowerOffOnBatteryChargingPresent'] as bool? ?? false,
    );

Map<String, dynamic> _$$DeviceConfigImplToJson(_$DeviceConfigImpl instance) =>
    <String, dynamic>{
      'deviceId': instance.deviceId,
      'adbPath': instance.adbPath,
      'scrcpyPath': instance.scrcpyPath,
      'maxSize': instance.maxSize,
      'bitRate': instance.bitRate,
      'stayAwake': instance.stayAwake,
      'turnScreenOff': instance.turnScreenOff,
      'showTouches': instance.showTouches,
      'fullscreen': instance.fullscreen,
      'alwaysOnTop': instance.alwaysOnTop,
      'disableScreensaver': instance.disableScreensaver,
      'noAudio': instance.noAudio,
      'noVideo': instance.noVideo,
      'noControl': instance.noControl,
      'noDisplay': instance.noDisplay,
      'encoder': instance.encoder,
      'crop': instance.crop,
      'lockVideoOrientation': instance.lockVideoOrientation,
      'maxFps': instance.maxFps,
      'renderDriver': instance.renderDriver,
      'windowTitle': instance.windowTitle,
      'windowX': instance.windowX,
      'windowY': instance.windowY,
      'windowWidth': instance.windowWidth,
      'windowHeight': instance.windowHeight,
      'keyRepeat': instance.keyRepeat,
      'keyRepeatDelay': instance.keyRepeatDelay,
      'shortcutMod': instance.shortcutMod,
      'record': instance.record,
      'recordFormat': instance.recordFormat,
      'noPowerOn': instance.noPowerOn,
      'noPowerOff': instance.noPowerOff,
      'noPowerOffOnClose': instance.noPowerOffOnClose,
      'noPowerOffOnDisconnect': instance.noPowerOffOnDisconnect,
      'noPowerOffOnError': instance.noPowerOffOnError,
      'noPowerOffOnExit': instance.noPowerOffOnExit,
      'noPowerOffOnStop': instance.noPowerOffOnStop,
      'noPowerOffOnSuspend': instance.noPowerOffOnSuspend,
      'noPowerOffOnResume': instance.noPowerOffOnResume,
      'noPowerOffOnLock': instance.noPowerOffOnLock,
      'noPowerOffOnUnlock': instance.noPowerOffOnUnlock,
      'noPowerOffOnScreenOff': instance.noPowerOffOnScreenOff,
      'noPowerOffOnScreenOn': instance.noPowerOffOnScreenOn,
      'noPowerOffOnBatteryLow': instance.noPowerOffOnBatteryLow,
      'noPowerOffOnBatteryCritical': instance.noPowerOffOnBatteryCritical,
      'noPowerOffOnBatteryFull': instance.noPowerOffOnBatteryFull,
      'noPowerOffOnBatteryCharging': instance.noPowerOffOnBatteryCharging,
      'noPowerOffOnBatteryDischarging': instance.noPowerOffOnBatteryDischarging,
      'noPowerOffOnBatteryNotCharging': instance.noPowerOffOnBatteryNotCharging,
      'noPowerOffOnBatteryUnknown': instance.noPowerOffOnBatteryUnknown,
      'noPowerOffOnBatteryNotPresent': instance.noPowerOffOnBatteryNotPresent,
      'noPowerOffOnBatteryPresent': instance.noPowerOffOnBatteryPresent,
      'noPowerOffOnBatteryChargingAC': instance.noPowerOffOnBatteryChargingAC,
      'noPowerOffOnBatteryChargingUSB': instance.noPowerOffOnBatteryChargingUSB,
      'noPowerOffOnBatteryChargingWireless':
          instance.noPowerOffOnBatteryChargingWireless,
      'noPowerOffOnBatteryChargingUnknown':
          instance.noPowerOffOnBatteryChargingUnknown,
      'noPowerOffOnBatteryChargingNotCharging':
          instance.noPowerOffOnBatteryChargingNotCharging,
      'noPowerOffOnBatteryChargingDischarging':
          instance.noPowerOffOnBatteryChargingDischarging,
      'noPowerOffOnBatteryChargingFull':
          instance.noPowerOffOnBatteryChargingFull,
      'noPowerOffOnBatteryChargingLow': instance.noPowerOffOnBatteryChargingLow,
      'noPowerOffOnBatteryChargingCritical':
          instance.noPowerOffOnBatteryChargingCritical,
      'noPowerOffOnBatteryChargingNotPresent':
          instance.noPowerOffOnBatteryChargingNotPresent,
      'noPowerOffOnBatteryChargingPresent':
          instance.noPowerOffOnBatteryChargingPresent,
    };
