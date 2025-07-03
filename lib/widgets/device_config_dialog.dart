import 'package:flutter/material.dart';
import 'package:flutter_scrcpy_gui/models/device_config.dart';
import 'package:flutter_scrcpy_gui/config/layout_config.dart';
import 'package:flutter_scrcpy_gui/services/config_service.dart';
import 'package:flutter_scrcpy_gui/models/path_history.dart';
import 'package:file_picker/file_picker.dart';

class DeviceConfigDialog extends StatefulWidget {
  final DeviceConfig config;
  final Function(DeviceConfig) onSave;
  final bool isCompact;
  final ConfigService configService;

  const DeviceConfigDialog({
    super.key,
    required this.config,
    required this.onSave,
    required this.configService,
    this.isCompact = false,
  });

  @override
  State<DeviceConfigDialog> createState() => _DeviceConfigDialogState();
}

class _DeviceConfigDialogState extends State<DeviceConfigDialog> {
  late DeviceConfig _config;
  final _formKey = GlobalKey<FormState>();

  final List<Map<String, String>> _switchConfigs = [
    {'title': '保持屏幕常亮', 'subtitle': '防止设备屏幕自动关闭，建议在需要长时间操作时启用', 'key': 'stayAwake'},
    {'title': '关闭设备屏幕', 'subtitle': '在连接时关闭设备屏幕，可以节省设备电量', 'key': 'turnScreenOff'},
    {'title': '显示触摸点', 'subtitle': '在设备上显示触摸点，适合演示或教学场景', 'key': 'showTouches'},
    {'title': '全屏显示', 'subtitle': '启动时全屏显示，适合演示或游戏场景', 'key': 'fullscreen'},
    {'title': '窗口置顶', 'subtitle': '保持窗口在最前面，方便同时操作其他窗口', 'key': 'alwaysOnTop'},
    {'title': '禁用屏保', 'subtitle': '防止系统屏保启动，适合长时间演示场景', 'key': 'disableScreensaver'},
    {'title': '禁用音频', 'subtitle': '不转发设备音频，可以节省带宽和系统资源', 'key': 'noAudio'},
    {'title': '禁用视频', 'subtitle': '不显示设备屏幕，仅用于音频传输或控制', 'key': 'noVideo'},
    {'title': '禁用控制', 'subtitle': '不允许控制设备，仅用于查看屏幕', 'key': 'noControl'},
    {'title': '禁用显示', 'subtitle': '不显示设备屏幕，仅用于录制或控制', 'key': 'noDisplay'},
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
      setState(() => _config = widget.config);
    }
  }

  Widget _buildFormField({
    required String label,
    required String helperText,
    required String? initialValue,
    required Function(String) onChanged,
    TextInputType? keyboardType,
  }) {
    final layoutConfig = LayoutConfig.getConfig(widget.isCompact);
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        border: const OutlineInputBorder(),
        isDense: widget.isCompact,
        contentPadding: layoutConfig.formFieldPadding,
      ),
      keyboardType: keyboardType,
      onChanged: (value) => setState(() => onChanged(value)),
    );
  }

  Widget _buildFormFieldWithBrowse({
    required String label,
    required String helperText,
    required String? initialValue,
    required Function(String) onChanged,
    required List<String> history,
    required String fileTypeDesc,
    TextInputType? keyboardType,
  }) {
    final layoutConfig = LayoutConfig.getConfig(widget.isCompact);
    final controller = TextEditingController(text: initialValue);
    final textStyle = layoutConfig.inputStyle ?? Theme.of(context).textTheme.bodyMedium;
    final itemPadding =
        EdgeInsets.symmetric(horizontal: layoutConfig.cardPadding, vertical: layoutConfig.verticalSpacing + 2);
    final itemHeight = widget.isCompact ? 32.0 : 44.0;
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        border: const OutlineInputBorder(),
        isDense: widget.isCompact,
        contentPadding: layoutConfig.formFieldPadding,
        suffixIcon: PopupMenuButton<String>(
          icon: const Icon(Icons.folder_open),
          onSelected: (value) async {
            if (value == '__file_picker__') {
              String? result = await FilePicker.platform.pickFiles(
                dialogTitle: '选择$fileTypeDesc文件',
                type: FileType.custom,
                allowedExtensions: ['exe', ''],
              ).then((picked) => picked?.files.single.path);
              if (result != null && result.isNotEmpty) {
                controller.text = result;
                onChanged(result);
              }
            } else {
              final path = value.split(' (').first.trim();
              controller.text = path;
              onChanged(path);
            }
          },
          itemBuilder: (context) {
            final items = history.where((e) => e.isNotEmpty).toList();
            return [
              ...items.map((e) => PopupMenuItem(
                    value: e,
                    height: itemHeight,
                    padding: itemPadding,
                    child: Text(e, style: textStyle),
                  )),
              if (items.isNotEmpty) const PopupMenuDivider(),
              PopupMenuItem(
                value: '__file_picker__',
                height: itemHeight,
                padding: itemPadding,
                child: Text('选择一个$fileTypeDesc文件', style: textStyle),
              ),
            ];
          },
        ),
      ),
      keyboardType: keyboardType,
      onChanged: (value) => setState(() => onChanged(value)),
    );
  }

  Widget _buildConfigSection({
    required String title,
    required List<Widget> children,
    required TextStyle? titleStyle,
  }) {
    final layoutConfig = LayoutConfig.getConfig(widget.isCompact);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: titleStyle),
        SizedBox(height: layoutConfig.verticalSpacing),
        ...children,
        SizedBox(height: layoutConfig.verticalSpacing * 2),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final layoutConfig = LayoutConfig.getConfig(widget.isCompact);
    final titleStyle =
        widget.isCompact ? textTheme.titleSmall : textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(layoutConfig.cardPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('核心配置 - ${widget.config.deviceId}', style: textTheme.titleMedium),
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
                  _buildConfigSection(
                    title: '基本配置',
                    titleStyle: titleStyle,
                    children: [
                      _buildFormFieldWithBrowse(
                        label: 'ADB 路径',
                        helperText: '留空则使用默认路径',
                        initialValue: _config.adbPath,
                        onChanged: (value) => _config = _config.copyWith(adbPath: value.isEmpty ? null : value),
                        history: PathHistory.getAdbDisplayList(),
                        fileTypeDesc: 'ADB',
                      ),
                      SizedBox(height: layoutConfig.verticalSpacing * 2),
                      _buildFormFieldWithBrowse(
                        label: 'Scrcpy 路径',
                        helperText: '留空则使用默认路径',
                        initialValue: _config.scrcpyPath,
                        onChanged: (value) => _config = _config.copyWith(scrcpyPath: value.isEmpty ? null : value),
                        history: PathHistory.getScrcpyDisplayList(),
                        fileTypeDesc: 'scrcpy',
                      ),
                      SizedBox(height: layoutConfig.verticalSpacing * 2),
                      _buildFormField(
                        label: '最大尺寸 (像素)',
                        helperText: '推荐值：1920（1080p）或 2560（2K）',
                        initialValue: _config.maxSize.toString(),
                        keyboardType: TextInputType.number,
                        onChanged: (value) =>
                            _config = _config.copyWith(maxSize: value.isEmpty ? null : int.tryParse(value)),
                      ),
                      SizedBox(height: layoutConfig.verticalSpacing * 2),
                      _buildFormField(
                        label: '视频编码率 (Mbps)',
                        helperText: '推荐值：8-16，值越大画质越好但占用更多带宽',
                        initialValue: _config.bitRate.toString(),
                        keyboardType: TextInputType.number,
                        onChanged: (value) =>
                            _config = _config.copyWith(bitRate: value.isEmpty ? null : int.tryParse(value)),
                      ),
                      SizedBox(height: layoutConfig.verticalSpacing * 2),
                      _buildFormField(
                        label: '最大帧率 (fps)',
                        helperText: '推荐值：30-60，值越大画面越流畅',
                        initialValue: _config.maxFps?.toString(),
                        keyboardType: TextInputType.number,
                        onChanged: (value) =>
                            _config = _config.copyWith(maxFps: value.isEmpty ? null : int.tryParse(value)),
                      ),
                    ],
                  ),
                  _buildConfigSection(
                    title: '快捷键修饰符',
                    titleStyle: titleStyle,
                    children: [
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(layoutConfig.cardPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: layoutConfig.horizontalSpacing,
                                runSpacing: layoutConfig.verticalSpacing,
                                children: [
                                  ...List.generate(7, (index) {
                                    final Map<String, String> mods = {
                                      '自动': '',
                                      '左 Ctrl': 'lctrl',
                                      '左 Alt': 'lalt',
                                      '左 Super': 'lsuper',
                                      '右 Ctrl': 'rctrl',
                                      '右 Alt': 'ralt',
                                      '右 Super': 'rsuper',
                                    };
                                    final label = mods.keys.elementAt(index);
                                    final value = mods.values.elementAt(index);
                                    final isSelected = value.isEmpty
                                        ? _config.shortcutMod == null || _config.shortcutMod!.isEmpty
                                        : _config.shortcutMod?.contains(value) ?? false;

                                    return FilterChip(
                                      label: Text(label, style: widget.isCompact ? textTheme.labelSmall : null),
                                      selected: isSelected,
                                      onSelected: (selected) {
                                        setState(() {
                                          if (value.isEmpty) {
                                            _config = _config.copyWith(shortcutMod: selected ? null : '');
                                          } else {
                                            final currentMods = _config.shortcutMod?.split(',') ?? [];
                                            if (selected) {
                                              currentMods.add(value);
                                            } else {
                                              currentMods.remove(value);
                                            }
                                            _config = _config.copyWith(
                                              shortcutMod: currentMods.isEmpty ? null : currentMods.join(','),
                                            );
                                          }
                                        });
                                      },
                                    );
                                  }),
                                ],
                              ),
                              SizedBox(height: layoutConfig.verticalSpacing),
                              Text(
                                '提示：选择"自动"将使用系统默认值，或选择任意组合的修饰键',
                                style: textTheme.bodySmall?.copyWith(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  _buildConfigSection(
                    title: '编码选项',
                    titleStyle: titleStyle,
                    children: [
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
                                      DropdownMenuItem(value: 'software', child: Text('软解码')),
                                      DropdownMenuItem(value: 'snapdragon_h264', child: Text('骁龙264')),
                                      DropdownMenuItem(value: 'snapdragon_h265', child: Text('骁龙265')),
                                      DropdownMenuItem(value: 'mediatek_h264', child: Text('联发科264')),
                                      DropdownMenuItem(value: 'mediatek_h265', child: Text('联发科265')),
                                    ],
                                    onChanged: (value) => setState(() {
                                      _config = _config.copyWith(encoder: value ?? 'software');
                                    }),
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
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: layoutConfig.formFieldPadding,
                                      border: const OutlineInputBorder(),
                                      labelText: '宽:高:X:Y',
                                      labelStyle: layoutConfig.inputLabelStyle,
                                    ),
                                    style: layoutConfig.inputStyle,
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
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: layoutConfig.formFieldPadding,
                                      border: const OutlineInputBorder(),
                                      labelText: '方向值',
                                      labelStyle: layoutConfig.inputLabelStyle,
                                    ),
                                    style: layoutConfig.inputStyle,
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
                    ],
                  ),
                  _buildConfigSection(
                    title: '窗口选项',
                    titleStyle: titleStyle,
                    children: [
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
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: layoutConfig.formFieldPadding,
                                      border: const OutlineInputBorder(),
                                      labelText: '标题',
                                      labelStyle: layoutConfig.inputLabelStyle,
                                    ),
                                    style: layoutConfig.inputStyle,
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
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding: layoutConfig.formFieldPadding,
                                          border: const OutlineInputBorder(),
                                          labelText: 'X (px)',
                                          labelStyle: layoutConfig.inputLabelStyle,
                                        ),
                                        style: layoutConfig.inputStyle,
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) => setState(() {
                                          _config =
                                              _config.copyWith(windowX: value.isEmpty ? null : int.tryParse(value));
                                        }),
                                      ),
                                    ),
                                    SizedBox(width: layoutConfig.horizontalSpacing),
                                    SizedBox(
                                      width: 60,
                                      child: TextFormField(
                                        initialValue: _config.windowY?.toString(),
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding: layoutConfig.formFieldPadding,
                                          border: const OutlineInputBorder(),
                                          labelText: 'Y (px)',
                                          labelStyle: layoutConfig.inputLabelStyle,
                                        ),
                                        style: layoutConfig.inputStyle,
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) => setState(() {
                                          _config =
                                              _config.copyWith(windowY: value.isEmpty ? null : int.tryParse(value));
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
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding: layoutConfig.formFieldPadding,
                                          border: const OutlineInputBorder(),
                                          labelText: '宽 (px)',
                                          labelStyle: layoutConfig.inputLabelStyle,
                                        ),
                                        style: layoutConfig.inputStyle,
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
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding: layoutConfig.formFieldPadding,
                                          border: const OutlineInputBorder(),
                                          labelText: '高 (px)',
                                          labelStyle: layoutConfig.inputLabelStyle,
                                        ),
                                        style: layoutConfig.inputStyle,
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) => setState(() {
                                          _config = _config.copyWith(
                                              windowHeight: value.isEmpty ? null : int.tryParse(value));
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
                    ],
                  ),
                  _buildConfigSection(
                    title: '录制选项',
                    titleStyle: titleStyle,
                    children: [
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
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: layoutConfig.formFieldPadding,
                                      border: const OutlineInputBorder(),
                                      labelText: '目录路径',
                                      labelStyle: layoutConfig.inputLabelStyle,
                                    ),
                                    style: layoutConfig.inputStyle,
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
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: layoutConfig.formFieldPadding,
                                      border: const OutlineInputBorder(),
                                      labelText: '格式',
                                      labelStyle: layoutConfig.inputLabelStyle,
                                    ),
                                    style: layoutConfig.inputStyle,
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
                    ],
                  ),
                  _buildConfigSection(
                    title: '高级选项',
                    titleStyle: titleStyle,
                    children: [
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
                    PathHistory.addAdbPath(_config.adbPath);
                    PathHistory.addScrcpyPath(_config.scrcpyPath);
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
