import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primelearn/app/router.dart';
import 'package:primelearn/app/theme.dart';
import 'package:primelearn/core/session/session.dart';
import 'package:primelearn/core/session/session_store.dart';

/// 应用根组件。
class PrimeLearnApp extends ConsumerWidget {
  /// 创建应用根组件。
  const PrimeLearnApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 会话被清理（退出登录 / 会话失效）时统一回到登录页（§8.11）。
    ref.listen<Session?>(sessionStoreProvider, (previous, next) {
      if (previous != null && next == null) {
        ref.read(routerProvider).go(const LoginRoute().location);
      }
    });

    return MaterialApp.router(
      title: 'Prime Learn',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
