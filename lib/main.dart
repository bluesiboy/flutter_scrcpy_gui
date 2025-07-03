import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_scrcpy_gui/services/adb_service.dart';
import 'package:flutter_scrcpy_gui/services/config_service.dart';
import 'package:flutter_scrcpy_gui/models/device_config.dart';
import 'package:flutter_scrcpy_gui/services/dialog_service.dart';
import 'package:flutter_scrcpy_gui/widgets/breath_glow_widget.dart';
import 'package:flutter_scrcpy_gui/widgets/device_config_dialog.dart';
import 'package:flutter_scrcpy_gui/widgets/device_card.dart';
import 'package:flutter_scrcpy_gui/config/layout_config.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_scrcpy_gui/models/path_history.dart';

// 定义一个Riverpod StateProvider来管理紧凑模式状态
final isCompactModeProvider = StateProvider<bool>((ref) => false); // 默认为舒适模式 (false)

// 定义一个Riverpod StateProvider来管理主题模式
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system); // 默认为跟随系统

// 定义一个Riverpod Provider来获取当前布局配置
final layoutConfigProvider = Provider<LayoutConfig>((ref) {
  final isCompact = ref.watch(isCompactModeProvider);
  return LayoutConfig.getConfig(isCompact);
});

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
  late final ConfigService _configService;
  DeviceConfig? currentSelectedConfig;

  @override
  void initState() {
    super.initState();
    _configService = ConfigService(widget.prefs);
    // 使用 Future.microtask 来确保在构建完成后更新状态
    Future.microtask(() {
      if (mounted) {
        ref.read(isCompactModeProvider.notifier).state = widget.initialCompactMode;
        ref.read(themeModeProvider.notifier).state = _configService.getThemeMode();
      }
    });
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

  @override
  Widget build(BuildContext context) {
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
      builder: FlutterSmartDialog.init(),
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
  List<Map<String, String>> _devices = [];
  String? _selectedDeviceId;
  String? _selectedDeviceSerial;
  Map<String, String?> _deviceIdToSerial = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _configService = ConfigService(widget.prefs);
    _adbService = AdbService(configService: _configService);
    _breathGlowController = BreathGlowController(breathCount: 100);
    _breathGlowController.start();

    // 初始化 scrcpy/adb 路径历史
    PathHistory.clear();
    final deviceIds = _configService.getAllDeviceIds();
    for (final id in deviceIds) {
      final config = _configService.getDeviceConfig(id);
      if (config != null) {
        PathHistory.addScrcpyPath(config.scrcpyPath);
        PathHistory.addAdbPath(config.adbPath);
      }
    }
    // 扫描环境变量
    PathHistory.scanExecutablesFromEnv().then((_) {
      setState(() {}); // 触发菜单刷新
    });
    _refreshDevices();
  }

  @override
  void dispose() {
    _breathGlowController.dispose();
    super.dispose();
  }

  Future<void> _refreshDevices() async {
    setState(() => _isLoading = true);
    try {
      final devices = await _adbService.getConnectedDevices();
      final serials = await Future.wait(devices.map((device) => _adbService.getDeviceSerial(device['id']!)));
      // 获取所有设备的序列号
      _deviceIdToSerial.clear();
      for (int i = 0; i < devices.length; i++) {
        final id = devices[i]['id']!;
        final serial = serials[i];
        _deviceIdToSerial[id] = serial;
      }
      setState(() {
        _devices = devices;
        _isLoading = false;
        if (_selectedDeviceId == null || !devices.any((d) => d['id'] == _selectedDeviceId)) {
          _selectedDeviceId = devices.isNotEmpty ? devices.first['id'] : null;
          _selectedDeviceSerial = _selectedDeviceId != null ? _deviceIdToSerial[_selectedDeviceId!] : null;
        }
      });
    } catch (e) {
      if (mounted && e is ProcessException) {
        SmartDialog.showToast(e.message);
      }
      setState(() => _isLoading = false);
      // 弹窗让用户填写adb 地址
      final TextEditingController controller = TextEditingController();

      if (!mounted) return;

      final result = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('ADB 路径配置'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('请输入 ADB 可执行文件路径：'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          hintText: 'ADB 可执行文件路径',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () async {
                        SmartDialog.showLoading(msg: '请等待...');
                        await Future.delayed(const Duration(milliseconds: 1500)); // 给UI一个短暂的时间来显示加载动画
                        try {
                          final result = await Future.microtask(() => FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: Platform.isWindows ? ['exe'] : null,
                                allowMultiple: false,
                              ));

                          if (result != null && result.files.isNotEmpty) {
                            controller.text = result.files.first.path!;
                          }
                        } finally {
                          SmartDialog.dismiss();
                        }
                      },
                      icon: const Icon(Icons.folder_open),
                      tooltip: '浏览文件',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  '提示：\n'
                  '通常情况下，scrcpy 随机附带 adb 文件\n',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () async {
                  final path = controller.text.trim();
                  if (path.isEmpty) {
                    SmartDialog.showToast('请选择 ADB 可执行文件');
                    return;
                  }

                  final file = File(path);
                  if (!await file.exists()) {
                    SmartDialog.showToast('指定的文件不存在');
                    return;
                  }

                  _adbService.adbPath = path;
                  await _configService.saveAdbPath(path);
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: const Text('确定'),
              ),
            ],
          );
        },
      );

      if (result != null) {
        _refreshDevices();
      }
    }
  }

  Future<void> _startScrcpy(String deviceId) async {
    final serial = _deviceIdToSerial[deviceId];
    final config = serial != null
        ? (_configService.getDeviceConfig(serial) ?? DeviceConfig(deviceId: serial))
        : DeviceConfig(deviceId: deviceId);
    try {
      await _adbService.startScrcpy(deviceId, config.toJson());
    } catch (e) {
      if (mounted) SmartDialog.showToast(e.toString());
    }
  }

  void _selectDevice(String deviceId) {
    setState(() {
      _selectedDeviceId = deviceId;
      _selectedDeviceSerial = _deviceIdToSerial[deviceId];
    });
  }

  Future<void> _saveConfig(DeviceConfig config) async {
    // 保存时用serial作为key
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
    final themeMode = ref.watch(themeModeProvider);
    final layoutConfig = ref.watch(layoutConfigProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Scrcpy GUI By',
              style: TextStyle(
                fontSize: layoutConfig.titleFontSize,
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
                    fontSize: layoutConfig.titleFontSize,
                  ),
                ),
              ),
            ),
          ],
        ),
        toolbarHeight: layoutConfig.toolbarHeight,
        actions: [
          IconButton(
            icon: Icon(_getThemeModeIcon(themeMode), size: layoutConfig.iconSize),
            onPressed: _toggleThemeMode,
            tooltip: _getThemeModeTooltip(themeMode),
            padding: EdgeInsets.symmetric(
              horizontal: layoutConfig.buttonPadding,
            ),
            constraints: BoxConstraints(
              minWidth: layoutConfig.buttonMinSize,
              minHeight: layoutConfig.buttonMinSize,
            ),
          ),
          IconButton(
            icon: Icon(layoutConfig.displayMode, size: layoutConfig.iconSize),
            onPressed: _toggleCompactMode,
            tooltip: layoutConfig.displayModelTooltip,
            padding: EdgeInsets.symmetric(
              horizontal: layoutConfig.buttonPadding,
            ),
            constraints: BoxConstraints(
              minWidth: layoutConfig.buttonMinSize,
              minHeight: layoutConfig.buttonMinSize,
            ),
          ),
          IconButton(
            tooltip: '刷新设备',
            icon: Icon(Icons.refresh, size: layoutConfig.iconSize),
            onPressed: _refreshDevices,
            padding: EdgeInsets.symmetric(
              horizontal: layoutConfig.buttonPadding,
            ),
            constraints: BoxConstraints(
              minWidth: layoutConfig.buttonMinSize,
              minHeight: layoutConfig.buttonMinSize,
            ),
          ),
          IconButton(
            tooltip: '打赏支持',
            icon: Icon(Icons.favorite, size: layoutConfig.iconSize, color: Colors.red),
            onPressed: () => _showDonateDialog(context),
            padding: EdgeInsets.symmetric(
              horizontal: layoutConfig.buttonPadding,
            ),
            constraints: BoxConstraints(
              minWidth: layoutConfig.buttonMinSize,
              minHeight: layoutConfig.buttonMinSize,
            ),
          ),
          IconButton(
            tooltip: '帮助',
            icon: Icon(Icons.help_outline, size: layoutConfig.iconSize),
            onPressed: () => _showHelpDialog(context),
            padding: EdgeInsets.symmetric(
              horizontal: layoutConfig.buttonPadding,
            ),
            constraints: BoxConstraints(
              minWidth: layoutConfig.buttonMinSize,
              minHeight: layoutConfig.buttonMinSize,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _devices.isEmpty
                  ? Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('没有找到已连接的设备'),
                            const SizedBox(height: 16),
                            ElevatedButton(onPressed: _refreshDevices, child: const Text('刷新')),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _devices.length,
                      itemBuilder: (context, index) {
                        final device = _devices[index];
                        final deviceId = device['id']!;
                        final deviceState = device['state']!;
                        final serial = _deviceIdToSerial[deviceId];
                        String statusText;
                        bool canConnect = false;

                        switch (deviceState) {
                          case 'device':
                            statusText = '设备已连接并已授权';
                            canConnect = true;
                            break;
                          case 'unauthorized':
                            statusText = '设备已连接但未授权，请在设备上确认授权';
                            break;
                          case 'offline':
                            statusText = '设备已连接但处于离线状态';
                            break;
                          default:
                            statusText = '设备状态未知';
                        }

                        return DeviceCard(
                          deviceId: deviceId,
                          statusText: statusText,
                          deviceState: deviceState,
                          canConnect: canConnect,
                          onStart: canConnect ? (id) => _startScrcpy(id) : null,
                          onSelect: (id) => _selectDevice(id),
                          onConfigChanged: (config) => _saveConfig(config),
                          config: serial != null
                              ? (_configService.getDeviceConfig(serial) ?? DeviceConfig(deviceId: serial))
                              : DeviceConfig(deviceId: deviceId),
                          isSelected: deviceId == _selectedDeviceId,
                          isCompact: layoutConfig.isCompact,
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
                    index: _devices.indexWhere((d) => d['id'] == _selectedDeviceId),
                    children: _devices.map((device) {
                      final deviceId = device['id']!;
                      final serial = _deviceIdToSerial[deviceId];
                      final config = serial != null
                          ? (_configService.getDeviceConfig(serial) ?? DeviceConfig(deviceId: serial))
                          : DeviceConfig(deviceId: deviceId);
                      return DeviceConfigDialog(
                        key: ValueKey(deviceId),
                        config: config,
                        onSave: _saveConfig,
                        isCompact: layoutConfig.isCompact,
                        configService: _configService,
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

  // 显示打赏弹窗
  void _showDonateDialog(BuildContext context) {
    final layoutConfig = ref.watch(layoutConfigProvider);
    final isSmallScreen = MediaQuery.of(context).size.width <= 600 && !layoutConfig.isCompact;
    final imageSize = layoutConfig.isCompact ? 120.0 : 180.0;

    DialogService.showGlassDialog(
      width: MediaQuery.of(context).size.width - 20,
      context: context,
      content: Container(
        // width: isSmallScreen ? MediaQuery.of(context).size.width - 10 : null,
        padding: isSmallScreen
            ? const EdgeInsets.symmetric(horizontal: 10, vertical: 20)
            : const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        // padding: const EdgeInsets.all(24),
        // constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '感谢您的支持！',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '如果您觉得这个工具对您有帮助，\n欢迎打赏支持作者继续开发！',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 24,
              runSpacing: 24,
              alignment: WrapAlignment.center,
              children: [
                Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/attachs/wechat_pay.png',
                        width: imageSize,
                        height: imageSize,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('微信支付'),
                  ],
                ),
                Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/attachs/ali_pay.png',
                        width: imageSize,
                        height: imageSize,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('支付宝'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              '您的每一份支持都是我继续前进的动力！',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('关闭'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // 显示帮助对话框
  void _showHelpDialog(BuildContext context) {
    final layoutConfig = ref.watch(layoutConfigProvider);
    final isSmallScreen = MediaQuery.of(context).size.width <= 600 && !layoutConfig.isCompact;
    final modKey = Platform.isWindows
        ? "Alt"
        : Platform.isMacOS
            ? "Command"
            : "Super";

    DialogService.showGlassDialog(
      scrollable: true,
      context: context,
      content: Container(
        padding: isSmallScreen
            ? const EdgeInsets.symmetric(horizontal: 10, vertical: 20)
            : const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 800),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.help_outline, size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    'Scrcpy 使用帮助',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildHelpSection(
                '基本操作',
                [
                  '• 点击设备卡片上的"启动"按钮开始投屏',
                  '• 启动后，scrcpy 窗口会自动打开',
                  '• 在 scrcpy 窗口中：',
                  '  - 使用鼠标点击和拖动来操作设备',
                  '  - 使用键盘输入文字',
                  '  - 使用快捷键控制投屏（见下方说明）',
                ],
              ),
              _buildHelpSection(
                '快捷键说明',
                [
                  '注意：以下快捷键需要在 scrcpy 窗口激活时使用',
                  '（点击 scrcpy 窗口使其获得焦点）',
                  '',
                  'Mod 键说明：',
                  '• Windows 系统：使用 $modKey 键',
                  '• macOS 系统：使用 Command 键',
                  '• Linux 系统：使用 Super 键',
                  '',
                  '基本操作：',
                  '• $modKey + c：复制设备剪贴板到电脑',
                  '• $modKey + v：粘贴电脑剪贴板到设备',
                  '• $modKey + f：切换全屏模式',
                  '• $modKey + q：退出',
                  '',
                  '显示控制：',
                  '• $modKey + h：显示/隐藏控制面板',
                  '• $modKey + r：旋转屏幕',
                  '• $modKey + s：切换显示状态栏',
                  '• $modKey + n：切换显示通知栏',
                  '• $modKey + t：切换显示触摸点',
                  '• $modKey + m：切换显示鼠标点击',
                  '• $modKey + i：切换显示设备信息',
                  '• $modKey + p：切换显示电源按钮',
                  '• $modKey + w：切换显示窗口边框',
                  '• $modKey + z：切换显示FPS',
                  '',
                  '其他功能：',
                  '• $modKey + x：切换显示触摸点',
                  '• $modKey + b：切换显示黑边',
                  '• $modKey + g：切换显示网格',
                  '• $modKey + d：切换显示调试信息',
                  '• $modKey + k：切换显示键盘',
                  '• $modKey + l：切换显示日志',
                  '• $modKey + u：切换显示USB调试',
                  '• $modKey + y：切换显示系统UI',
                ],
              ),
              _buildHelpSection(
                '小技巧',
                [
                  '• 在配置面板中可以调整投屏质量和性能',
                  '• 可以保存每个设备的独立配置',
                  '• 支持多设备同时投屏',
                  '• 可以调整窗口大小和位置',
                  '• 支持深色/浅色主题切换',
                  '• 支持紧凑/舒适模式切换',
                  '• 如果快捷键不起作用，请确保 scrcpy 窗口处于激活状态',
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('关闭'),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('关闭'),
        ),
      ],
    );
  }

  Widget _buildHelpSection(String title, List<String> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: Text(
                  item,
                  style: const TextStyle(fontSize: 14),
                ),
              )),
        ],
      ),
    );
  }
}
