import 'package:flutter/material.dart';
import 'package:flutter_scrcpy_gui/models/device_config.dart';

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

  // 紧凑模式下的尺寸常量
  static const double _compactPadding = 8.0;
  static const double _normalPadding = 16.0;
  static const double _compactDividerHeight = 0.5;
  static const double _normalDividerHeight = 1.0;
  static const double _compactSpacing = 16.0;
  static const double _normalSpacing = 16.0;
  static const double _compactSwitchScale = 0.7;
  static const double _normalSwitchScale = 1.0;

  // 获取当前模式下的尺寸值
  double get _currentPadding => widget.isCompact ? _compactPadding : _normalPadding;
  double get _currentDividerHeight => widget.isCompact ? _compactDividerHeight : _normalDividerHeight;
  double get _currentSpacing => widget.isCompact ? _compactSpacing : _normalSpacing;
  double get _currentSwitchScale => widget.isCompact ? _compactSwitchScale : _normalSwitchScale;

  // 获取当前模式下的视觉密度
  VisualDensity get _currentVisualDensity => widget.isCompact ? VisualDensity.compact : VisualDensity.standard;

  // 获取当前模式下的内容填充
  EdgeInsets get _currentContentPadding => EdgeInsets.symmetric(
        horizontal: widget.isCompact ? _compactPadding : _normalPadding,
      );

  // 获取当前模式下的文本样式
  TextStyle? _getTitleStyle(TextTheme textTheme) => widget.isCompact ? textTheme.titleMedium : textTheme.titleLarge;

  TextStyle? _getBodyStyle(TextTheme textTheme) => widget.isCompact ? textTheme.bodyMedium : textTheme.bodyLarge;

  TextStyle? _getSubtitleStyle(TextTheme textTheme) => widget.isCompact ? textTheme.bodySmall : textTheme.bodyMedium;

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

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(_currentPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '设备配置 - ${widget.config.deviceId}',
                style: _getTitleStyle(textTheme),
              ),
            ],
          ),
        ),
        Divider(height: _currentDividerHeight),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(_currentPadding),
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
                      contentPadding: widget.isCompact ? const EdgeInsets.symmetric(horizontal: 10, vertical: 8) : null,
                    ),
                    onChanged: (value) => _config = _config.copyWith(adbPath: value),
                  ),
                  SizedBox(height: _currentSpacing),
                  TextFormField(
                    initialValue: _config.scrcpyPath,
                    decoration: InputDecoration(
                      labelText: 'Scrcpy 路径',
                      helperText: '留空则使用默认路径',
                      border: const OutlineInputBorder(),
                      isDense: widget.isCompact,
                      contentPadding: widget.isCompact ? const EdgeInsets.symmetric(horizontal: 10, vertical: 8) : null,
                    ),
                    onChanged: (value) => _config = _config.copyWith(scrcpyPath: value),
                  ),
                  SizedBox(height: _currentSpacing),
                  TextFormField(
                    initialValue: _config.maxSize.toString(),
                    decoration: InputDecoration(
                      labelText: '最大尺寸 (像素)',
                      helperText: '推荐值：1920（1080p）或 2560（2K）',
                      border: const OutlineInputBorder(),
                      isDense: widget.isCompact,
                      contentPadding: widget.isCompact ? const EdgeInsets.symmetric(horizontal: 10, vertical: 8) : null,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => _config = _config.copyWith(maxSize: int.tryParse(value) ?? 1920),
                  ),
                  SizedBox(height: _currentSpacing),
                  TextFormField(
                    initialValue: _config.bitRate.toString(),
                    decoration: InputDecoration(
                      labelText: '比特率 (Mbps)',
                      helperText: '推荐值：8-16，值越大画质越好但占用更多带宽',
                      border: const OutlineInputBorder(),
                      isDense: widget.isCompact,
                      contentPadding: widget.isCompact ? const EdgeInsets.symmetric(horizontal: 10, vertical: 8) : null,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => _config = _config.copyWith(bitRate: int.tryParse(value) ?? 0),
                  ),
                  SizedBox(height: _currentSpacing),
                  Text('编码选项',
                      style: widget.isCompact
                          ? textTheme.titleSmall
                          : textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(height: _currentSpacing),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Column(
                      children: [
                        ListTile(
                          visualDensity: _currentVisualDensity,
                          contentPadding: _currentContentPadding,
                          title: Text('视频编码器', style: _getBodyStyle(textTheme)),
                          subtitle: Text('选择适合您设备的编码器', style: _getSubtitleStyle(textTheme)),
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
                        Divider(height: _currentDividerHeight),
                        ListTile(
                          visualDensity: _currentVisualDensity,
                          contentPadding: _currentContentPadding,
                          title: Text('屏幕裁剪', style: _getBodyStyle(textTheme)),
                          subtitle:
                              Text('例如：1920:1080:0:0 表示从左上角开始裁剪 1920x1080 的区域', style: _getSubtitleStyle(textTheme)),
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
                              onChanged: (value) => _config = _config.copyWith(crop: value),
                            ),
                          ),
                        ),
                        Divider(height: _currentDividerHeight),
                        ListTile(
                          visualDensity: _currentVisualDensity,
                          contentPadding: _currentContentPadding,
                          title: Text('锁定视频方向', style: _getBodyStyle(textTheme)),
                          subtitle: Text('0=自然方向，1=90度，2=180度，3=270度', style: _getSubtitleStyle(textTheme)),
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
                              onChanged: (value) =>
                                  _config = _config.copyWith(lockVideoOrientation: int.tryParse(value)),
                            ),
                          ),
                        ),
                        Divider(height: _currentDividerHeight),
                        ListTile(
                          visualDensity: _currentVisualDensity,
                          contentPadding: _currentContentPadding,
                          title: Text('最大帧率', style: _getBodyStyle(textTheme)),
                          subtitle: Text('推荐值：30-60，值越大画面越流畅', style: _getSubtitleStyle(textTheme)),
                          trailing: SizedBox(
                            width: 120,
                            child: TextFormField(
                              initialValue: _config.maxFps?.toString(),
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                border: OutlineInputBorder(),
                                labelText: '帧率 (fps)',
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) => _config = _config.copyWith(maxFps: int.tryParse(value)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: _currentSpacing),
                  Text('窗口选项',
                      style: widget.isCompact
                          ? textTheme.titleSmall
                          : textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(height: _currentSpacing),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Column(
                      children: [
                        ListTile(
                          visualDensity: _currentVisualDensity,
                          contentPadding: _currentContentPadding,
                          title: Text('窗口标题', style: _getBodyStyle(textTheme)),
                          subtitle: Text('例如：${_config.deviceId} - Scrcpy', style: _getSubtitleStyle(textTheme)),
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
                              onChanged: (value) => _config = _config.copyWith(windowTitle: value),
                            ),
                          ),
                        ),
                        Divider(height: _currentDividerHeight),
                        ListTile(
                          visualDensity: _currentVisualDensity,
                          contentPadding: _currentContentPadding,
                          title: Text('窗口位置', style: _getBodyStyle(textTheme)),
                          subtitle: Text('0,0 表示左上角，-1,-1 表示居中', style: _getSubtitleStyle(textTheme)),
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
                                  onChanged: (value) => _config = _config.copyWith(windowX: int.tryParse(value)),
                                ),
                              ),
                              const SizedBox(width: 8),
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
                                  onChanged: (value) => _config = _config.copyWith(windowY: int.tryParse(value)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(height: _currentDividerHeight),
                        ListTile(
                          visualDensity: _currentVisualDensity,
                          contentPadding: _currentContentPadding,
                          title: Text('窗口大小', style: _getBodyStyle(textTheme)),
                          subtitle: Text('留空则自动适应屏幕比例', style: _getSubtitleStyle(textTheme)),
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
                                  onChanged: (value) => _config = _config.copyWith(windowWidth: int.tryParse(value)),
                                ),
                              ),
                              const SizedBox(width: 8),
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
                                  onChanged: (value) => _config = _config.copyWith(windowHeight: int.tryParse(value)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: _currentSpacing),
                  Text('录制选项',
                      style: widget.isCompact
                          ? textTheme.titleSmall
                          : textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(height: _currentSpacing),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Column(
                      children: [
                        ListTile(
                          visualDensity: _currentVisualDensity,
                          contentPadding: _currentContentPadding,
                          title: Text('录制文件', style: _getBodyStyle(textTheme)),
                          subtitle: Text('支持相对路径和绝对路径', style: _getSubtitleStyle(textTheme)),
                          trailing: SizedBox(
                            width: 120,
                            child: TextFormField(
                              initialValue: _config.record,
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                border: OutlineInputBorder(),
                                labelText: '文件路径',
                              ),
                              onChanged: (value) => _config = _config.copyWith(record: value),
                            ),
                          ),
                        ),
                        Divider(height: _currentDividerHeight),
                        ListTile(
                          visualDensity: _currentVisualDensity,
                          contentPadding: _currentContentPadding,
                          title: Text('录制格式', style: _getBodyStyle(textTheme)),
                          subtitle: Text('mp4（通用性好）、mkv（支持更多编码）', style: _getSubtitleStyle(textTheme)),
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
                              onChanged: (value) => _config = _config.copyWith(recordFormat: value),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: _currentSpacing),
                  Text('高级选项',
                      style: widget.isCompact
                          ? textTheme.titleSmall
                          : textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(height: _currentSpacing),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Column(
                      children: [
                        ListTile(
                          visualDensity: _currentVisualDensity,
                          contentPadding: _currentContentPadding,
                          title: Text('保持屏幕常亮', style: _getBodyStyle(textTheme)),
                          subtitle: Text('防止设备屏幕自动关闭，建议在需要长时间操作时启用', style: _getSubtitleStyle(textTheme)),
                          trailing: Transform.scale(
                            scale: _currentSwitchScale,
                            child: Switch(
                              value: _config.stayAwake,
                              onChanged: (value) => setState(() {
                                _config = _config.copyWith(stayAwake: value);
                              }),
                            ),
                          ),
                          onTap: () => setState(() {
                            _config = _config.copyWith(stayAwake: !_config.stayAwake);
                          }),
                        ),
                        Divider(height: _currentDividerHeight),
                        ListTile(
                          visualDensity: _currentVisualDensity,
                          contentPadding: _currentContentPadding,
                          title: Text('关闭设备屏幕', style: _getBodyStyle(textTheme)),
                          subtitle: Text('在连接时关闭设备屏幕，可以节省设备电量', style: _getSubtitleStyle(textTheme)),
                          trailing: Transform.scale(
                            scale: _currentSwitchScale,
                            child: Switch(
                              value: _config.turnScreenOff,
                              onChanged: (value) => setState(() {
                                _config = _config.copyWith(turnScreenOff: value);
                              }),
                            ),
                          ),
                          onTap: () => setState(() {
                            _config = _config.copyWith(turnScreenOff: !_config.turnScreenOff);
                          }),
                        ),
                        Divider(height: _currentDividerHeight),
                        ListTile(
                          visualDensity: _currentVisualDensity,
                          contentPadding: _currentContentPadding,
                          title: Text('显示触摸点', style: _getBodyStyle(textTheme)),
                          subtitle: Text('在设备上显示触摸点，适合演示或教学场景', style: _getSubtitleStyle(textTheme)),
                          trailing: Transform.scale(
                            scale: _currentSwitchScale,
                            child: Switch(
                              value: _config.showTouches,
                              onChanged: (value) => setState(() {
                                _config = _config.copyWith(showTouches: value);
                              }),
                            ),
                          ),
                          onTap: () => setState(() {
                            _config = _config.copyWith(showTouches: !_config.showTouches);
                          }),
                        ),
                        Divider(height: _currentDividerHeight),
                        ListTile(
                          visualDensity: _currentVisualDensity,
                          contentPadding: _currentContentPadding,
                          title: Text('全屏显示', style: _getBodyStyle(textTheme)),
                          subtitle: Text('启动时全屏显示，适合演示或游戏场景', style: _getSubtitleStyle(textTheme)),
                          trailing: Transform.scale(
                            scale: _currentSwitchScale,
                            child: Switch(
                              value: _config.fullscreen,
                              onChanged: (value) => setState(() {
                                _config = _config.copyWith(fullscreen: value);
                              }),
                            ),
                          ),
                          onTap: () => setState(() {
                            _config = _config.copyWith(fullscreen: !_config.fullscreen);
                          }),
                        ),
                        Divider(height: _currentDividerHeight),
                        ListTile(
                          visualDensity: _currentVisualDensity,
                          contentPadding: _currentContentPadding,
                          title: Text('窗口置顶', style: _getBodyStyle(textTheme)),
                          subtitle: Text('保持窗口在最前面，方便同时操作其他窗口', style: _getSubtitleStyle(textTheme)),
                          trailing: Transform.scale(
                            scale: _currentSwitchScale,
                            child: Switch(
                              value: _config.alwaysOnTop,
                              onChanged: (value) => setState(() {
                                _config = _config.copyWith(alwaysOnTop: value);
                              }),
                            ),
                          ),
                          onTap: () => setState(() {
                            _config = _config.copyWith(alwaysOnTop: !_config.alwaysOnTop);
                          }),
                        ),
                        Divider(height: _currentDividerHeight),
                        ListTile(
                          visualDensity: _currentVisualDensity,
                          contentPadding: _currentContentPadding,
                          title: Text('禁用屏保', style: _getBodyStyle(textTheme)),
                          subtitle: Text('防止系统屏保启动，适合长时间演示场景', style: _getSubtitleStyle(textTheme)),
                          trailing: Transform.scale(
                            scale: _currentSwitchScale,
                            child: Switch(
                              value: _config.disableScreensaver,
                              onChanged: (value) => setState(() {
                                _config = _config.copyWith(disableScreensaver: value);
                              }),
                            ),
                          ),
                          onTap: () => setState(() {
                            _config = _config.copyWith(disableScreensaver: !_config.disableScreensaver);
                          }),
                        ),
                        Divider(height: _currentDividerHeight),
                        ListTile(
                          visualDensity: _currentVisualDensity,
                          contentPadding: _currentContentPadding,
                          title: Text('禁用音频', style: _getBodyStyle(textTheme)),
                          subtitle: Text('不转发设备音频，可以节省带宽和系统资源', style: _getSubtitleStyle(textTheme)),
                          trailing: Transform.scale(
                            scale: _currentSwitchScale,
                            child: Switch(
                              value: _config.noAudio,
                              onChanged: (value) => setState(() {
                                _config = _config.copyWith(noAudio: value);
                              }),
                            ),
                          ),
                          onTap: () => setState(() {
                            _config = _config.copyWith(noAudio: !_config.noAudio);
                          }),
                        ),
                        Divider(height: _currentDividerHeight),
                        ListTile(
                          visualDensity: _currentVisualDensity,
                          contentPadding: _currentContentPadding,
                          title: Text('禁用视频', style: _getBodyStyle(textTheme)),
                          subtitle: Text('不显示设备屏幕，仅用于音频传输或控制', style: _getSubtitleStyle(textTheme)),
                          trailing: Transform.scale(
                            scale: _currentSwitchScale,
                            child: Switch(
                              value: _config.noVideo,
                              onChanged: (value) => setState(() {
                                _config = _config.copyWith(noVideo: value);
                              }),
                            ),
                          ),
                          onTap: () => setState(() {
                            _config = _config.copyWith(noVideo: !_config.noVideo);
                          }),
                        ),
                        Divider(height: _currentDividerHeight),
                        ListTile(
                          visualDensity: _currentVisualDensity,
                          contentPadding: _currentContentPadding,
                          title: Text('禁用控制', style: _getBodyStyle(textTheme)),
                          subtitle: Text('不允许控制设备，仅用于查看屏幕', style: _getSubtitleStyle(textTheme)),
                          trailing: Transform.scale(
                            scale: _currentSwitchScale,
                            child: Switch(
                              value: _config.noControl,
                              onChanged: (value) => setState(() {
                                _config = _config.copyWith(noControl: value);
                              }),
                            ),
                          ),
                          onTap: () => setState(() {
                            _config = _config.copyWith(noControl: !_config.noControl);
                          }),
                        ),
                        Divider(height: _currentDividerHeight),
                        ListTile(
                          visualDensity: _currentVisualDensity,
                          contentPadding: _currentContentPadding,
                          title: Text('禁用显示', style: _getBodyStyle(textTheme)),
                          subtitle: Text('不显示设备屏幕，仅用于录制或控制', style: _getSubtitleStyle(textTheme)),
                          trailing: Transform.scale(
                            scale: _currentSwitchScale,
                            child: Switch(
                              value: _config.noDisplay,
                              onChanged: (value) => setState(() {
                                _config = _config.copyWith(noDisplay: value);
                              }),
                            ),
                          ),
                          onTap: () => setState(() {
                            _config = _config.copyWith(noDisplay: !_config.noDisplay);
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Divider(height: _currentDividerHeight),
        Padding(
          padding: EdgeInsets.all(_currentPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('保存后更改才会生效', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
              const SizedBox(width: 16),
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
