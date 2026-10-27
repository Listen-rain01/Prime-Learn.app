import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primelearn/app/app.dart';

/// 应用入口。
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 规格 §1.1：edge-to-edge，状态栏/系统栏图标跟随亮暗主题。
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const ProviderScope(child: PrimeLearnApp()));
}
