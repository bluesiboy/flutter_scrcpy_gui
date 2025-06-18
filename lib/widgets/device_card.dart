import 'package:flutter/material.dart';
import 'package:flutter_scrcpy_gui/models/device_config.dart';
import 'package:flutter_scrcpy_gui/services/adb_service.dart';
import 'package:flutter_scrcpy_gui/config/layout_config.dart';

class DeviceCard extends StatefulWidget {
  final String deviceId;
  final String statusText;
  final String deviceState;
  final bool canConnect;
  final bool isSelected;
  final Function(String) onSelect;
  final Function(String)? onStart;
  final Function(DeviceConfig) onConfigChanged;
  final DeviceConfig config;
  final bool isCompact;

  const DeviceCard({
    super.key,
    required this.deviceId,
    required this.statusText,
    required this.deviceState,
    required this.canConnect,
    required this.isSelected,
    required this.onSelect,
    this.onStart,
    required this.onConfigChanged,
    required this.config,
    this.isCompact = false,
  });

  @override
  State<DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  String? _deviceName;
  bool _isLoading = true;
  bool _isRunning = false;
  final _adbService = AdbService();

  @override
  void initState() {
    super.initState();
    _loadDeviceName();
  }

  Future<void> _loadDeviceName() async {
    try {
      final name = await _adbService.getDeviceName(widget.deviceId);
      if (mounted) {
        setState(() {
          _deviceName = name;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _deviceName = widget.deviceId;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleStart() async {
    if (_isRunning) return;
    setState(() => _isRunning = true);
    try {
      await widget.onStart?.call(widget.deviceId);
    } finally {
      if (mounted) setState(() => _isRunning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final layoutConfig = LayoutConfig.getConfig(widget.isCompact);

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: layoutConfig.cardMargin,
        vertical: layoutConfig.verticalSpacing,
      ),
      color: widget.isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => widget.onSelect(widget.deviceId),
        child: ListTile(
          dense: true,
          minVerticalPadding: layoutConfig.verticalSpacing / 2,
          minLeadingWidth: layoutConfig.iconSize,
          contentPadding: EdgeInsets.symmetric(
            horizontal: layoutConfig.cardPadding,
            vertical: layoutConfig.verticalSpacing / 2,
          ),
          leading: _isLoading
              ? SizedBox(
                  width: layoutConfig.iconSize,
                  height: layoutConfig.iconSize,
                  child: const CircularProgressIndicator(strokeWidth: 2.0),
                )
              : Icon(
                  Icons.phone_android,
                  size: layoutConfig.iconSize,
                  color: widget.isSelected ? Theme.of(context).colorScheme.primary : null,
                ),
          title: layoutConfig.titleFontSize <= 16.0
              ? Row(
                  children: [
                    Expanded(
                      child: Text(
                        _deviceName ?? widget.deviceId,
                        style: textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      widget.deviceState,
                      style: textTheme.bodySmall?.copyWith(
                        color: widget.canConnect ? Colors.green : Colors.orange,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                )
              : Text(
                  _deviceName ?? widget.deviceId,
                  style: textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
          subtitle: layoutConfig.titleFontSize > 16.0
              ? Text(
                  widget.deviceState,
                  style: textTheme.bodySmall?.copyWith(
                    color: widget.canConnect ? Colors.green : Colors.orange,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          trailing: widget.canConnect
              ? IconButton(
                  onPressed: _isRunning ? null : _handleStart,
                  icon: _isRunning
                      ? SizedBox(
                          width: layoutConfig.iconSize,
                          height: layoutConfig.iconSize,
                          child: const CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          Icons.play_arrow,
                          size: layoutConfig.iconSize,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  tooltip: '启动',
                  constraints: BoxConstraints(
                    minWidth: layoutConfig.buttonMinSize,
                    minHeight: layoutConfig.buttonMinSize,
                    maxWidth: layoutConfig.buttonMinSize,
                    maxHeight: layoutConfig.buttonMinSize,
                  ),
                  padding: EdgeInsets.all(layoutConfig.buttonPadding / 2),
                )
              : widget.statusText.isNotEmpty
                  ? Tooltip(
                      message: widget.statusText,
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                        size: layoutConfig.iconSize,
                      ),
                    )
                  : null,
        ),
      ),
    );
  }
}
