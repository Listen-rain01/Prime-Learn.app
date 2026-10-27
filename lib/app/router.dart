import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:primelearn/app/app_shell.dart';
import 'package:primelearn/core/session/session_store.dart';
import 'package:primelearn/features/auth/presentation/pages/login_page.dart';
import 'package:primelearn/features/records/presentation/pages/records_page.dart';
import 'package:primelearn/features/settings/presentation/pages/bank_preset_page.dart';
import 'package:primelearn/features/settings/presentation/pages/settings_page.dart';
import 'package:primelearn/features/tasks/presentation/pages/today_page.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router.g.dart';

/// 登录路由（在 shell 之外）。
@TypedGoRoute<LoginRoute>(path: '/login')
class LoginRoute extends GoRouteData with $LoginRoute {
  /// 创建登录路由。
  const LoginRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const LoginPage();
}

/// 三个 Tab 的 shell：今日 / 记录 / 我的。
@TypedStatefulShellRoute<AppShellRouteData>(
  branches: <TypedStatefulShellBranch<StatefulShellBranchData>>[
    TypedStatefulShellBranch<TodayBranchData>(
      routes: <TypedRoute<RouteData>>[TypedGoRoute<TodayRoute>(path: '/')],
    ),
    TypedStatefulShellBranch<RecordsBranchData>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<RecordsRoute>(path: '/records'),
      ],
    ),
    TypedStatefulShellBranch<SettingsBranchData>(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<SettingsRoute>(
          path: '/settings',
          routes: <TypedRoute<RouteData>>[
            TypedGoRoute<BankPresetRoute>(path: 'bank-preset'),
          ],
        ),
      ],
    ),
  ],
)
class AppShellRouteData extends StatefulShellRouteData {
  /// 创建 shell 路由。
  const AppShellRouteData();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) => AppShell(navigationShell: navigationShell);
}

/// 今日分支。
class TodayBranchData extends StatefulShellBranchData {
  /// 创建今日分支。
  const TodayBranchData();
}

/// 记录分支。
class RecordsBranchData extends StatefulShellBranchData {
  /// 创建记录分支。
  const RecordsBranchData();
}

/// 我的分支。
class SettingsBranchData extends StatefulShellBranchData {
  /// 创建我的分支。
  const SettingsBranchData();
}

/// 今日 Tab。
class TodayRoute extends GoRouteData with $TodayRoute {
  /// 创建今日路由。
  const TodayRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const TodayPage();
}

/// 记录 Tab。
class RecordsRoute extends GoRouteData with $RecordsRoute {
  /// 创建记录路由。
  const RecordsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const RecordsPage();
}

/// 我的 Tab。
class SettingsRoute extends GoRouteData with $SettingsRoute {
  /// 创建我的路由。
  const SettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SettingsPage();
}

/// 题库预设（「我的」分支内 push）。
class BankPresetRoute extends GoRouteData with $BankPresetRoute {
  /// 创建题库预设路由。
  const BankPresetRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const BankPresetPage();
}

/// 全局路由。
@Riverpod(keepAlive: true)
Raw<GoRouter> router(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    routes: $appRoutes,
    redirect: (context, state) {
      final loggedIn = ref.read(sessionStoreProvider) != null;
      final atLogin = state.matchedLocation == '/login';
      if (!loggedIn) return atLogin ? null : '/login';
      if (atLogin) return '/';
      return null;
    },
    errorBuilder: (context, state) =>
        _RouteErrorPage(message: state.error?.toString()),
  );
}

class _RouteErrorPage extends StatelessWidget {
  const _RouteErrorPage({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.link_off, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              const Text('页面不存在'),
              if (message != null) ...[
                const SizedBox(height: 8),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
