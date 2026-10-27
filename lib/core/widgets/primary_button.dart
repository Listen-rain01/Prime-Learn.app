import 'package:flutter/material.dart';

/// 登录主按钮（规格 §3.5）。
///
/// 撑满容器宽度、高 50dp、FilledButton、12dp 圆角；
/// 加载时禁用并显示 20×20dp 进度（strokeWidth 2，onPrimary）。
class PrimaryButton extends StatelessWidget {
  /// 创建主按钮。
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.loading = false,
    super.key,
  });

  /// 按钮文案。
  final String label;

  /// 点击回调；为 null 时禁用。
  final VoidCallback? onPressed;

  /// 是否展示加载态。
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 50,
      width: double.infinity,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: loading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: scheme.onPrimary,
                ),
              )
            : Text(
                label,
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                  color: scheme.onPrimary,
                ),
              ),
      ),
    );
  }
}
