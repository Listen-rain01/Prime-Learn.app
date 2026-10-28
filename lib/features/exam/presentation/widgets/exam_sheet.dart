import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primelearn/app/router.dart';
import 'package:primelearn/core/errors/use_case_failure.dart';
import 'package:primelearn/core/session/session.dart';
import 'package:primelearn/core/session/session_store.dart';
import 'package:primelearn/core/widgets/inline_notice.dart';
import 'package:primelearn/features/auth/auth_providers.dart';
import 'package:primelearn/features/exam/application/run_exam.dart';
import 'package:primelearn/features/exam/domain/entities/exam_page.dart';
import 'package:primelearn/features/exam/domain/entities/exam_paper.dart';
import 'package:primelearn/features/exam/exam_providers.dart';
import 'package:primelearn/features/settings/bank_providers.dart';
import 'package:primelearn/features/settings/domain/entities/bank_catalog.dart';
import 'package:primelearn/features/tasks/presentation/providers/daily_board_notifier.dart';

/// 打开考试执行弹层（模拟/手机共用）。
Future<void> showExamSheet(
  BuildContext context, {
  required ExamKind kind,
  VoidCallback? onOpenPreset,
}) => showModalBottomSheet<void>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => FractionallySizedBox(
    heightFactor: 0.88,
    child: _ExamSheet(kind: kind, onOpenPreset: onOpenPreset),
  ),
);

class _ExamSheet extends ConsumerStatefulWidget {
  const _ExamSheet({required this.kind, this.onOpenPreset});

  final ExamKind kind;
  final VoidCallback? onOpenPreset;

  @override
  ConsumerState<_ExamSheet> createState() => _ExamSheetState();
}

