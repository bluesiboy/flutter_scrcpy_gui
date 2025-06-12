import 'package:flutter/material.dart';
import 'package:flutter_scrcpy_gui/models/device_config.dart';
import 'package:flutter_scrcpy_gui/services/adb_service.dart';

class DeviceCard extends StatefulWidget {
  final String deviceId;
  final bool isSelected;
  final Function(String) onSelect;
  final Function(String) onStart;
  final Function(DeviceConfig) onConfigChanged;
  final DeviceConfig config;
  final bool isCompact;

  const DeviceCard({
    super.key,
    required this.deviceId,
    required this.isSelected,
    required this.onSelect,
    required this.onStart,
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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isCompact = widget.isCompact;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => widget.onSelect(widget.deviceId),
        child: Padding(
          padding: EdgeInsets.all(isCompact ? 8.0 : 16.0),
          child: Row(
            children: [
              if (_isLoading)
                SizedBox(
                  width: isCompact ? 16.0 : 24.0,
                  height: isCompact ? 16.0 : 24.0,
                  child: const CircularProgressIndicator(strokeWidth: 2.0),
                )
              else
                Icon(
                  Icons.phone_android,
                  size: isCompact ? 16.0 : 24.0,
                  color: widget.isSelected ? Theme.of(context).colorScheme.primary : null,
                ),
              SizedBox(width: isCompact ? 8.0 : 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _deviceName ?? widget.deviceId,
                      style: isCompact ? textTheme.bodyMedium : textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!isCompact && _deviceName != null)
                      Text(
                        widget.deviceId,
                        style: textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (widget.isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                  size: isCompact ? 16.0 : 24.0,
                ),
              SizedBox(width: isCompact ? 8.0 : 16.0),
              FilledButton(
                onPressed: () => widget.onStart(widget.deviceId),
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 8.0 : 16.0,
                    vertical: isCompact ? 4.0 : 8.0,
                  ),
                ),
                child: Text(
                  '启动',
                  style: isCompact
                      ? textTheme.labelSmall!.copyWith(color: Colors.white)
                      : textTheme.labelLarge!.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
