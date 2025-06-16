import 'package:flutter/material.dart';
import 'package:flutter_scrcpy_gui/models/device_config.dart';
import 'package:flutter_scrcpy_gui/config/layout_config.dart';

class DeviceConfigDialog extends StatefulWidget {
  final DeviceConfig config;
  final Function(DeviceConfig) onSave;
  final bool isCompact;

  const DeviceConfigDialog({
    super.key,
    required this.config,
    required this.onSave,
    this.isCompact = false,
  });

  @override
  State<DeviceConfigDialog> createState() => _DeviceConfigDialogState();
}

class _DeviceConfigDialogState extends State<DeviceConfigDialog> {
  late DeviceConfig _config;
  final _formKey = GlobalKey<FormState>();

  final List<Map<String, String>> _switchConfigs = [
    {
      'title': '保持屏幕常亮',
      'subtitle': '防止设备屏幕自动关闭，建议在需要长时间操作时启用',
      'key': 'stayAwake',
    },
    {
      'title': '关闭设备屏幕',
      'subtitle': '在连接时关闭设备屏幕，可以节省设备电量',
      'key': 'turnScreenOff',
    },
    {
      'title': '显示触摸点',
      'subtitle': '在设备上显示触摸点，适合演示或教学场景',
      'key': 'showTouches',
    },
    {
      'title': '全屏显示',
      'subtitle': '启动时全屏显示，适合演示或游戏场景',
      'key': 'fullscreen',
    },
    {
      'title': '窗口置顶',
      'subtitle': '保持窗口在最前面，方便同时操作其他窗口',
      'key': 'alwaysOnTop',
    },
    {
      'title': '禁用屏保',
      'subtitle': '防止系统屏保启动，适合长时间演示场景',
      'key': 'disableScreensaver',
    },
    {
      'title': '禁用音频',
      'subtitle': '不转发设备音频，可以节省带宽和系统资源',
      'key': 'noAudio',
    },
    {
      'title': '禁用视频',
      'subtitle': '不显示设备屏幕，仅用于音频传输或控制',
      'key': 'noVideo',
    },
    {
      'title': '禁用控制',
      'subtitle': '不允许控制设备，仅用于查看屏幕',
      'key': 'noControl',
    },
    {
      'title': '禁用显示',
      'subtitle': '不显示设备屏幕，仅用于录制或控制',
      'key': 'noDisplay',
    },
  ];

  @override
  void initState() {
    super.initState();
    _config = widget.config;
  }

