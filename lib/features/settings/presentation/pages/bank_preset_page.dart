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
  final ScrollController _scroll = ScrollController();
  BankUnit? _unit;
  BankStyle? _style;
  BankStyle? _child;
  BankOption? _bank;
  ExamPaper? _paper;
  String? _message;
  bool _messageIsError = false;
  bool _saving = false;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

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
    final paperList = papers?.value ?? const <ExamPaper>[];
    // 只有一份时自动选中；多份必须由用户明确选择。
    final selectedPaper =
        _paper ?? (paperList.length == 1 ? paperList.first : null);
    final canSave = selectedPaper != null;
    final stage = _stage();
    final breadcrumb = [
      if (_unit != null) _unit!.name,
      if (_style != null) _style!.name,
      if (_child != null) _child!.name,
    ].join(' / ');

    return Scaffold(
      appBar: AppBar(title: const Text('题库预设')),
      body: ListView(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          _SummaryCard(
            preset: preset,
            currentBankName: session?.bankName ?? '',
            currentBankId: session?.examTypeId ?? '',
          ),
          const SizedBox(height: 20),
          _StepBar(stage: stage),
          if (breadcrumb.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              breadcrumb,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 12),
          _SelectorRow(
            label: '单位',
            value: _unit?.name,
            placeholder: '选择单位',
            loading: units.isLoading,
            onTap: units.value == null || units.value!.isEmpty
                ? null
                : () => _pickUnit(units.value!),
          ),
          if (_unit != null)
            _SelectorRow(
              label: '分类',
              value: _style?.name,
              placeholder: '选择分类',
              loading: styles?.isLoading ?? false,
              onTap: _hasItems(styles)
                  ? () => _pickStyle(styles!.value!)
                  : null,
            ),
          if (_style != null)
            _SelectorRow(
              label: '年份',
              value: _child?.name,
              placeholder: '选择年份',
              loading: children?.isLoading ?? false,
              onTap: _hasItems(children)
                  ? () => _pickChild(children!.value!)
                  : null,
            ),
          if (_child != null)
            _SelectorRow(
              label: '题库',
              value: _bank?.name,
              placeholder: '选择题库',
              loading: options?.isLoading ?? false,
              onTap: _hasItems(options)
                  ? () => _pickBank(options!.value!)
                  : null,
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
              selectedPaperId: selectedPaper?.id,
              onSelectPaper: (paper) => setState(() => _paper = paper),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _saveHint(papers, selectedPaper),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: canSave
                    ? Theme.of(context).colorScheme.onSurfaceVariant
                    : Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: canSave && !_saving ? _save : null,
                child: Text(_saving ? '保存中...' : '保存为执行预设'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _stage() {
    if (_bank != null) return 4;
    if (_child != null) return 3;
    if (_style != null) return 2;
    if (_unit != null) return 1;
    return 0;
  }

  bool _hasItems<T>(AsyncValue<List<T>>? value) =>
      value?.value?.isNotEmpty ?? false;

  String _saveHint(
    AsyncValue<List<ExamPaper>>? papers,
    ExamPaper? selectedPaper,
  ) {
    if (_bank == null) return '请先依次选择单位、分类、年份和题库';
    if (papers == null || papers.isLoading) return '正在检查该题库的可考试卷…';
    if (papers.hasError) return '试卷检查失败，请重新选择题库';
    final list = papers.value ?? const [];
    if (list.isEmpty) return '该题库没有可考试卷，不能用于模拟/手机考试';
    if (selectedPaper == null) {
      return '该题库有 ${list.length} 份试卷，请选择要使用的一份';
    }
    return '将使用：${selectedPaper.name}'
        '（${_score(selectedPaper.totalScore)} 分 / 及格 '
        '${_score(selectedPaper.passingGrade)}）';
  }

  String _score(double value) => value == value.roundToDouble()
      ? value.round().toString()
      : value.toStringAsFixed(1);

  Future<void> _pickUnit(List<BankUnit> units) async {
    final choice = await showModalBottomSheet<BankUnit>(
      context: context,
      useRootNavigator: true,
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
    await _advanceToStyles(choice);
  }

  Future<void> _pickStyle(List<BankStyle> styles) async {
    final choice = await showModalBottomSheet<BankStyle>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _ChoiceSheet<BankStyle>(
        title: '选择分类',
        items: styles,
        contextLabel: _unit?.name ?? '',
        labelOf: (style) => style.name,
      ),
    );
    if (choice == null) return;
    setState(() {
      _style = choice;
      _child = null;
      _bank = null;
      _message = null;
    });
    await _advanceToChildren(choice);
  }

  Future<void> _pickChild(List<BankStyle> children) async {
    final choice = await showModalBottomSheet<BankStyle>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _ChoiceSheet<BankStyle>(
        title: '选择年份',
        items: children,
        contextLabel: '${_unit?.name ?? ''} / ${_style?.name ?? ''}',
        labelOf: (child) => child.name,
      ),
    );
    if (choice == null) return;
    setState(() {
      _child = choice;
      _bank = null;
      _message = null;
    });
    await _advanceToBanks(choice);
  }

  /// 选完单位后自动进入分类选择（等数据加载完，再略延迟让上一个弹层关闭）。
  Future<void> _advanceToStyles(BankUnit unit) async {
    await Future<void>.delayed(const Duration(milliseconds: 260));
    if (!mounted || _unit?.id != unit.id) return;
    try {
      final styles = await ref.read(bankStylesProvider(unit.id).future);
      if (!mounted || styles.isEmpty) return;
      await _pickStyle(styles);
    } on Object {
      // 加载失败时停在当前步，用户可手动点选择器重试。
    }
  }

  /// 选完分类后自动进入年份选择。
  Future<void> _advanceToChildren(BankStyle style) async {
    final unit = _unit;
    if (unit == null) return;
    await Future<void>.delayed(const Duration(milliseconds: 260));
    if (!mounted || _style?.key != style.key) return;
    try {
      final children = await ref.read(
        bankChildrenProvider((
          unitId: unit.id,
          styleId: style.styleId,
          code: style.code,
          departmentId: style.departmentId,
        )).future,
      );
      if (!mounted || children.isEmpty) return;
      await _pickChild(children);
    } on Object {
      // 同上，失败保留手动重试入口。
    }
  }

  /// 选完年份后自动进入题库选择。
  Future<void> _advanceToBanks(BankStyle child) async {
    final unit = _unit;
    if (unit == null) return;
    await Future<void>.delayed(const Duration(milliseconds: 260));
    if (!mounted || _child?.key != child.key) return;
    try {
      final options = await ref.read(
        bankOptionsProvider((
          unitId: unit.id,
          styleId: child.styleId,
          departmentId: child.departmentId,
          year: child.year,
        )).future,
      );
      if (!mounted || options.isEmpty) return;
      await _pickBank(options);
    } on Object {
      // 同上。
    }
  }

  Future<void> _pickBank(List<BankOption> options) async {
    final choice = await showModalBottomSheet<BankOption>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _BankSheet(
        options: options,
        contextLabel:
            '${_unit?.name ?? ''} / ${_style?.name ?? ''} / ${_child?.name ?? ''}',
      ),
    );
    if (choice == null) return;
    setState(() {
      _bank = choice;
      _paper = null;
      _message = null;
    });
    // 选完题库后自动滚到详情，避免用户以为没有反应。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _save() async {
    final bank = _bank!;
    final papersNow = ref.read(examPapersProvider(bank.id)).value ?? const [];
    final selectedPaper =
        _paper ?? (papersNow.length == 1 ? papersNow.first : null);
    if (selectedPaper == null) {
      setState(() {
        _message = '请选择要使用的试卷';
        _messageIsError = true;
      });
      return;
    }
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
        preset: BankPreset(
          bankId: bank.id,
          bankName: bank.name,
          questionCount: bank.questionCount,
          singleCount: bank.singleCount,
          multipleCount: bank.multipleCount,
          judgeCount: bank.judgeCount,
          paperId: selectedPaper.id,
        ),
      );
      ref.invalidate(bankPresetProvider);
      if (!mounted) return;
      setState(() {
        _message = '已保存预设：${bank.name} · ${selectedPaper.name}';
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
    this.loading = false,
  });

  final String label;
  final String? value;
  final String placeholder;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasValue = value != null && value!.isNotEmpty;
    final enabled = onTap != null;

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
                hasValue ? value! : (loading ? '加载中...' : placeholder),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyLarge?.copyWith(
                  color: hasValue
                      ? scheme.onSurface
                      : enabled
                      ? scheme.outline
                      : scheme.outlineVariant,
                  fontWeight: hasValue ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
            if (loading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(Icons.chevron_right, color: scheme.outlineVariant),
          ],
        ),
      ),
    );
  }
}

