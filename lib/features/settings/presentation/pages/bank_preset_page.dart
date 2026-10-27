import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primelearn/core/errors/use_case_failure.dart';
import 'package:primelearn/core/session/session_store.dart';
import 'package:primelearn/core/widgets/inline_notice.dart';
import 'package:primelearn/features/exam/domain/entities/exam_paper.dart';
import 'package:primelearn/features/exam/exam_providers.dart';
import 'package:primelearn/features/settings/bank_providers.dart';
import 'package:primelearn/features/settings/domain/entities/bank_catalog.dart';

/// 题库预设页：单页选择器 + 底部弹层，展示题库与可考试卷详情。
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
  bool _messageIsError = false;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final preset = ref.watch(bankPresetProvider);
    final session = ref.watch(sessionStoreProvider);
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
    final papers = _bank == null
        ? null
        : ref.watch(examPapersProvider(_bank!.id));
    final canSave = papers?.value?.isNotEmpty ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('题库预设')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          _SummaryCard(
            preset: preset,
            currentBankName: session?.bankName ?? '',
            currentBankId: session?.examTypeId ?? '',
          ),
          const SizedBox(height: 20),
          _sectionTitle(textTheme, scheme, '目标题库'),
          _SelectorRow(
            label: '单位',
            value: _unit?.name,
            placeholder: '选择单位',
            onTap: () => _pickUnit(units.value ?? const []),
          ),
          if (_unit != null)
            _SelectorRow(
              label: '分类',
              value: _style?.name,
              placeholder: '选择分类',
              onTap: styles == null
                  ? null
                  : () => _pickStyle(styles.value ?? const []),
            ),
          if (_style != null)
            _SelectorRow(
              label: '年份',
              value: _child?.name,
              placeholder: '选择年份',
              onTap: children == null
                  ? null
                  : () => _pickChild(children.value ?? const []),
            ),
          if (_child != null)
            _SelectorRow(
              label: '题库',
              value: _bank?.name,
              placeholder: '选择题库',
              onTap: options == null
                  ? null
                  : () => _pickBank(options.value ?? const []),
            ),
          if (_bank != null) ...[
            const SizedBox(height: 20),
            _sectionTitle(textTheme, scheme, '题库详情'),
            _BankDetailsCard(
              bank: _bank!,
              unitName: _unit?.name ?? '',
              styleName: _style?.name ?? '',
              year: _child?.year ?? '',
              papers: papers,
            ),
          ],
          const SizedBox(height: 20),
          _NotesCard(scheme: scheme, textTheme: textTheme),
          if (_message != null) ...[
            const SizedBox(height: 16),
            InlineNotice(
              message: _message!,
              tone: _messageIsError
                  ? InlineNoticeTone.error
                  : InlineNoticeTone.success,
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: FilledButton(
          onPressed: canSave && !_saving ? _save : null,
          child: Text(_saving ? '保存中...' : '保存为执行预设'),
        ),
      ),
    );
  }

  Future<void> _pickUnit(List<BankUnit> units) async {
    final choice = await showModalBottomSheet<BankUnit>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _ChoiceSheet<BankUnit>(
        title: '选择单位',
        items: units,
        labelOf: (unit) => unit.name,
      ),
    );
    if (choice == null) return;
    setState(() {
      _unit = choice;
      _style = null;
      _child = null;
      _bank = null;
      _message = null;
    });
  }

  Future<void> _pickStyle(List<BankStyle> styles) async {
    final choice = await showModalBottomSheet<BankStyle>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _ChoiceSheet<BankStyle>(
        title: '选择分类',
        items: styles,
        labelOf: (style) => style.name,
        subtitleOf: (style) => style.year.isEmpty ? '' : '${style.year} 年',
      ),
    );
    if (choice == null) return;
    setState(() {
      _style = choice;
      _child = null;
      _bank = null;
      _message = null;
    });
  }

  Future<void> _pickChild(List<BankStyle> children) async {
    final choice = await showModalBottomSheet<BankStyle>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _ChoiceSheet<BankStyle>(
        title: '选择年份',
        items: children,
        labelOf: (child) => child.name,
        subtitleOf: (child) => child.year.isEmpty ? '' : '${child.year} 年',
      ),
    );
    if (choice == null) return;
    setState(() {
      _child = choice;
      _bank = null;
      _message = null;
    });
  }

  Future<void> _pickBank(List<BankOption> options) async {
    final choice = await showModalBottomSheet<BankOption>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _BankSheet(options: options),
    );
    if (choice == null) return;
    setState(() {
      _bank = choice;
      _message = null;
    });
  }

  Future<void> _save() async {
    final bank = _bank!;
    final session = ref.read(sessionStoreProvider);
    if (session == null) {
      setState(() {
        _message = '未登录';
        _messageIsError = true;
      });
      return;
    }
    setState(() => _saving = true);
    try {
      final useCase = await ref.read(saveBankPresetProvider.future);
      await useCase.execute(
        userId: session.userId,
        preset: BankPreset(bankId: bank.id, bankName: bank.name),
      );
      ref.invalidate(bankPresetProvider);
      if (!mounted) return;
      setState(() {
        _message = '已保存预设：${bank.name}';
        _messageIsError = false;
      });
    } on UseCaseFailure catch (error) {
      if (!mounted) return;
      setState(() {
        _message = error.message;
        _messageIsError = true;
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _sectionTitle(TextTheme textTheme, ColorScheme scheme, String text) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
      );
}

/// 顶部摘要：预设、当前题库、对齐状态。
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.preset,
    required this.currentBankName,
    required this.currentBankId,
  });

  final AsyncValue<BankPreset?> preset;
  final String currentBankName;
  final String currentBankId;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return preset.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, _) => const Text('读取预设失败'),
      data: (value) {
        final aligned = value != null && value.bankId == currentBankId;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '当前预设',
                      style: textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  _StatusChip(
                    label: value == null
                        ? '未设置'
                        : aligned
                        ? '已对齐'
                        : '执行前切换',
                    tone: value == null
                        ? _ChipTone.neutral
                        : aligned
                        ? _ChipTone.positive
                        : _ChipTone.warning,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                value?.bankName ?? '还没有设置执行预设',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '当前题库：${currentBankName.isEmpty ? '未知' : currentBankName}',
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              if (value != null && !aligned) ...[
                const SizedBox(height: 4),
                Text(
                  '执行考试前会先切到你预设的题库（切换需授权）',
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

enum _ChipTone { neutral, positive, warning }

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.tone});

  final String label;
  final _ChipTone tone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (background, foreground) = switch (tone) {
      _ChipTone.neutral => (
        scheme.surfaceContainerHigh,
        scheme.onSurfaceVariant,
      ),
      _ChipTone.positive => (
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
      ),
      _ChipTone.warning => (
        scheme.tertiaryContainer,
        scheme.onTertiaryContainer,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: foreground, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// 单行选择器：label + 当前值 + 箭头。
class _SelectorRow extends StatelessWidget {
  const _SelectorRow({
    required this.label,
    required this.value,
    required this.placeholder,
    required this.onTap,
  });

  final String label;
  final String? value;
  final String placeholder;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasValue = value != null && value!.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
        child: Row(
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
            Expanded(
              child: Text(
                hasValue ? value! : placeholder,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyLarge?.copyWith(
                  color: hasValue ? scheme.onSurface : scheme.outline,
                  fontWeight: hasValue ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: scheme.outlineVariant),
          ],
        ),
      ),
    );
  }
}

/// 题库详情：题目数、状态、所属、可考试卷。
class _BankDetailsCard extends ConsumerWidget {
  const _BankDetailsCard({
    required this.bank,
    required this.unitName,
    required this.styleName,
    required this.year,
    required this.papers,
  });

  final BankOption bank;
  final String unitName;
  final String styleName;
  final String year;
  final AsyncValue<List<ExamPaper>>? papers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  bank.name,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _StatusChip(
                label: '${bank.questionCount} 题 · ${bank.stateName}',
                tone: _ChipTone.neutral,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            [
              unitName,
              styleName,
              if (year.isNotEmpty) '$year 年',
            ].where((part) => part.isNotEmpty).join(' / '),
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '可考试卷',
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          if (papers == null)
            const Text('尚未选择题库')
          else
            papers!.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: LinearProgressIndicator(),
              ),
              error: (error, _) => Text(
                error is UseCaseFailure ? error.message : '试卷加载失败',
                style: textTheme.bodySmall?.copyWith(color: scheme.error),
              ),
              data: (list) => list.isEmpty
                  ? Text(
                      '该题库没有可考试卷，不适用模拟/手机考试',
                      style: textTheme.bodySmall?.copyWith(color: scheme.error),
                    )
                  : Column(
                      children: [
                        for (final paper in list)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.description_outlined,
                                  size: 18,
                                  color: scheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    paper.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: scheme.onSurface,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${_score(paper.totalScore)} 分 · 及格 ${_score(paper.passingGrade)}',
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
        ],
      ),
    );
  }

  String _score(double value) => value == value.roundToDouble()
      ? value.round().toString()
      : value.toStringAsFixed(1);
}

