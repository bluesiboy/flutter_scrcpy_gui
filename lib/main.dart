import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_scrcpy_gui/services/adb_service.dart';
import 'package:flutter_scrcpy_gui/services/config_service.dart';
import 'package:flutter_scrcpy_gui/models/device_config.dart';
import 'package:flutter_scrcpy_gui/widgets/breath_glow_widget.dart';
import 'package:flutter_scrcpy_gui/widgets/device_config_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:window_manager/window_manager.dart';

// 布局尺寸配置
class LayoutSizes {
  static const double titleFontSize = 20.0;
  static const double titleFontSizeCompact = 16.0;

  static const double toolbarHeight = 56.0;
  static const double toolbarHeightCompact = 40.0;

  static const double iconSize = 24.0;
  static const double iconSizeCompact = 20.0;

  static const double buttonPadding = 12.0;
  static const double buttonPaddingCompact = 8.0;

  static const double buttonMinSize = 48.0;
  static const double buttonMinSizeCompact = 32.0;

  static const double cardMargin = 16.0;
  static const double cardMarginCompact = 8.0;

  static const double cardPadding = 16.0;
  static const double cardPaddingCompact = 8.0;

  static const double verticalSpacing = 8.0;
  static const double verticalSpacingCompact = 4.0;
}

// 定义一个Riverpod StateProvider来管理紧凑模式状态
final isCompactModeProvider = StateProvider<bool>((ref) => false); // 默认为舒适模式 (false)

// 定义一个Riverpod StateProvider来管理主题模式
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system); // 默认为跟随系统

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final configService = ConfigService(prefs);

  // 获取保存的显示模式和窗口大小
  final isCompact = configService.getCompactMode();
  final savedSize = configService.getWindowSize();
  final savedPosition = configService.getWindowPosition();

  // 初始化窗口管理器
  await windowManager.ensureInitialized();
  windowManager.setTitle('Scrcpy GUI');
  WindowOptions windowOptions = WindowOptions(
    size: savedSize, // 使用保存的窗口大小
    minimumSize: const Size(400, 400), // 设置最小窗口大小
    center: savedPosition == Offset.zero, // 如果没有保存的位置，则居中显示
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    if (savedPosition != Offset.zero) {
      await windowManager.setPosition(savedPosition);
    }
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(ProviderScope(
    child: MainApp(
      prefs: prefs,
      initialCompactMode: isCompact,
    ),
  ));
}

class MainApp extends ConsumerStatefulWidget {
  final SharedPreferences prefs;
  final bool initialCompactMode;

