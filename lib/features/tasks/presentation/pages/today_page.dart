import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primelearn/core/errors/use_case_failure.dart';
import 'package:primelearn/core/session/session_store.dart';
import 'package:primelearn/core/widgets/tonal_block.dart';
import 'package:primelearn/features/tasks/domain/entities/task_board.dart';
import 'package:primelearn/features/tasks/presentation/providers/daily_board_notifier.dart';
import 'package:primelearn/features/tasks/presentation/widgets/daily_points_header.dart';
import 'package:primelearn/features/tasks/presentation/widgets/daily_task_row.dart';

/// 今日 Tab：今日积分、当前题库与每日任务。
class TodayPage extends ConsumerWidget {
  /// 创建今日页。
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionStoreProvider);
    final board = ref.watch(dailyBoardProvider);

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
            TonalBlock(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _TasksSection(
                board: board,
                onRetry: () => ref.invalidate(dailyBoardProvider),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 每日任务分组块内容。
class _TasksSection extends StatelessWidget {
  const _TasksSection({required this.board, required this.onRetry});

  final AsyncValue<TaskBoard> board;
  final VoidCallback onRetry;

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
      data: (value) => _TasksData(board: value),
    );
  }
}

class _TasksData extends StatelessWidget {
  const _TasksData({required this.board});

  final TaskBoard board;

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
          for (final task in board.tasks) DailyTaskRow(task: task),
      ],
    );
  }
}
