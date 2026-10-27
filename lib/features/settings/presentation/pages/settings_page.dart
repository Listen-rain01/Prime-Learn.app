import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primelearn/app/router.dart';
import 'package:primelearn/core/errors/use_case_failure.dart';
import 'package:primelearn/core/network/api_client.dart';
import 'package:primelearn/core/session/session_store.dart';
import 'package:primelearn/core/utils/redactor.dart';
import 'package:primelearn/core/widgets/inline_notice.dart';
import 'package:primelearn/core/widgets/tonal_block.dart';
import 'package:primelearn/features/auth/presentation/providers/login_notifier.dart';
import 'package:primelearn/features/settings/bank_providers.dart';
import 'package:primelearn/features/settings/domain/entities/person_profile.dart';
import 'package:primelearn/features/settings/profile_providers.dart';

/// 我的 Tab：账号、个人信息、题库入口、退出登录。
class SettingsPage extends ConsumerWidget {
  /// 创建我的页。
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final session = ref.watch(sessionStoreProvider);
    final profile = ref.watch(personProfileProvider);
    final avatar = ref.watch(profileAvatarProvider);
    final preset = ref.watch(bankPresetProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            TonalBlock(
              child: Row(
                children: [
                  _Avatar(bytes: avatar.value, name: session?.userName ?? ''),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session?.userName ?? '未登录',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                ],
              ),
            ),
            const SizedBox(height: 16),
            TonalBlock(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _ProfileSection(
                profile: profile,
                onRetry: () => ref.invalidate(personProfileProvider),
              ),
            ),
            const SizedBox(height: 16),
            TonalBlock(
              padding: EdgeInsets.zero,
              // ListTile 的水波纹需要就近 Material；TonalBlock 自带背景色会遮挡，
              // 因此在这里补一层透明 Material。
              child: Material(
                type: MaterialType.transparency,
                child: ListTile(
                  leading: Icon(
                    Icons.library_books_outlined,
                    color: scheme.onSurfaceVariant,
                  ),
                  title: const Text('题库预设'),
                  subtitle: Text(
                    preset.value?.bankName ?? '未设置',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: OutlinedButton(
                    onPressed: () =>
                        const BankPresetRoute().push<void>(context),
                    child: const Text('设置'),
                  ),
                  onTap: () => const BankPresetRoute().push<void>(context),
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

/// 个人信息卡片内容（`POST /PersonWap/MyBaseInfo` 的 vData）。
class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.profile, required this.onRetry});

  final AsyncValue<PersonProfile?> profile;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '个人信息',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        profile.when(
          loading: () => Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '正在加载个人信息...',
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          error: (error, _) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InlineNotice(
                  message: error is UseCaseFailure ? error.message : '加载失败',
                ),
                const SizedBox(height: 4),
                TextButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('重试'),
                ),
              ],
            ),
          ),
          data: (value) {
            if (value == null || value.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  '暂无个人信息',
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              );
            }
            // 平台实测：部分账号的工号（pnum）就是身份证号，此时必须按身份证脱敏。
            final employeeNo = value.employeeNo == value.idCard
                ? Redactor.idCard(value.employeeNo)
                : value.employeeNo;
            final rows = <(String, String)>[
              ('工号', employeeNo),
              ('身份证号', Redactor.idCard(value.idCard)),
              ('工作单位', value.department),
              ('联系方式', Redactor.phone(value.phone)),
              ('家庭地址', value.address),
            ];
            return Column(
              children: [
                for (var index = 0; index < rows.length; index++) ...[
                  if (index > 0)
                    Divider(
                      height: 0.5,
                      thickness: 0.5,
                      color: scheme.outlineVariant,
                    ),
                  _InfoRow(label: rows[index].$1, value: rows[index].$2),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final display = value.trim().isEmpty ? '未填写' : value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              display,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

/// 圆形头像：有头像字节用图片，否则回退姓名首字。
class _Avatar extends StatelessWidget {
  const _Avatar({required this.bytes, required this.name});

  final Uint8List? bytes;
  final String name;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final imageBytes = bytes;
    final initial = name.isEmpty ? '?' : name.substring(0, 1);

    return CircleAvatar(
      radius: 28,
      backgroundColor: scheme.primaryContainer,
      backgroundImage: imageBytes == null ? null : MemoryImage(imageBytes),
      child: imageBytes == null
          ? Text(
              initial,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onPrimaryContainer,
              ),
            )
          : null,
    );
  }
}
