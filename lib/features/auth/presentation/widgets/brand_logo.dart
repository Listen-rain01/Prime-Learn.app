import 'package:flutter/material.dart';

/// 品牌标识：Flutter 图标 + 蓝色渐变（对齐 docs/01-login.png）。
class BrandLogo extends StatelessWidget {
  /// 创建品牌标识。
  const BrandLogo({super.key, this.size = 96});

  /// 图标边长。
  final double size;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF4FC3F7), Color(0xFF0288D1), Color(0xFF01579B)],
        stops: [0, 0.55, 1],
      ).createShader(bounds),
      blendMode: BlendMode.srcATop,
      child: Icon(Icons.flutter_dash, size: size, color: Colors.white),
    );
  }
}
