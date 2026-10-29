import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 三个 Tab 的外壳（今日 / 记录 / 我的）。
///
/// 使用 `StatefulNavigationShell` 保留各分支的导航栈；
/// 重复点击当前 Tab 时回到该分支根页面。
class AppShell extends StatelessWidget {
  /// 创建外壳。
  const AppShell({required this.navigationShell, super.key});

  /// 分支导航状态。
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: '统计',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
