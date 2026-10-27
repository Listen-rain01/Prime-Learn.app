import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primelearn/app/router.dart';
import 'package:primelearn/core/network/api_client.dart';
import 'package:primelearn/core/session/session_store.dart';
import 'package:primelearn/core/widgets/tonal_block.dart';
import 'package:primelearn/features/auth/presentation/providers/login_notifier.dart';

/// 我的 Tab：账号信息、设置入口、退出登录。
class SettingsPage extends ConsumerWidget {
  /// 创建我的页。
  const SettingsPage({super.key});

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
                  Text(
                    session?.userName ?? '未登录',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
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
              padding: EdgeInsets.zero,
              // ListTile 的水波纹需要就近 Material；TonalBlock 自带背景色会遮挡，
              // 因此在这里补一层透明 Material。
              child: Material(
                type: MaterialType.transparency,
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.rule_outlined,
                        color: scheme.onSurfaceVariant,
                      ),
                      title: const Text('积分规则'),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: scheme.onSurfaceVariant,
                      ),
                      onTap: () => const RulesRoute().push<void>(context),
                    ),
                    Divider(
                      height: 0.5,
                      thickness: 0.5,
                      indent: 16,
                      endIndent: 16,
                      color: scheme.outlineVariant,
                    ),
                    ListTile(
                      enabled: false,
                      leading: Icon(
                        Icons.library_books_outlined,
                        color: scheme.onSurfaceVariant,
                      ),
                      title: const Text('题库切换'),
                      subtitle: const Text('待接入'),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: scheme.outlineVariant,
                      ),
                    ),
                  ],
                ),
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
