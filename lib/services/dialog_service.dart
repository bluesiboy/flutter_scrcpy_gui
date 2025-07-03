import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

class DialogService {
  static final DialogService _instance = DialogService._internal();
  factory DialogService() => _instance;
  DialogService._internal();

  /// 显示玻璃态输入弹框
  static Future<T?> showGlassInputDialog<T>({
    required BuildContext context,
    required String title,
    required TextEditingController controller,
    String hintText = '',
    int maxLines = 1,
    int maxLength = 50,
    String? Function(String?)? validator,
    List<Widget>? actions,
  }) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final inputContent = Container(
      height: maxLines == 1 ? 80 : 160,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: isDark ? Colors.white54 : Colors.black54,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDark ? Colors.white24 : Colors.black26,
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDark ? Colors.white24 : Colors.black26,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.blue,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.1),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          counterStyle: TextStyle(
            color: isDark ? Colors.white54 : Colors.black54,
            fontSize: 12,
          ),
        ),
        maxLines: maxLines,
        maxLength: maxLength,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 14,
        ),
      ),
    );

    return showGlassDialog<T>(
      context: context,
      title: title,
      content: inputContent,
      actions: actions ??
          [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('确定'),
            ),
          ],
    );
  }

  /// 显示玻璃态选择弹框
  static Future<T?> showGlassSelectionDialog<T>({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) async {
    return showGlassDialog<T>(
      context: context,
      title: title,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  /// 显示玻璃态头像选择弹框
  static Future<String?> showAvatarSelectionDialog({
    required BuildContext context,
    required List<String> avatarFiles,
    required String? selectedAvatar,
  }) async {
    final avatarContent = GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: avatarFiles.length,
      itemBuilder: (ctx, i) {
        final avatar = avatarFiles[i];
        return GestureDetector(
          onTap: () {
            Navigator.pop(context, avatar);
          },
          child: CircleAvatar(
            backgroundImage: AssetImage(avatar),
            radius: 32,
            child: selectedAvatar == avatar
                ? Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blueAccent, width: 3),
                    ),
                  )
                : null,
          ),
        );
      },
    );

    return showGlassDialog<String>(
      context: context,
      title: null,
      content: avatarContent,
      padding: EdgeInsets.zero,
      showTitle: false,
      scrollable: false,
    );
  }

  /// 显示通用玻璃态弹框 - 支持任意Widget内容
  static Future<T?> showGlassDialog<T>({
    required BuildContext context,
    String? title,
    required Widget content,
    List<Widget>? actions,
    double? width,
    EdgeInsets? padding,
    bool showTitle = true,
    bool scrollable = false,
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
    bool useSafeArea = true,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
  }) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor ?? Colors.black.withOpacity(0.3),
      barrierLabel: barrierLabel,
      useSafeArea: useSafeArea,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: _AdaptiveGlassDialog(
          title: title,
          content: content,
          actions: actions,
          width: width,
          padding: padding,
          showTitle: showTitle,
          scrollable: scrollable,
          isDark: isDark,
        ),
      ),
    );
  }

  /// 显示简单的玻璃态弹框 - 无标题，只有内容
  static Future<T?> showSimpleGlassDialog<T>({
    required BuildContext context,
    required Widget content,
    List<Widget>? actions,
    double? width,
    EdgeInsets? padding,
    bool scrollable = true,
    bool barrierDismissible = true,
  }) async {
    return showGlassDialog<T>(
      context: context,
      title: null,
      content: content,
      actions: actions,
      width: width,
      padding: padding,
      showTitle: false,
      scrollable: scrollable,
      barrierDismissible: barrierDismissible,
    );
  }

  /// 显示全屏玻璃态弹框
  static Future<T?> showFullScreenGlassDialog<T>({
    required BuildContext context,
    String? title,
    required Widget content,
    List<Widget>? actions,
    EdgeInsets? padding,
    bool showTitle = true,
    bool scrollable = true,
    bool barrierDismissible = true,
  }) async {
    final screenSize = MediaQuery.of(context).size;
    return showGlassDialog<T>(
      context: context,
      title: title,
      content: content,
      actions: actions,
      width: screenSize.width * 0.9,
      padding: padding,
      showTitle: showTitle,
      scrollable: scrollable,
      barrierDismissible: barrierDismissible,
    );
  }
}

class _AdaptiveGlassDialog extends StatefulWidget {
  final String? title;
  final Widget content;
  final List<Widget>? actions;
  final double? width;
  final EdgeInsets? padding;
  final bool showTitle;
  final bool scrollable;
  final bool isDark;

  const _AdaptiveGlassDialog({
    Key? key,
    this.title,
    required this.content,
    this.actions,
    this.width,
    this.padding,
    this.showTitle = true,
    this.scrollable = false,
    required this.isDark,
  }) : super(key: key);

  @override
  State<_AdaptiveGlassDialog> createState() => _AdaptiveGlassDialogState();
}

class _AdaptiveGlassDialogState extends State<_AdaptiveGlassDialog> {
  double? _contentHeight;
  final GlobalKey _contentKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  void _measure() {
    final context = _contentKey.currentContext;
    if (context != null) {
      final box = context.findRenderObject() as RenderBox?;
      if (box != null && mounted) {
        final h = box.size.height;
        if (_contentHeight == null || (_contentHeight! - h).abs() > 1) {
          setState(() {
            _contentHeight = h;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.95;
    // 计算额外高度：标题、actions、SizedBox、padding
    final double extraHeight = (widget.showTitle && widget.title != null ? 34 : 0) +
        (widget.actions != null && widget.actions!.isNotEmpty ? 64 : 0) + // 48+16
        (widget.padding?.vertical ?? 40); // 默认上下各20
    final double totalHeight = (_contentHeight ?? 150) + extraHeight;
    return GlassmorphicContainer(
      width: widget.width ?? 320,
      height: totalHeight.clamp(100, maxHeight),
      borderRadius: 20,
      blur: 18,
      border: 1.2,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.36),
          Colors.white.withOpacity(0.22),
        ],
        stops: const [0.1, 1],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.45),
          Colors.white.withOpacity(0.32),
        ],
      ),
      child: Padding(
        padding: widget.padding ?? const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showTitle && widget.title != null) ...[
              Text(
                widget.title!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: widget.isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
            ],
            Container(
              key: _contentKey,
              child: Center(
                child: widget.scrollable ? SingleChildScrollView(child: widget.content) : widget.content,
              ),
            ),
            if (widget.actions != null && widget.actions!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: widget.actions!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
