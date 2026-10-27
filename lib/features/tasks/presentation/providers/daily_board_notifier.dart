import 'package:primelearn/core/errors/no_retry.dart';
import 'package:primelearn/core/session/session_store.dart';
import 'package:primelearn/features/tasks/domain/entities/task_board.dart';
import 'package:primelearn/features/tasks/tasks_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'daily_board_notifier.g.dart';

/// 今日任务看板状态：登录态变化时自动重新加载。
@Riverpod(retry: noProviderRetry)
class DailyBoardNotifier extends _$DailyBoardNotifier {
  @override
  Future<TaskBoard> build() async {
    final session = ref.watch(sessionStoreProvider);
    if (session == null) return TaskBoard.empty;
    return ref.watch(loadDailyBoardProvider).execute(session.userId);
  }

  /// 重新加载（下拉刷新/重试按钮）。
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
