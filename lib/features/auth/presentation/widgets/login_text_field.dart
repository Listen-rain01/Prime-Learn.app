import 'package:flutter/material.dart';

/// 登录页输入框（规格 §3.3）。
///
/// 两个输入框共用一个 decoration：12dp 圆角、primary 描边、无填充、
/// 水平 16dp / 垂直 18dp 内边距、浮动 label 为 primary。
class LoginTextField extends StatelessWidget {
  /// 创建输入框。
  const LoginTextField({
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
    this.maxLength,
    this.enabled = true,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    super.key,
  });

  /// 文本控制器。
  final TextEditingController controller;

  /// 浮动标签。
  final String labelText;

  /// 提示文字。
  final String hintText;

  /// 左侧图标。
  final IconData icon;

  /// 是否密文。
  final bool obscureText;

  /// 右侧附加组件。
  final Widget? suffix;

  /// 键盘类型。
  final TextInputType? keyboardType;

  /// 键盘动作键。
  final TextInputAction? textInputAction;

  /// 最大长度。
  final int? maxLength;

  /// 是否可用（加载中禁用）。
  final bool enabled;

  /// 字段级错误文案；非空时显示红色描边与提示。
  final String? errorText;

  /// 输入变化回调。
  final ValueChanged<String>? onChanged;

  /// 提交回调。
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: scheme.primary),
    );
    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: scheme.error),
    );

    return TextField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLength: maxLength,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: textTheme.bodyMedium?.copyWith(
        fontSize: 15,
        color: scheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        errorText: errorText,
        counterText: '',
        filled: false,
        border: border,
        enabledBorder: border,
        focusedBorder: border,
        disabledBorder: border,
        errorBorder: errorBorder,
        focusedErrorBorder: errorBorder,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        floatingLabelStyle: TextStyle(color: scheme.primary),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        prefixIcon: Icon(icon, color: scheme.onSurfaceVariant),
        suffixIcon: suffix,
      ),
    );
  }
}
