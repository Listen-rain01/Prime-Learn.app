import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primelearn/app/router.dart';
import 'package:primelearn/core/errors/use_case_failure.dart';
import 'package:primelearn/core/session/session_store.dart';
import 'package:primelearn/core/widgets/inline_notice.dart';
import 'package:primelearn/core/widgets/tonal_block.dart';
import 'package:primelearn/features/checkin/presentation/widgets/check_in_card.dart';
import 'package:primelearn/features/exam/presentation/widgets/mock_exam_sheet.dart';
import 'package:primelearn/features/reading/reading_providers.dart';
import 'package:primelearn/features/tasks/domain/entities/daily_task.dart';
import 'package:primelearn/features/tasks/domain/entities/task_board.dart';
import 'package:primelearn/features/tasks/presentation/providers/daily_board_notifier.dart';
import 'package:primelearn/features/tasks/presentation/widgets/daily_points_header.dart';
import 'package:primelearn/features/tasks/presentation/widgets/daily_task_row.dart';

/// 今日 Tab：今日积分、当前题库、签到与每日任务。
class TodayPage extends ConsumerWidget {
  /// 创建今日页。
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionStoreProvider);
    final board = ref.watch(dailyBoardProvider);
    final checkedIn =
        board.value?.tasks.any(
          (task) =>
              task.criterion == Criterion.checkIn && task.currentScore > 0,
        ) ??
        false;

    // 会话失效（平台返回登录页/401）时清理会话，App 层监听后跳回登录页。
    ref.listen<AsyncValue<TaskBoard>>(dailyBoardProvider, (_, next) {
      final error = next.error;
      if (error is UseCaseFailure && error.sessionExpired) {
        ref.read(sessionStoreProvider.notifier).clear();
      }
    });

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            TonalBlock(
              child: DailyPointsHeader(
                userName: session?.userName ?? '未登录',
                bankName: session?.bankName ?? '未设置',
                points: board.value?.currentPoints,
              ),
            ),
            const SizedBox(height: 16),
            CheckInCard(
              alreadyCheckedIn: checkedIn,
              onSuccess: () => ref.invalidate(dailyBoardProvider),
            ),
            const SizedBox(height: 16),
            TonalBlock(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _TasksSection(
                board: board,
                onRetry: () => ref.invalidate(dailyBoardProvider),
                onTaskTap: (task) {
                  if (task.criterion == Criterion.studyKnowledge &&
                      !task.isCompleted) {
                    _openReadingSheet(context, ref);
                  } else if (task.criterion == Criterion.mockExam) {
                    showMockExamSheet(context);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 打开知识学习动作弹层（按预设文章完成）。
void _openReadingSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _ReadingTaskSheet(
      onOpenPreset: () {
        Navigator.of(context).pop();
        const ReadingPresetRoute().push<void>(context);
      },
    ),
  );
}

/// 知识学习弹层：展示预设文章并一键完成。
class _ReadingTaskSheet extends ConsumerStatefulWidget {
  const _ReadingTaskSheet({required this.onOpenPreset});

  final VoidCallback onOpenPreset;

  @override
  ConsumerState<_ReadingTaskSheet> createState() => _ReadingTaskSheetState();
}

class _ReadingTaskSheetState extends ConsumerState<_ReadingTaskSheet> {
  String? _message;
  bool _messageIsError = false;
  bool _completing = false;
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final preset = ref.watch(readingPresetProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('知识学习', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            preset.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => Text('读取阅读预设失败', style: textTheme.bodyMedium),
              data: (value) => value == null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '还没有设置阅读预设',
                          style: textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: widget.onOpenPreset,
                            child: const Text('去选择文章'),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          value.title,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                        ),
                        if (value.typeName.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            value.typeName,
                            style: textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _done || _completing ? null : _complete,
                            icon: const Icon(
                              Icons.menu_book_outlined,
                              size: 18,
                            ),
                            label: Text(
                              _done
                                  ? '今日已完成'
                                  : _completing
                                  ? '正在完成...'
                                  : '按预设完成今日阅读',
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: widget.onOpenPreset,
                          child: const Text('更换文章'),
                        ),
                      ],
                    ),
            ),
            if (_message != null) ...[
              const SizedBox(height: 8),
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

  Future<void> _complete() async {
    final preset = ref.read(readingPresetProvider).value;
    final session = ref.read(sessionStoreProvider);
    if (preset == null || session == null) return;
    setState(() => _completing = true);
    try {
      final completed = await ref
          .read(completeReadingProvider)
          .execute(userId: session.userId, preset: preset);
      ref.invalidate(dailyBoardProvider);
      if (!mounted) return;
      setState(() {
        _done = true;
        _message = completed
            ? '已完成阅读：${preset.title}（积分延迟到账）'
            : '今日知识学习已完成，无需重复阅读';
        _messageIsError = false;
      });
    } on UseCaseFailure catch (error) {
      if (!mounted) return;
      setState(() {
        _message = error.message;
        _messageIsError = true;
      });
    } finally {
      if (mounted) setState(() => _completing = false);
    }
  }
}

/// 每日任务分组块内容。
class _TasksSection extends StatelessWidget {
  const _TasksSection({
    required this.board,
    required this.onRetry,
    required this.onTaskTap,
  });

  final AsyncValue<TaskBoard> board;
  final VoidCallback onRetry;
  final ValueChanged<DailyTask> onTaskTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return board.when(
      loading: () => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: scheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '正在加载每日任务...',
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '每日任务加载失败',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              error is UseCaseFailure ? error.message : '请稍后重试',
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
      ),
      data: (value) => _TasksData(board: value, onTaskTap: onTaskTap),
    );
  }
}

class _TasksData extends StatelessWidget {
  const _TasksData({required this.board, required this.onTaskTap});

  final TaskBoard board;
  final ValueChanged<DailyTask> onTaskTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
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
              '${board.completedCount}/${board.tasks.length} 已完成',
              style: textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (board.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              '暂无任务',
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          )
        else
          for (final task in board.tasks)
            DailyTaskRow(
              task: task,
              onTap:
                  task.criterion == Criterion.studyKnowledge &&
                          !task.isCompleted ||
                      task.criterion == Criterion.mockExam
                  ? () => onTaskTap(task)
                  : null,
            ),
      ],
    );
  }
}
