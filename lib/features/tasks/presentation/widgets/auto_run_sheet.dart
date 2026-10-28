import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primelearn/features/tasks/presentation/providers/daily_auto_runner.dart';

/// 打开一键完成弹层。
Future<void> showAutoRunSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _AutoRunSheet(),
    );

class _AutoRunSheet extends ConsumerStatefulWidget {
  const _AutoRunSheet();

  @override
  ConsumerState<_AutoRunSheet> createState() => _AutoRunSheetState();
}

class _AutoRunSheetState extends ConsumerState<_AutoRunSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final runner = ref.read(dailyAutoRunnerProvider.notifier);
      final hasResult = ref
          .read(dailyAutoRunnerProvider)
          .any((step) => step.status != AutoTaskStatus.pending);
      if (!runner.running && !hasResult) {
        runner.run();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final steps = ref.watch(dailyAutoRunnerProvider);
    final running = steps.any((step) => step.status == AutoTaskStatus.running);
    final allDone = steps.every((step) => step.status == AutoTaskStatus.done);
    final hasFailed = steps.any((step) => step.status == AutoTaskStatus.failed);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('一键完成今日任务', style: textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              '模拟考试 → 手机考试 → 签到 → 知识学习；已完成或已满上限会自动跳过。',
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            for (var i = 0; i < steps.length; i++) ...[
              _StepRow(progress: steps[i]),
              if (i != steps.length - 1) const SizedBox(height: 10),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(
                  allDone
                      ? Icons.check_circle
                      : hasFailed
                      ? Icons.error_outline
                      : running
                      ? Icons.autorenew
                      : Icons.info_outline,
                  size: 18,
                  color: allDone
                      ? scheme.primary
                      : hasFailed
                      ? scheme.error
                      : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    allDone
                        ? '全部完成'
                        : hasFailed
                        ? '部分任务未完成，见上方原因'
                        : running
                        ? '正在执行...'
                        : '等待执行',
                    style: textTheme.bodySmall?.copyWith(
                      color: allDone
                          ? scheme.primary
                          : hasFailed
                          ? scheme.error
                          : scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(running ? '后台执行，关闭' : '关闭'),
                  ),
                ),
                if (!running && (allDone || hasFailed)) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () =>
                          ref.read(dailyAutoRunnerProvider.notifier).run(),
                      child: const Text('再执行一次'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.progress});

  final AutoTaskProgress progress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: switch (progress.status) {
            AutoTaskStatus.done => Icon(
              Icons.check_circle,
              size: 18,
              color: scheme.primary,
            ),
            AutoTaskStatus.running => const Padding(
              padding: EdgeInsets.all(2),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            AutoTaskStatus.failed => Icon(
              Icons.error_outline,
              size: 18,
              color: scheme.error,
            ),
            AutoTaskStatus.pending => Icon(
              Icons.radio_button_unchecked,
              size: 18,
              color: scheme.outlineVariant,
            ),
          },
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                progress.title,
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (progress.detail.isNotEmpty)
                Text(
                  progress.detail,
                  style: textTheme.bodySmall?.copyWith(
                    color: progress.status == AutoTaskStatus.failed
                        ? scheme.error
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
