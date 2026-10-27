import 'package:flutter/material.dart';

/// 应用主题（当前视觉基线）。
///
/// Material 3、seed `Colors.blue`、亮/暗色均使用 `ColorScheme.fromSeed`、
/// 主题模式跟随系统；页面背景使用 `colorScheme.surface`。
abstract final class AppTheme {
  static const Color _seed = Colors.blue;

  /// 亮色主题。
  static ThemeData light() =>
      ThemeData(useMaterial3: true, colorSchemeSeed: _seed);

  /// 暗色主题。
  static ThemeData dark() => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: _seed,
    brightness: Brightness.dark,
  );
}
