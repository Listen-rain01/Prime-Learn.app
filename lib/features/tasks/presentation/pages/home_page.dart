import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primelearn/app/router.dart';
import 'package:primelearn/core/network/api_client.dart';
import 'package:primelearn/core/session/session_store.dart';
import 'package:primelearn/core/widgets/tonal_block.dart';
import 'package:primelearn/features/auth/presentation/providers/login_notifier.dart';

/// 首页（指挥台）。
///
/// 目前只展示会话信息与占位结构；完整视觉见 docs/ui/PURE_UI_SPEC.md §4，
/// 待今日任务接口接入后按规格补齐。
class HomePage extends ConsumerWidget {
  /// 创建首页。
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final session = ref.watch(sessionStoreProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            TonalBlock(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          session == null ? '未登录' : session.userName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Row(
                        children: [
                          Icon(
                            Icons.stars_rounded,
                            size: 20,
                            color: scheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '今日积分',
                            style: textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '—',
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1,
                              color: scheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '当前题库：${session?.bankName ?? '未设置'}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TonalBlock(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '每日任务',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '0/0 已完成',
                        style: textTheme.labelMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      '今日任务接口尚未接入',
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TonalBlock(
              padding: EdgeInsets.zero,
              child: SizedBox(
                height: 56,
                width: double.infinity,
                child: TextButton(
                  onPressed: () async {
                    await ref.read(apiClientProvider).clearCookies();
                    ref.read(sessionStoreProvider.notifier).clear();
                    ref.read(loginProvider.notifier).reset();
                    if (context.mounted) {
                      const LoginRoute().go(context);
                    }
                  },
                  child: Text(
                    '退出登录',
                    style: textTheme.labelLarge?.copyWith(color: scheme.error),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