class _ExamSheetState extends ConsumerState<_ExamSheet> {
  ExamStep? _step;
  ExamResult? _result;
  String? _message;
  bool _messageIsError = false;
  bool _running = false;
  bool _aligning = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final preset = ref.watch(bankPresetProvider);
    final session = ref.watch(sessionStoreProvider);
    final value = preset.value;
    final ready = value != null && value.paperId != null && session != null;
    final needsSwitch =
        value != null && session != null && value.bankId != session.examTypeId;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.kind == ExamKind.mock ? '模拟考试' : '手机考试',
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (preset.isLoading)
              const LinearProgressIndicator()
            else if (value == null)
              _EmptyPreset(
                onTap:
                    widget.onOpenPreset ??
                    () => const BankPresetRoute().push<void>(context),
              )
            else ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value.paperName ?? '未选择试卷',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${value.bankName} · ${_score(value.paperTotalScore)} 分'
                      ' / 及格 ${_score(value.paperPassingGrade)}',
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '当前题库：${session?.bankName ?? '未知'}',
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (!ready)
                const InlineNotice(
                  message: '还没有可用的题库/试卷预设',
                  tone: InlineNoticeTone.error,
                )
              else ...[
                if (needsSwitch)
                  const InlineNotice(
                    message: '当前题库与预设不一致，开始时会自动切换到预设题库',
                    tone: InlineNoticeTone.info,
                  ),
                if (needsSwitch) const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _running ? null : _start,
                    icon: const Icon(Icons.play_arrow),
                    label: Text(
                      _aligning
                          ? '正在切换题库...'
                          : _running
                          ? '正在执行...'
                          : widget.kind == ExamKind.mock
                          ? '开始模拟考试'
                          : '开始手机考试',
                    ),
                  ),
                ),
              ],
            ],
            if (_step != null) ...[
              const SizedBox(height: 14),
              _Steps(current: _step!),
            ],
            if (_result != null) ...[
              const SizedBox(height: 12),
              _ResultTile(result: _result!),
            ],
            if (_message != null) ...[
              const SizedBox(height: 12),
              InlineNotice(
                message: _message!,
                tone: _messageIsError
                    ? InlineNoticeTone.error
                    : InlineNoticeTone.success,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _start() async {
    final session = ref.read(sessionStoreProvider);
    final preset = ref.read(bankPresetProvider).value;
    if (session == null || preset == null || preset.paperId == null) return;
    setState(() {
      _running = true;
      _step = null;
      _result = null;
      _message = null;
      _messageIsError = false;
    });
    try {
      await _alignBank(session, preset);
      final current = ref.read(sessionStoreProvider) ?? session;
      final result = await ref
          .read(runExamProvider)
          .execute(
            kind: widget.kind,
            userId: current.userId,
            paper: ExamPaper(
              id: preset.paperId!,
              name: preset.paperName ?? '',
              totalScore: preset.paperTotalScore ?? 0,
              passingGrade: preset.paperPassingGrade ?? 0,
            ),
            onStep: (step) {
              if (mounted) setState(() => _step = step);
            },
          );
      ref.invalidate(dailyBoardProvider);
      if (!mounted) return;
      setState(() {
        _result = result;
        _message = '考试完成';
      });
      await _learnPaperCount(preset, result.questionCount);
    } on UseCaseFailure catch (error) {
      if (!mounted) return;
      setState(() {
        _message = error.message;
        _messageIsError = true;
      });
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  /// 执行前对齐题库：不一致时调用切库接口并刷新会话。
  Future<void> _alignBank(Session session, BankPreset preset) async {
    if (session.examTypeId == preset.bankId) return;
    setState(() {
      _aligning = true;
      _message = '题库不一致，正在切换到预设题库...';
      _messageIsError = false;
    });
    try {
      await ref
          .read(ensureBankPresetProvider)
          .execute(
            userId: session.userId,
            currentBankId: session.examTypeId ?? '',
            preset: preset,
          );
      final context = await ref
          .read(authRepositoryProvider)
          .fetchBankContext(session.userId);
      final latest = ref.read(sessionStoreProvider);
      if (latest != null) {
        ref
            .read(sessionStoreProvider.notifier)
            .save(
              latest.copyWith(
                bankName: context.bankName,
                examTypeId: context.examTypeId,
              ),
            );
      }
      if (context.examTypeId != preset.bankId) {
        throw const UseCaseFailure('题库切换后校验不一致，请重试');
      }
      if (mounted) {
        setState(() {
          _message = '已切换到预设题库：${preset.bankName}';
          _messageIsError = false;
        });
      }
    } finally {
      if (mounted) setState(() => _aligning = false);
    }
  }

  /// 首次跑完后把试卷题数写回预设（平台没有按试卷查询题数的接口）。
  Future<void> _learnPaperCount(BankPreset preset, int count) async {
    if (count <= 0) return;
    try {
      final repository = await ref.read(bankPresetRepositoryProvider.future);
      final current = repository.read();
      if (current == null ||
          current.paperId != preset.paperId ||
          current.paperQuestionCount == count) {
        return;
      }
      await repository.save(current.copyWith(paperQuestionCount: count));
      ref.invalidate(bankPresetProvider);
    } on Object {
      // 计数仅用于展示，失败不影响考试结果。
    }
  }

  String _score(double? value) {
    if (value == null) return '--';
    return value == value.roundToDouble()
        ? value.round().toString()
        : value.toStringAsFixed(1);
  }
}

class _EmptyPreset extends StatelessWidget {
  const _EmptyPreset({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '还没有可用的考试预设',
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '请先在「我的 → 题库预设」选择题库和试卷。',
          style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 10),
        FilledButton.tonal(onPressed: onTap, child: const Text('去设置题库预设')),
      ],
    );
  }
}

class _Steps extends StatelessWidget {
  const _Steps({required this.current});

  final ExamStep current;

  static const _labels = {
    ExamStep.create: '创建考试',
    ExamStep.enter: '进入考试',
    ExamStep.fetch: '获取试题',
    ExamStep.submit: '提交答案',
    ExamStep.settle: '结算成绩',
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final keys = _labels.keys.toList();
    final index = keys.indexOf(current);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '执行进度',
          style: textTheme.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 6),
        for (var i = 0; i < keys.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(
                  i < index
                      ? Icons.check_circle
                      : i == index
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 18,
                  color: i <= index ? scheme.primary : scheme.outlineVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  _labels[keys[i]]!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: i <= index
                        ? scheme.onSurface
                        : scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.result});

  final ExamResult result;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: result.passed ? scheme.primaryContainer : scheme.errorContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            result.passed ? Icons.check_circle : Icons.error_outline,
            color: result.passed
                ? scheme.onPrimaryContainer
                : scheme.onErrorContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${result.score} 分 · ${result.passed ? '合格' : '不合格'}',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: result.passed
                        ? scheme.onPrimaryContainer
                        : scheme.onErrorContainer,
                  ),
                ),
                Text(
                  result.message,
                  style: textTheme.bodySmall?.copyWith(
                    color: result.passed
                        ? scheme.onPrimaryContainer
                        : scheme.onErrorContainer,
                  ),
                ),
                if (result.questionCount > 0)
                  Text(
                    '本场 ${result.questionCount} 题',
                    style: textTheme.bodySmall?.copyWith(
                      color: result.passed
                          ? scheme.onPrimaryContainer
                          : scheme.onErrorContainer,
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
