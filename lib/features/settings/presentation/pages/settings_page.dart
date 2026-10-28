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
import 'package:primelearn/features/settings/domain/entities/bank_catalog.dart';
import 'package:primelearn/features/settings/domain/entities/person_profile.dart';
import 'package:primelearn/features/settings/profile_providers.dart';

/// 头部工号文案；平台实测 pnum 可能等于身份证号，同值时按身份证脱敏。
String _employeeNoText(PersonProfile? profile) {
  if (profile == null) return '工号 --';
  final no = profile.employeeNo.trim();
  if (no.isEmpty) return '工号 未填写';
  final display = no == profile.idCard ? Redactor.idCard(no) : no;
  return '工号 $display';
}

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
                        Row(
                          children: [
                            Icon(
                              Icons.badge_outlined,
                              size: 14,
                              color: scheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                _employeeNoText(profile.value),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
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
            _PresetEntryCard(
              preset: preset.value,
              currentBankId: session?.examTypeId,
              currentBankName: session?.bankName ?? '',
              onTap: () => const BankPresetRoute().push<void>(context),
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

/// 题库预设入口：流向式卡片（当前 → 目标），一致时自动折叠。
class _PresetEntryCard extends StatelessWidget {
  const _PresetEntryCard({
    required this.preset,
    required this.currentBankId,
    required this.currentBankName,
    required this.onTap,
  });

  final BankPreset? preset;
  final String? currentBankId;
  final String currentBankName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final value = preset;
    final aligned =
        value != null && currentBankId != null && value.bankId == currentBankId;
    final typeMeta = _typeMeta(value);
    final paperText = _paperText(value);

    final (statusLabel, statusBackground, statusForeground) = switch (value) {
      null => ('未设置', scheme.surfaceContainerHigh, scheme.onSurfaceVariant),
      _ when aligned => (
        '已对齐',
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
      ),
      _ => ('待切换', scheme.tertiaryContainer, scheme.onTertiaryContainer),
    };

    return TonalBlock(
      padding: EdgeInsets.zero,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '题库预设',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusBackground,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        statusLabel,
                        style: textTheme.labelSmall?.copyWith(
                          color: statusForeground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right, color: scheme.outlineVariant),
                  ],
                ),
                const SizedBox(height: 10),
                _LabeledValue(
                  label: '当前题库',
                  value: currentBankName.isEmpty ? '未知' : currentBankName,
                ),
                const SizedBox(height: 6),
                _LabeledValue(
                  label: '目标题库',
                  value: value?.bankName ?? '未设置',
                  highlight: value != null,
                ),
                if (value != null) ...[
                  const SizedBox(height: 6),
                  _LabeledValue(
                    label: '目标试卷',
                    value: paperText,
                    highlight: value.paperId != null,
                  ),
                ],
                if (value != null && typeMeta != null) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 76),
                    child: Text(
                      typeMeta,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
                if (value == null) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 76),
                    child: Text(
                      '点击选择目标题库',
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _typeMeta(BankPreset? value) {
    if (value == null) return null;
    final parts = <String>[
      if (value.questionCount != null) '总题数 ${value.questionCount}',
      if (value.singleCount != null) '单选 ${value.singleCount}',
      if (value.multipleCount != null) '多选 ${value.multipleCount}',
      if (value.judgeCount != null) '判断 ${value.judgeCount}',
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }

  /// 目标试卷文案；没有绑定试卷 ID 的旧预设提示重新选择。
  String _paperText(BankPreset? value) {
    if (value == null) return '';
    if (value.paperId == null) return '未选择，点击补选';
    final name = value.paperName ?? '';
    final total = value.paperTotalScore;
    final pass = value.paperPassingGrade;
    final score = total != null && pass != null
        ? '（${_score(total)} 分 / 及格 ${_score(pass)}）'
        : '';
    final count = value.paperCount != null && value.paperCount! > 1
        ? ' · 共 ${value.paperCount} 份'
        : '';
    return '$name$score$count';
  }

  String _score(double value) => value == value.roundToDouble()
      ? value.round().toString()
      : value.toStringAsFixed(1);
}

/// 卡片里的「标签 + 值」行。
class _LabeledValue extends StatelessWidget {
  const _LabeledValue({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 64,
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
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface,
              fontWeight: highlight ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
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
            final rows = <({String label, String value, IconData icon})>[
              (
                label: '身份证号',
                value: Redactor.idCard(value.idCard),
                icon: Icons.badge_outlined,
              ),
              (
                label: '工作单位',
                value: value.department,
                icon: Icons.business_outlined,
              ),
              (
                label: '联系方式',
                value: Redactor.phone(value.phone),
                icon: Icons.phone_outlined,
              ),
              (label: '家庭地址', value: value.address, icon: Icons.home_outlined),
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
                  _InfoRow(
                    label: rows[index].label,
                    value: rows[index].value,
                    icon: rows[index].icon,
                  ),
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
  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

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
          Icon(icon, size: 18, color: scheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  display,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
              ],
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
