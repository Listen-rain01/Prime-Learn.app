import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primelearn/app/router.dart';
import 'package:primelearn/core/errors/use_case_failure.dart';
import 'package:primelearn/core/session/session_store.dart';
import 'package:primelearn/core/widgets/inline_notice.dart';
import 'package:primelearn/features/exam/application/run_mock_exam.dart';
import 'package:primelearn/features/exam/domain/entities/exam_page.dart';
import 'package:primelearn/features/exam/domain/entities/exam_paper.dart';
import 'package:primelearn/features/exam/exam_providers.dart';
import 'package:primelearn/features/settings/bank_providers.dart';
import 'package:primelearn/features/tasks/presentation/providers/daily_board_notifier.dart';

/// 模拟考试页：按预设题库/试卷自动完成一场模拟考试。
class MockExamPage extends ConsumerStatefulWidget {
  /// 创建模拟考试页。
  const MockExamPage({super.key});

  @override
  ConsumerState<MockExamPage> createState() => _MockExamPageState();
}

class _MockExamPageState extends ConsumerState<MockExamPage> {
  MockExamStep? _step;
  ExamResult? _result;
  String? _message;
  bool _messageIsError = false;
  bool _running = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final preset = ref.watch(bankPresetProvider);
    final session = ref.watch(sessionStoreProvider);
    final value = preset.value;
    final ready =
        value != null &&
        value.paperId != null &&
        session != null &&
        value.bankId == session.examTypeId;

    return Scaffold(
      appBar: AppBar(title: const Text('模拟考试')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          if (preset.isLoading)
            const LinearProgressIndicator()
          else if (value == null)
            _EmptyPresetCard(
              onTap: () => const BankPresetRoute().push<void>(context),
            )
          else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '预设试卷',
                    style: textTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value.paperName ?? '未选择试卷',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
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
                  const SizedBox(height: 4),
                  Text(
                    '当前题库：${session?.bankName ?? '未知'}',
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (!ready)
              _MismatchCard(
                onTap: () => const BankPresetRoute().push<void>(context),
              )
            else
              FilledButton.icon(
                onPressed: _running ? null : _start,
                icon: const Icon(Icons.play_arrow),
                label: Text(_running ? '正在执行...' : '开始模拟考试'),
              ),
          ],
          if (_step != null) ...[
            const SizedBox(height: 20),
            _StepList(current: _step!),
          ],
          if (_result != null) ...[
            const SizedBox(height: 16),
            _ResultCard(result: _result!),
          ],
          if (_message != null) ...[
            const SizedBox(height: 16),
            InlineNotice(
              message: _message!,
              tone: _messageIsError
                  ? InlineNoticeTone.error
                  : InlineNoticeTone.success,
            ),
          ],
          const SizedBox(height: 16),
          Text(
            '流程：创建考试 → 进入 → 取题 → 提交 → 结算。'
            '答案使用平台下发的正确答案字段自动作答。',
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
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
      final result = await ref
          .read(runMockExamProvider)
          .execute(
            userId: session.userId,
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
        _messageIsError = false;
      });
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

  String _score(double? value) {
    if (value == null) return '--';
    return value == value.roundToDouble()
        ? value.round().toString()
        : value.toStringAsFixed(1);
  }
}

class _EmptyPresetCard extends StatelessWidget {
  const _EmptyPresetCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
          Text(
            '还没有可用的考试预设',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '请先在「我的 → 题库预设」选择题库和试卷。',
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(onPressed: onTap, child: const Text('去设置题库预设')),
        ],
      ),
    );
  }
}

class _MismatchCard extends StatelessWidget {
  const _MismatchCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '当前题库与预设不一致，暂不能开始考试',
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onErrorContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '题库切换属于写操作，需单独授权验证；请先在平台切换到预设题库。',
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onErrorContainer,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: onTap, child: const Text('查看题库预设')),
        ],
      ),
    );
  }
}

class _StepList extends StatelessWidget {
  const _StepList({required this.current});

  final MockExamStep current;

  static const _labels = {
    MockExamStep.create: '创建考试',
    MockExamStep.enter: '进入考试',
    MockExamStep.fetch: '获取试题',
    MockExamStep.submit: '提交答案',
    MockExamStep.settle: '结算成绩',
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
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < keys.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
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

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final ExamResult result;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: result.passed ? scheme.primaryContainer : scheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
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
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: result.passed
                        ? scheme.onPrimaryContainer
                        : scheme.onErrorContainer,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  result.message,
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
