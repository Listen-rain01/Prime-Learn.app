import 'package:flutter/material.dart';

/// 跨 feature 的设计系统基元：内联提示。
///
/// 替代底部 SnackBar：错误就近显示、不遮挡输入、不自动消失，
/// 并通过 `Semantics(liveRegion: true)` 让读屏器播报。
enum InlineNoticeTone {
  /// 错误：表单提交失败、接口报错。
  error,

  /// 普通说明：加载失败后的补充信息。
  info,

  /// 成功：保存成功等非阻塞反馈。
  success,
}

/// 内联提示条。
class InlineNotice extends StatelessWidget {
  /// 创建内联提示。
  const InlineNotice({
    required this.message,
    this.tone = InlineNoticeTone.error,
    this.icon,
    super.key,
  });

  /// 提示文案。
  final String message;

  /// 语气，决定配色与默认图标。
  final InlineNoticeTone tone;

  /// 自定义图标；为空时按语气取默认图标。
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final (background, foreground, toneIcon) = switch (tone) {
      InlineNoticeTone.error => (
        scheme.errorContainer,
        scheme.onErrorContainer,
        Icons.error_outline,
      ),
      InlineNoticeTone.info => (
        scheme.secondaryContainer,
        scheme.onSecondaryContainer,
        Icons.info_outline,
      ),
      InlineNoticeTone.success => (
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
        Icons.check_circle_outline,
      ),
    };

    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon ?? toneIcon, size: 18, color: foreground),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: textTheme.bodySmall?.copyWith(color: foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
