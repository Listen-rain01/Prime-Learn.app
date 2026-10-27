import 'package:primelearn/features/tasks/domain/entities/daily_task.dart';

/// 今日任务看板：已按「可执行 / 暂不执行」分组。
class TaskBoard {
  /// 创建看板。
  const TaskBoard({this.actionable = const [], this.pending = const []});

  /// 空看板。
  static const TaskBoard empty = TaskBoard();

  /// v1 可执行的任务。
  final List<DailyTask> actionable;

  /// 暂不执行、不获取积分的任务。
  final List<DailyTask> pending;

  /// 全部任务。
  List<DailyTask> get all => [...actionable, ...pending];

  /// 已完成任务数（已拿满上限）。
  int get completedCount => all.where((task) => task.isCompleted).length;

  /// 今日已得积分。
  int get currentPoints => all.fold(0, (sum, task) => sum + task.currentScore);

  /// 今日积分上限。
  int get maxPoints => all.fold(0, (sum, task) => sum + task.maxScore);

  /// 是否有任何任务。
  bool get isEmpty => all.isEmpty;
}
