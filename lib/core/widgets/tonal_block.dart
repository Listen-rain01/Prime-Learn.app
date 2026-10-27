import 'package:flutter/material.dart';

/// 跨 feature 的设计系统基元：Tonal 分组块。
///
/// `surfaceContainerLow` 背景、20dp 圆角、无阴影、无边框；
/// 同一页面内分组块间距 16dp。
class TonalBlock extends StatelessWidget {
  /// 创建分组块。
  const TonalBlock({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    super.key,
  });

  /// 内容。
  final Widget child;

  /// 内边距。
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}