/// 四步进度：单位 → 分类 → 年份 → 题库。
class _StepBar extends StatelessWidget {
  const _StepBar({required this.stage});

  /// 已完成步骤数（0–4）。
  final int stage;

  static const _labels = ['单位', '分类', '年份', '题库'];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        for (var index = 0; index < _labels.length; index++) ...[
          if (index > 0)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: stage > index ? scheme.primary : scheme.outlineVariant,
              ),
            ),
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: stage > index
                      ? scheme.primary
                      : scheme.surfaceContainerHighest,
                ),
                child: stage > index
                    ? Icon(Icons.check, size: 14, color: scheme.onPrimary)
                    : Text(
                        '${index + 1}',
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
              ),
              const SizedBox(height: 4),
              Text(
                _labels[index],
                style: textTheme.labelSmall?.copyWith(
                  color: stage > index
                      ? scheme.onSurface
                      : scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// 题库详情：题目数、状态、所属、可考试卷（需选一份）。
class _BankDetailsCard extends ConsumerWidget {
  const _BankDetailsCard({
    required this.bank,
    required this.unitName,
    required this.styleName,
    required this.year,
    required this.papers,
    required this.selectedPaperId,
    required this.onSelectPaper,
  });

  final BankOption bank;
  final String unitName;
  final String styleName;
  final String year;
  final AsyncValue<List<ExamPaper>>? papers;
  final String? selectedPaperId;
  final ValueChanged<ExamPaper> onSelectPaper;

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
          const SizedBox(height: 4),
          Text(
            '总题数 ${bank.questionCount} · 单选 ${bank.singleCount}'
            ' · 多选 ${bank.multipleCount} · 判断 ${bank.judgeCount}',
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '试卷',
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (list.length > 1)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '共 ${list.length} 份，请选择一份',
                              style: textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        for (final paper in list)
                          InkWell(
                            onTap: () => onSelectPaper(paper),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    paper.id == selectedPaperId
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_unchecked,
                                    size: 18,
                                    color: paper.id == selectedPaperId
                                        ? scheme.primary
                                        : scheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      paper.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: scheme.onSurface,
                                        fontWeight: paper.id == selectedPaperId
                                            ? FontWeight.w600
                                            : FontWeight.w400,
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
        _note('预设保存目标题库和一份试卷；执行考试时直接使用这份试卷。'),
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

/// 通用单选弹层（带搜索与层级上下文）。
class _ChoiceSheet<T> extends StatefulWidget {
  const _ChoiceSheet({
    required this.title,
    required this.items,
    required this.labelOf,
    this.subtitleOf,
    this.contextLabel = '',
  });

  final String title;
  final List<T> items;
  final String Function(T) labelOf;
  final String Function(T)? subtitleOf;
  final String contextLabel;

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
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
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
            Text(widget.title, style: textTheme.titleMedium),
            const SizedBox(height: 2),
            Text(
              widget.contextLabel.isEmpty
                  ? '共 ${widget.items.length} 项'
                  : '${widget.contextLabel} · 共 ${widget.items.length} 项',
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
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
  const _BankSheet({required this.options, this.contextLabel = ''});

  final List<BankOption> options;
  final String contextLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('选择题库', style: textTheme.titleMedium),
            const SizedBox(height: 2),
            Text(
              contextLabel.isEmpty
                  ? '共 ${options.length} 个'
                  : '$contextLabel · 共 ${options.length} 个',
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
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