  const MainApp({
    super.key,
    required this.prefs,
    required this.initialCompactMode,
  });

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> with WindowListener {
  late final AdbService _adbService;
  late final ConfigService _configService;
  String? _selectedDeviceId;
  DeviceConfig? currentSelectedConfig;

  @override
  void initState() {
    super.initState();
    _adbService = AdbService();
    _configService = ConfigService(widget.prefs);
    _refreshDevices();
    // 设置初始显示模式
    ref.read(isCompactModeProvider.notifier).state = widget.initialCompactMode;
    // 设置初始主题模式
    ref.read(themeModeProvider.notifier).state = _configService.getThemeMode();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowResize() async {
    final size = await windowManager.getSize();
    await _configService.saveWindowSize(size);
  }

  @override
  void onWindowMove() async {
    final position = await windowManager.getPosition();
    await _configService.saveWindowPosition(position);
  }

  Future<void> _refreshDevices() async {
    final devices = await _adbService.getConnectedDevices();
    setState(() {
      if (_selectedDeviceId == null || !devices.contains(_selectedDeviceId)) {
        _selectedDeviceId = devices.isNotEmpty ? devices.first : null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(isCompactModeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Scrcpy GUI By blueisboy',
      themeMode: themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: HomePage(prefs: widget.prefs),
    );
  }
}

class HomePage extends ConsumerStatefulWidget {
  final SharedPreferences prefs;

  const HomePage({super.key, required this.prefs});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late final AdbService _adbService;
  late final ConfigService _configService;
  late final BreathGlowController _breathGlowController;
  List<String> _devices = [];
  bool _isLoading = true;
  String? _selectedDeviceId;

  @override
  void initState() {
    super.initState();
    _adbService = AdbService();
    _configService = ConfigService(widget.prefs);
    _breathGlowController = BreathGlowController(breathCount: 100);
    _breathGlowController.start();
    _refreshDevices();
  }

  @override
  void dispose() {
    _breathGlowController.dispose();
    super.dispose();
  }

  Future<void> _refreshDevices() async {
    setState(() => _isLoading = true);
    final devices = await _adbService.getConnectedDevices();
    setState(() {
      _devices = devices;
      _isLoading = false;
      if (_selectedDeviceId == null || !devices.contains(_selectedDeviceId)) {
        _selectedDeviceId = devices.isNotEmpty ? devices.first : null;
      }
    });
  }

  Future<void> _startScrcpy(String deviceId) async {
    final config = _configService.getDeviceConfig(deviceId) ?? DeviceConfig(deviceId: deviceId);
    await _adbService.startScrcpy(deviceId, config.toJson());
  }

  void _selectDevice(String deviceId) {
    setState(() {
      _selectedDeviceId = deviceId;
    });
  }

  Future<void> _saveConfig(DeviceConfig config) async {
    await _configService.saveDeviceConfig(config);
  }

  // 切换主题模式
  Future<void> _toggleThemeMode() async {
    final currentMode = ref.read(themeModeProvider);
    ThemeMode newMode;
    switch (currentMode) {
      case ThemeMode.system:
        newMode = ThemeMode.light;
        break;
      case ThemeMode.light:
        newMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        newMode = ThemeMode.system;
        break;
    }
    ref.read(themeModeProvider.notifier).state = newMode;
    await _configService.saveThemeMode(newMode);
  }

  // 获取主题模式图标
  IconData _getThemeModeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return Icons.brightness_auto;
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
    }
  }

  // 获取主题模式提示文本
  String _getThemeModeTooltip(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return '当前：跟随系统\n点击切换到浅色主题';
      case ThemeMode.light:
        return '当前：浅色主题\n点击切换到深色主题';
      case ThemeMode.dark:
        return '当前：深色主题\n点击切换到跟随系统';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompactMode = ref.watch(isCompactModeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Scrcpy GUI By',
              style: TextStyle(
                fontSize: isCompactMode ? LayoutSizes.titleFontSizeCompact : LayoutSizes.titleFontSize,
              ),
            ),
            BreathGlowWidget(
              controller: _breathGlowController,
              glowColor: Theme.of(context).primaryColor,
              child: TextButton(
                onPressed: () {},
                child: Text(
                  'blueisboy',
                  style: TextStyle(
                    fontSize: isCompactMode ? LayoutSizes.titleFontSizeCompact : LayoutSizes.titleFontSize,
                  ),
                ),
              ),
            ),
          ],
        ),
        toolbarHeight: isCompactMode ? LayoutSizes.toolbarHeightCompact : LayoutSizes.toolbarHeight,
        actions: [
          IconButton(
            icon: Icon(
              _getThemeModeIcon(themeMode),
              size: isCompactMode ? LayoutSizes.iconSizeCompact : LayoutSizes.iconSize,
            ),
            onPressed: _toggleThemeMode,
            tooltip: _getThemeModeTooltip(themeMode),
            padding: EdgeInsets.symmetric(
              horizontal: isCompactMode ? LayoutSizes.buttonPaddingCompact : LayoutSizes.buttonPadding,
            ),
            constraints: BoxConstraints(
              minWidth: isCompactMode ? LayoutSizes.buttonMinSizeCompact : LayoutSizes.buttonMinSize,
              minHeight: isCompactMode ? LayoutSizes.buttonMinSizeCompact : LayoutSizes.buttonMinSize,
            ),
          ),
          IconButton(
            icon: Icon(
              isCompactMode ? Icons.expand : Icons.compress,
              size: isCompactMode ? LayoutSizes.iconSizeCompact : LayoutSizes.iconSize,
            ),
            onPressed: _toggleCompactMode,
            tooltip: isCompactMode ? '切换到舒适模式' : '切换到紧凑模式',
            padding: EdgeInsets.symmetric(
              horizontal: isCompactMode ? LayoutSizes.buttonPaddingCompact : LayoutSizes.buttonPadding,
            ),
            constraints: BoxConstraints(
              minWidth: isCompactMode ? LayoutSizes.buttonMinSizeCompact : LayoutSizes.buttonMinSize,
              minHeight: isCompactMode ? LayoutSizes.buttonMinSizeCompact : LayoutSizes.buttonMinSize,
            ),
          ),
          IconButton(
            tooltip: '刷新设备',
            icon: Icon(
              Icons.refresh,
              size: isCompactMode ? LayoutSizes.iconSizeCompact : LayoutSizes.iconSize,
            ),
            onPressed: _refreshDevices,
            padding: EdgeInsets.symmetric(
              horizontal: isCompactMode ? LayoutSizes.buttonPaddingCompact : LayoutSizes.buttonPadding,
            ),
            constraints: BoxConstraints(
              minWidth: isCompactMode ? LayoutSizes.buttonMinSizeCompact : LayoutSizes.buttonMinSize,
              minHeight: isCompactMode ? LayoutSizes.buttonMinSizeCompact : LayoutSizes.buttonMinSize,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _devices.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('没有找到已连接的设备'),
                          const SizedBox(height: 16),
                          ElevatedButton(onPressed: _refreshDevices, child: const Text('刷新')),
                        ],
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _devices.length,
                      itemBuilder: (context, index) {
                        final deviceId = _devices[index];
                        return DeviceCard(
                          deviceId: deviceId,
                          onStart: () => _startScrcpy(deviceId),
                          onConfigure: () => _selectDevice(deviceId),
                          isSelected: deviceId == _selectedDeviceId,
                          isCompact: isCompactMode,
                        ).animate().fadeIn().slideX();
                      },
                    ),
          const SizedBox(height: 8),
          Expanded(
            child: _selectedDeviceId == null
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('请选择一个设备进行配置'),
                        SizedBox(height: 16),
                      ],
                    ),
                  )
                : IndexedStack(
                    index: _devices.indexOf(_selectedDeviceId!),
                    children: _devices.map((deviceId) {
                      final config = _configService.getDeviceConfig(deviceId) ?? DeviceConfig(deviceId: deviceId);
                      return DeviceConfigDialog(
                        key: ValueKey(deviceId),
                        config: config,
                        onSave: _saveConfig,
                        isCompact: isCompactMode,
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  // 切换显示模式
  Future<void> _toggleCompactMode() async {
    final currentMode = ref.read(isCompactModeProvider);
    final newMode = !currentMode;
    ref.read(isCompactModeProvider.notifier).state = newMode;
    await _configService.saveCompactMode(newMode);
  }
}

class DeviceCard extends StatefulWidget {
  final String deviceId;
  final Future<void> Function() onStart;
  final VoidCallback onConfigure;
  final bool isSelected;
  final bool isCompact;

  const DeviceCard({
    super.key,
    required this.deviceId,
    required this.onStart,
    required this.onConfigure,
    required this.isSelected,
    this.isCompact = false,
  });

  @override
  State<DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  bool _isRunning = false;

  Future<void> _handleStart() async {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
    });

    try {
      await widget.onStart();
    } finally {
      if (mounted) {
        setState(() {
          _isRunning = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: widget.isCompact ? LayoutSizes.cardMarginCompact : LayoutSizes.cardMargin,
        vertical: widget.isCompact ? LayoutSizes.verticalSpacingCompact : LayoutSizes.verticalSpacing,
      ),
      color: widget.isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: widget.onConfigure,
        child: ListTile(
          dense: widget.isCompact,
          contentPadding: EdgeInsets.symmetric(
            horizontal: widget.isCompact ? LayoutSizes.cardPaddingCompact : LayoutSizes.cardPadding,
            vertical: widget.isCompact ? LayoutSizes.verticalSpacingCompact : LayoutSizes.verticalSpacing,
          ),
          title: Text(
            widget.deviceId,
            style: widget.isCompact ? textTheme.titleMedium : textTheme.titleLarge,
          ),
          trailing: IconButton(
            icon: _isRunning
                ? SizedBox(
                    width: widget.isCompact ? LayoutSizes.iconSizeCompact : LayoutSizes.iconSize,
                    height: widget.isCompact ? LayoutSizes.iconSizeCompact : LayoutSizes.iconSize,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    Icons.play_arrow,
                    size: widget.isCompact ? LayoutSizes.iconSizeCompact : LayoutSizes.iconSize,
                  ),
            onPressed: _isRunning ? null : _handleStart,
          ),
        ),
      ),
    );
  }
}
