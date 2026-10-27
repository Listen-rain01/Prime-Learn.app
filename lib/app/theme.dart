import 'package:flutter/material.dart';

/// 应用配色与主题。
///
/// 取色参照 docs/01-login.png：浅灰背景 + 钢蓝主色。
abstract final class AppColors {
  /// 主色（登录按钮）。
  static const Color primary = Color(0xFF2E6E9E);

  /// 主色深一档。
  static const Color primaryDark = Color(0xFF1F5279);

  /// 页面背景。
  static const Color background = Color(0xFFF7F8FA);

  /// 卡片 / 输入框背景。
  static const Color surface = Color(0xFFFFFFFF);

  /// 输入框描边。
  static const Color border = Color(0xFFB7C4D1);

  /// 主文字色。
  static const Color textPrimary = Color(0xFF1F2933);

  /// 次要文字色。
  static const Color textSecondary = Color(0xFF6B7683);

  /// 错误提示色。
  static const Color error = Color(0xFFC0392B);
}

/// 主题装配。
abstract final class AppTheme {
  /// 亮色主题。
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(primary: AppColors.primary);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}
