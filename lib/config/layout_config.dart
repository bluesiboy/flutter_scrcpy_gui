import 'package:flutter/material.dart';

/// 布局配置类
/// 用于统一管理应用程序的布局配置
class LayoutConfig {
  /// 标题字体大小
  final double titleFontSize;

  /// 工具栏高度
  final double toolbarHeight;

  /// 图标大小
  final double iconSize;

  /// 按钮内边距
  final double buttonPadding;

  /// 按钮最小尺寸
  final double buttonMinSize;

  /// 卡片外边距
  final double cardMargin;

  /// 卡片内边距
  final double cardPadding;

  /// 垂直间距
  final double verticalSpacing;

  /// 水平间距
  final double horizontalSpacing;

  /// 表单字段内边距
  final EdgeInsets formFieldPadding;

  /// 分隔线高度
  final double dividerHeight;

  /// 开关缩放比例
  final double switchScale;

  /// 视觉密度
  final VisualDensity visualDensity;

  /// 构造函数
  const LayoutConfig({
    required this.titleFontSize,
    required this.toolbarHeight,
    required this.iconSize,
    required this.buttonPadding,
    required this.buttonMinSize,
    required this.cardMargin,
    required this.cardPadding,
    required this.verticalSpacing,
    required this.horizontalSpacing,
    required this.formFieldPadding,
    required this.dividerHeight,
    required this.switchScale,
    required this.visualDensity,
  });

  /// 舒适模式配置
  static const LayoutConfig comfortable = LayoutConfig(
    titleFontSize: 20.0,
    toolbarHeight: 56.0,
    iconSize: 24.0,
    buttonPadding: 12.0,
    buttonMinSize: 48.0,
    cardMargin: 16.0,
    cardPadding: 16.0,
    verticalSpacing: 8.0,
    horizontalSpacing: 8.0,
    formFieldPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    dividerHeight: 1.0,
    switchScale: 1.0,
    visualDensity: VisualDensity.standard,
  );

  /// 紧凑模式配置
  static const LayoutConfig compact = LayoutConfig(
    titleFontSize: 16.0,
    toolbarHeight: 40.0,
    iconSize: 20.0,
    buttonPadding: 8.0,
    buttonMinSize: 32.0,
    cardMargin: 8.0,
    cardPadding: 8.0,
    verticalSpacing: 4.0,
    horizontalSpacing: 4.0,
    formFieldPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
    dividerHeight: 0.5,
    switchScale: 0.7,
    visualDensity: VisualDensity.compact,
  );

  /// 根据是否紧凑模式获取对应的配置
  static LayoutConfig getConfig(bool isCompact) {
    return isCompact ? compact : comfortable;
  }
}