/// 使用说明。
class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.scheme, required this.textTheme});

  final ColorScheme scheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _note('预设只保存目标题库，不保存试卷；每次考试前再从可考试卷中选择。'),
        const SizedBox(height: 6),
        _note('执行考试或一键任务前会校验当前题库，不一致时切换（需授权）。'),
        const SizedBox(height: 6),
        _note('没有可考试卷的题库会标灰，不适用模拟/手机考试。'),
      ],
    ),
  );

  Widget _note(String text) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '· ',
        style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
      ),
      Expanded(
        child: Text(
          text,
          style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ),
    ],
  );
}

/// 通用单选弹层（带搜索）。
class _ChoiceSheet<T> extends StatefulWidget {
  const _ChoiceSheet({
    required this.title,
    required this.items,
    required this.labelOf,
    this.subtitleOf,
  });

  final String title;
  final List<T> items;
  final String Function(T) labelOf;
  final String Function(T)? subtitleOf;

  @override
  State<_ChoiceSheet<T>> createState() => _ChoiceSheetState<T>();
}

class _ChoiceSheetState<T> extends State<_ChoiceSheet<T>> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.items
        .where(
          (item) => widget
              .labelOf(item)
              .toLowerCase()
              .contains(_query.trim().toLowerCase()),
        )
        .toList();
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: '搜索',
                isDense: true,
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  final subtitle = widget.subtitleOf?.call(item) ?? '';
                  return ListTile(
                    title: Text(widget.labelOf(item)),
                    subtitle: subtitle.isEmpty ? null : Text(subtitle),
                    onTap: () => Navigator.of(context).pop(item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 题库弹层：无试卷的题库灰显并禁用。
class _BankSheet extends StatelessWidget {
  const _BankSheet({required this.options});

  final List<BankOption> options;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('选择题库', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) =>
                    _BankSheetRow(bank: options[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BankSheetRow extends ConsumerWidget {
  const _BankSheetRow({required this.bank});

  final BankOption bank;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final count = ref.watch(bankPaperCountProvider(bank.id));

    return count.when(
      loading: () => ListTile(
        enabled: false,
        title: Text(bank.name),
        subtitle: Text('${bank.questionCount} 题 · 检查试卷中...'),
        trailing: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, _) => ListTile(
        enabled: false,
        title: Text(bank.name),
        subtitle: Text('${bank.questionCount} 题 · 试卷检查失败'),
      ),
      data: (value) {
        final usable = value > 0;
        return ListTile(
          enabled: usable,
          title: Text(
            bank.name,
            style: textTheme.bodyLarge?.copyWith(
              color: usable ? scheme.onSurface : scheme.outline,
            ),
          ),
          subtitle: Text(
            usable
                ? '${bank.questionCount} 题 · 可考试卷 $value 份'
                : '${bank.questionCount} 题 · 无试卷，不适用考试',
            style: textTheme.bodySmall?.copyWith(
              color: usable ? scheme.onSurfaceVariant : scheme.outline,
            ),
          ),
          trailing: usable
              ? const Icon(Icons.chevron_right)
              : _StatusChip(label: '不适用', tone: _ChipTone.neutral),
          onTap: usable ? () => Navigator.of(context).pop(bank) : null,
        );
      },
    );
  }
}
