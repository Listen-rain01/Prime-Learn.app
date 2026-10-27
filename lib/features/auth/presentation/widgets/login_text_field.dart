import 'package:flutter/material.dart';
import 'package:primelearn/app/theme.dart';

/// 登录页输入框：左侧图标 + 可选右侧操作。
class LoginTextField extends StatelessWidget {
  /// 创建输入框。
  const LoginTextField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    super.key,
  });

  /// 文本控制器。
  final TextEditingController controller;

  /// 占位提示。
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

  /// 输入变化回调。
  final ValueChanged<String>? onChanged;

  /// 提交回调。
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          fontSize: 16,
          color: AppColors.textSecondary,
        ),
        prefixIcon: Icon(icon, size: 22, color: AppColors.textSecondary),
        suffixIcon: suffix,
      ),
    );
  }
}
