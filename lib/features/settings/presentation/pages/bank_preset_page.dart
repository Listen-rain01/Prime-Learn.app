import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primelearn/core/errors/use_case_failure.dart';
import 'package:primelearn/core/widgets/inline_notice.dart';
import 'package:primelearn/features/settings/bank_providers.dart';
import 'package:primelearn/features/settings/domain/entities/bank_catalog.dart';

/// 题库预设页：单位 → 分类 → 年份 → 题库，保存为预设。
class BankPresetPage extends ConsumerStatefulWidget {
  /// 创建题库预设页。
  const BankPresetPage({super.key});

  @override
  ConsumerState<BankPresetPage> createState() => _BankPresetPageState();
}

class _BankPresetPageState extends ConsumerState<BankPresetPage> {
  BankUnit? _unit;
  BankStyle? _style;
  BankStyle? _child;
  BankOption? _bank;
  String? _message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final preset = ref.watch(bankPresetProvider);
    final units = ref.watch(bankUnitsProvider);
    final styles = _unit == null
        ? null
        : ref.watch(bankStylesProvider(_unit!.id));
    final children = (_unit == null || _style == null)
        ? null
        : ref.watch(
            bankChildrenProvider((
              unitId: _unit!.id,
              styleId: _style!.styleId,
              code: _style!.code,
              departmentId: _style!.departmentId,
            )),
          );
    final options = (_unit == null || _child == null)
        ? null
        : ref.watch(
            bankOptionsProvider((
              unitId: _unit!.id,
              styleId: _child!.styleId,
              departmentId: _child!.departmentId,
              year: _child!.year,
            )),
          );

    return Scaffold(
      appBar: AppBar(title: const Text('题库预设')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          preset.when(
            loading: () => const _Loading(message: '正在读取预设...'),
            error: (_, _) => const Text('读取预设失败'),
            data: (value) => Text(
              value == null ? '当前未设置预设' : '当前预设：${value.bankName}',
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _sectionTitle(textTheme, scheme, '单位'),
          units.when(
            loading: () => const _Loading(message: '正在加载单位...'),
            error: (error, _) => _ErrorText(error),
            data: (list) => Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final unit in list)
                  ChoiceChip(
                    label: Text(unit.name),
                    selected: _unit?.id == unit.id,
                    onSelected: (_) => setState(() {
                      _unit = unit;
                      _style = null;
                      _child = null;
                      _bank = null;
                      _message = null;
                    }),
                  ),
              ],
            ),
          ),
          if (styles != null) ...[
            _sectionTitle(textTheme, scheme, '分类'),
            styles.when(
              loading: () => const _Loading(message: '正在加载分类...'),
              error: (error, _) => _ErrorText(error),
              data: (list) => Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final style in list)
                    ChoiceChip(
                      label: Text(style.name),
                      selected: _style?.key == style.key,
                      onSelected: (_) => setState(() {
                        _style = style;
                        _child = null;
                        _bank = null;
                        _message = null;
                      }),
                    ),
                ],
              ),
            ),
          ],
          if (children != null) ...[
            _sectionTitle(textTheme, scheme, '年份'),
            children.when(
              loading: () => const _Loading(message: '正在加载年份...'),
              error: (error, _) => _ErrorText(error),
              data: (list) => Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final child in list)
                    ChoiceChip(
                      label: Text(child.name),
                      selected: _child?.key == child.key,
                      onSelected: (_) => setState(() {
                        _child = child;
                        _bank = null;
                        _message = null;
                      }),
                    ),
                ],
              ),
            ),
          ],
          if (options != null) ...[
            _sectionTitle(textTheme, scheme, '题库'),
            options.when(
              loading: () => const _Loading(message: '正在加载题库...'),
              error: (error, _) => _ErrorText(error),
              data: (list) => list.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('该分类下暂无题库'),
                    )
                  : Column(
                      children: [
                        for (final option in list)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(option.name),
                            subtitle: Text(
                              '${option.questionCount} 题 · ${option.stateName}',
                            ),
                            trailing: Icon(
                              _bank?.id == option.id
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: _bank?.id == option.id
                                  ? scheme.primary
                                  : scheme.outlineVariant,
                            ),
                            onTap: () => setState(() {
                              _bank = option;
                              _message = null;
                            }),
                          ),
                      ],
                    ),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _bank == null ? null : _save,
            child: const Text('保存预设'),
          ),
          if (_message != null) ...[
            const SizedBox(height: 12),
            InlineNotice(message: _message!, tone: InlineNoticeTone.success),
          ],
        ],
      ),
    );
  }

  Future<void> _save() async {
    final bank = _bank!;
    final store = await ref.read(bankPresetStoreProvider.future);
    await store.save(BankPreset(bankId: bank.id, bankName: bank.name));
    ref.invalidate(bankPresetProvider);
    if (!mounted) return;
    setState(() => _message = '已保存预设：${bank.name}');
  }

  Widget _sectionTitle(TextTheme textTheme, ColorScheme scheme, String text) =>
      Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Text(
          text,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
      );
}

class _Loading extends StatelessWidget {
  const _Loading({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Text(
      message,
      style: Theme.of(context).textTheme.bodySmall
          ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
    ),
  );
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.error);

  final Object error;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Text(
      error is UseCaseFailure ? (error as UseCaseFailure).message : '加载失败',
      style: TextStyle(color: Theme.of(context).colorScheme.error),
    ),
  );
}