  @override
  void didUpdateWidget(DeviceConfigDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config != widget.config) {
      setState(() {
        _config = widget.config;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final layoutConfig = LayoutConfig.getConfig(widget.isCompact);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(layoutConfig.cardPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '设备配置 - ${widget.config.deviceId}',
                style: textTheme.titleMedium,
              ),
            ],
          ),
        ),
        Divider(height: layoutConfig.dividerHeight),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(layoutConfig.cardPadding),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    initialValue: _config.adbPath,
                    decoration: InputDecoration(
                      labelText: 'ADB 路径',
                      helperText: '留空则使用默认路径',
                      border: const OutlineInputBorder(),
                      isDense: widget.isCompact,
                      contentPadding: layoutConfig.formFieldPadding,
                    ),
                    onChanged: (value) => setState(() {
                      _config = _config.copyWith(adbPath: value.isEmpty ? null : value);
                    }),
                  ),
                  SizedBox(height: layoutConfig.verticalSpacing * 2),
                  TextFormField(
                    initialValue: _config.scrcpyPath,
                    decoration: InputDecoration(
                      labelText: 'Scrcpy 路径',
                      helperText: '留空则使用默认路径',
                      border: const OutlineInputBorder(),
                      isDense: widget.isCompact,
                      contentPadding: layoutConfig.formFieldPadding,
                    ),
                    onChanged: (value) => setState(() {
                      _config = _config.copyWith(scrcpyPath: value.isEmpty ? null : value);
                    }),
                  ),
                  SizedBox(height: layoutConfig.verticalSpacing * 2),
                  TextFormField(
                    initialValue: _config.maxSize?.toString(),
                    decoration: InputDecoration(
                      labelText: '最大尺寸 (像素)',
                      helperText: '推荐值：1920（1080p）或 2560（2K）',
                      border: const OutlineInputBorder(),
                      isDense: widget.isCompact,
                      contentPadding: layoutConfig.formFieldPadding,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => setState(() {
                      _config = _config.copyWith(maxSize: value.isEmpty ? null : int.tryParse(value));
                    }),
                  ),
                  SizedBox(height: layoutConfig.verticalSpacing * 2),
                  TextFormField(
                    initialValue: _config.bitRate?.toString(),
                    decoration: InputDecoration(
                      labelText: '比特率 (Mbps)',
                      helperText: '推荐值：8-16，值越大画质越好但占用更多带宽',
                      border: const OutlineInputBorder(),
                      isDense: widget.isCompact,
                      contentPadding: layoutConfig.formFieldPadding,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => setState(() {
                      _config = _config.copyWith(bitRate: value.isEmpty ? null : int.tryParse(value));
                    }),
                  ),
                  SizedBox(height: layoutConfig.verticalSpacing * 2),
                  TextFormField(
                    initialValue: _config.maxFps?.toString(),
                    decoration: InputDecoration(
                      labelText: '最大帧率 (fps)',
                      helperText: '推荐值：30-60，值越大画面越流畅',
                      border: const OutlineInputBorder(),
                      isDense: widget.isCompact,
                      contentPadding: layoutConfig.formFieldPadding,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => setState(() {
                      _config = _config.copyWith(maxFps: value.isEmpty ? null : int.tryParse(value));
                    }),
                  ),
                  SizedBox(height: layoutConfig.verticalSpacing * 2),
                  Text('编码选项',
                      style: widget.isCompact
                          ? textTheme.titleSmall
                          : textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(height: layoutConfig.verticalSpacing),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(layoutConfig.cardPadding),
                      child: Column(
                        children: [
                          ListTile(
                            visualDensity: layoutConfig.visualDensity,
                            contentPadding: EdgeInsets.symmetric(horizontal: layoutConfig.cardPadding),
                            title: Text('视频编码器', style: textTheme.bodyMedium),
                            subtitle: Text('选择适合您设备的编码器', style: textTheme.bodySmall),
                            trailing: SizedBox(
                              width: 120,
                              child: DropdownButton<String>(
                                value: _config.encoder?.isEmpty ?? true ? 'software' : _config.encoder,
                                isDense: true,
                                isExpanded: true,
                                underline: Container(
                                  height: 1,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'software',
                                    child: Text('软解码'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'snapdragon_h264',
                                    child: Text('骁龙264'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'snapdragon_h265',
                                    child: Text('骁龙265'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'mediatek_h264',
                                    child: Text('联发科264'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'mediatek_h265',
                                    child: Text('联发科265'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _config = _config.copyWith(encoder: value ?? 'software');
                                  });
                                },
                              ),
                            ),
                          ),
                          Divider(height: layoutConfig.dividerHeight),
                          ListTile(
                            visualDensity: layoutConfig.visualDensity,
                            contentPadding: EdgeInsets.symmetric(horizontal: layoutConfig.cardPadding),
                            title: Text('屏幕裁剪', style: textTheme.bodyMedium),
                            subtitle: Text('例如：1920:1080:0:0 表示从左上角开始裁剪 1920x1080 的区域', style: textTheme.bodySmall),
                            trailing: SizedBox(
                              width: 120,
                              child: TextFormField(
                                initialValue: _config.crop,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                  border: OutlineInputBorder(),
                                  labelText: '宽:高:X:Y',
                                ),
                                onChanged: (value) => setState(() {
                                  _config = _config.copyWith(crop: value.isEmpty ? null : value);
                                }),
                              ),
                            ),
                          ),
                          Divider(height: layoutConfig.dividerHeight),
                          ListTile(
                            visualDensity: layoutConfig.visualDensity,
                            contentPadding: EdgeInsets.symmetric(horizontal: layoutConfig.cardPadding),
                            title: Text('锁定视频方向', style: textTheme.bodyMedium),
                            subtitle: Text('0=自然方向，1=90度，2=180度，3=270度', style: textTheme.bodySmall),
                            trailing: SizedBox(
                              width: 120,
                              child: TextFormField(
                                initialValue: _config.lockVideoOrientation?.toString(),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                  border: OutlineInputBorder(),
                                  labelText: '方向值',
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) => setState(() {
                                  _config = _config.copyWith(
                                      lockVideoOrientation: value.isEmpty ? null : int.tryParse(value));
                                }),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: layoutConfig.verticalSpacing * 2),
                  Text('窗口选项',
                      style: widget.isCompact
                          ? textTheme.titleSmall
                          : textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(height: layoutConfig.verticalSpacing),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(layoutConfig.cardPadding),
                      child: Column(
                        children: [
                          ListTile(
                            visualDensity: layoutConfig.visualDensity,
                            contentPadding: EdgeInsets.symmetric(horizontal: layoutConfig.cardPadding),
                            title: Text('窗口标题', style: textTheme.bodyMedium),
                            subtitle: Text('例如：${_config.deviceId} - Scrcpy', style: textTheme.bodySmall),
                            trailing: SizedBox(
                              width: 120,
                              child: TextFormField(
                                initialValue: _config.windowTitle,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                  border: OutlineInputBorder(),
                                  labelText: '标题',
                                ),
                                onChanged: (value) => setState(() {
                                  _config = _config.copyWith(windowTitle: value.isEmpty ? null : value);
                                }),
                              ),
                            ),
                          ),
                          Divider(height: layoutConfig.dividerHeight),
                          ListTile(
                            visualDensity: layoutConfig.visualDensity,
                            contentPadding: EdgeInsets.symmetric(horizontal: layoutConfig.cardPadding),
                            title: Text('窗口位置', style: textTheme.bodyMedium),
                            subtitle: Text('0,0 表示左上角，-1,-1 表示居中', style: textTheme.bodySmall),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 60,
                                  child: TextFormField(
                                    initialValue: _config.windowX?.toString(),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                      border: OutlineInputBorder(),
                                      labelText: 'X (px)',
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) => setState(() {
                                      _config = _config.copyWith(windowX: value.isEmpty ? null : int.tryParse(value));
                                    }),
                                  ),
                                ),
                                SizedBox(width: layoutConfig.horizontalSpacing),
                                SizedBox(
                                  width: 60,
                                  child: TextFormField(
                                    initialValue: _config.windowY?.toString(),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                      border: OutlineInputBorder(),
                                      labelText: 'Y (px)',
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) => setState(() {
                                      _config = _config.copyWith(windowY: value.isEmpty ? null : int.tryParse(value));
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(height: layoutConfig.dividerHeight),
                          ListTile(
                            visualDensity: layoutConfig.visualDensity,
                            contentPadding: EdgeInsets.symmetric(horizontal: layoutConfig.cardPadding),
                            title: Text('窗口大小', style: textTheme.bodyMedium),
                            subtitle: Text('设置窗口的宽度和高度（像素）', style: textTheme.bodySmall),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 60,
                                  child: TextFormField(
                                    initialValue: _config.windowWidth?.toString(),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                      border: OutlineInputBorder(),
                                      labelText: '宽 (px)',
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) => setState(() {
                                      _config =
                                          _config.copyWith(windowWidth: value.isEmpty ? null : int.tryParse(value));
                                    }),
                                  ),
                                ),
                                SizedBox(width: layoutConfig.horizontalSpacing),
                                SizedBox(
                                  width: 60,
                                  child: TextFormField(
                                    initialValue: _config.windowHeight?.toString(),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                      border: OutlineInputBorder(),
                                      labelText: '高 (px)',
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) => setState(() {
                                      _config =
                                          _config.copyWith(windowHeight: value.isEmpty ? null : int.tryParse(value));
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: layoutConfig.verticalSpacing * 2),
                  Text('录制选项',
                      style: widget.isCompact
                          ? textTheme.titleSmall
                          : textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(height: layoutConfig.verticalSpacing),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(layoutConfig.cardPadding),
                      child: Column(
                        children: [
                          ListTile(
                            visualDensity: layoutConfig.visualDensity,
                            contentPadding: EdgeInsets.symmetric(horizontal: layoutConfig.cardPadding),
                            title: Text('录制目录', style: textTheme.bodyMedium),
                            subtitle: Text('选择录制文件的保存目录，文件名将自动生成', style: textTheme.bodySmall),
                            trailing: SizedBox(
                              width: 120,
                              child: TextFormField(
                                initialValue: _config.recordDirectory,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                  border: OutlineInputBorder(),
                                  labelText: '目录路径',
                                ),
                                onChanged: (value) => setState(() {
                                  _config = _config.copyWith(recordDirectory: value.isEmpty ? null : value);
                                }),
                              ),
                            ),
                          ),
                          Divider(height: layoutConfig.dividerHeight),
                          ListTile(
                            visualDensity: layoutConfig.visualDensity,
                            contentPadding: EdgeInsets.symmetric(horizontal: layoutConfig.cardPadding),
                            title: Text('录制格式', style: textTheme.bodyMedium),
                            subtitle: Text('mp4（通用性好）、mkv（支持更多编码）', style: textTheme.bodySmall),
                            trailing: SizedBox(
                              width: 120,
                              child: TextFormField(
                                initialValue: _config.recordFormat,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                  border: OutlineInputBorder(),
                                  labelText: '格式',
                                ),
                                onChanged: (value) => setState(() {
                                  _config = _config.copyWith(recordFormat: value.isEmpty ? null : value);
                                }),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: layoutConfig.verticalSpacing * 2),
                  Text('高级选项',
                      style: widget.isCompact
                          ? textTheme.titleSmall
                          : textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(height: layoutConfig.verticalSpacing),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(layoutConfig.cardPadding),
                      child: Column(
                        children: [
                          ...List.generate(
                            _switchConfigs.length,
                            (index) {
                              final item = _switchConfigs[index];
                              return Column(
                                children: [
                                  if (index > 0) Divider(height: layoutConfig.dividerHeight),
                                  ListTile(
                                    visualDensity: layoutConfig.visualDensity,
                                    contentPadding: EdgeInsets.symmetric(horizontal: layoutConfig.cardPadding),
                                    title: Text(item['title']!, style: textTheme.bodyMedium),
                                    subtitle: Text(item['subtitle']!, style: textTheme.bodySmall),
                                    trailing: Transform.scale(
                                      scale: layoutConfig.switchScale,
                                      child: Switch(
                                        value: _config.toJson()[item['key']] ?? false,
                                        onChanged: (value) => setState(() {
                                          _config = _config.copyWith(
                                            stayAwake: item['key'] == 'stayAwake' ? value : _config.stayAwake,
                                            turnScreenOff:
                                                item['key'] == 'turnScreenOff' ? value : _config.turnScreenOff,
                                            showTouches: item['key'] == 'showTouches' ? value : _config.showTouches,
                                            fullscreen: item['key'] == 'fullscreen' ? value : _config.fullscreen,
                                            alwaysOnTop: item['key'] == 'alwaysOnTop' ? value : _config.alwaysOnTop,
                                            disableScreensaver: item['key'] == 'disableScreensaver'
                                                ? value
                                                : _config.disableScreensaver,
                                            noAudio: item['key'] == 'noAudio' ? value : _config.noAudio,
                                            noVideo: item['key'] == 'noVideo' ? value : _config.noVideo,
                                            noControl: item['key'] == 'noControl' ? value : _config.noControl,
                                            noDisplay: item['key'] == 'noDisplay' ? value : _config.noDisplay,
                                          );
                                        }),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(layoutConfig.cardPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('保存后更改才会生效', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
              SizedBox(width: layoutConfig.horizontalSpacing * 2),
              FilledButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    widget.onSave(_config);
                  }
                },
                child: Text('保存',
                    style: widget.isCompact
                        ? Theme.of(context).textTheme.labelSmall!.copyWith(color: Colors.white)
                        : null),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
