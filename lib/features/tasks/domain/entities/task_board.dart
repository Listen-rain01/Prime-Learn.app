import 'package:primelearn/features/tasks/domain/entities/daily_task.dart';

/// 今日任务看板：保持接口返回的自然顺序。
class TaskBoard {
  /// 创建看板。
  const TaskBoard({this.tasks = const []});

  /// 空看板。
  static const TaskBoard empty = TaskBoard();

  /// 任务列表（顺序即接口顺序）。
  final List<DailyTask> tasks;

  /// 已完成任务数（已拿满上限）。
  int get completedCount => tasks.where((task) => task.isCompleted).length;

  /// 今日已得积分。
  int get currentPoints =>
      tasks.fold(0, (sum, task) => sum + task.currentScore);

  /// 今日积分上限。
  int get maxPoints => tasks.fold(0, (sum, task) => sum + task.maxScore);

  /// 是否有任何任务。
  bool get isEmpty => tasks.isEmpty;
}
