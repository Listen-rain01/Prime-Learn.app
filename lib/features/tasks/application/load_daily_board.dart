import 'package:primelearn/core/errors/use_case_failure.dart';
import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/features/tasks/domain/entities/daily_task.dart';
import 'package:primelearn/features/tasks/domain/entities/task_board.dart';
import 'package:primelearn/features/tasks/domain/repositories/tasks_repository.dart';

/// 加载今日任务看板：排序 + 分组。
///
/// 分组依据是**我们的执行能力**，不是积分高低：
/// - 暂不执行：签到（尚未实现）、视频学习、练习时长、手机练习（v1 不做）；
/// - 其余（知识学习、模拟考试、手机考试）视为可执行。
///
/// 清单按 AGENTS.md v1 范围收敛：手机练习不做；签到实现后移出暂不执行组。
class LoadDailyBoard {
  /// 创建用例。
  LoadDailyBoard(this._repository);

  final TasksRepository _repository;

  /// 暂不执行的任务标识。
  static const Set<Criterion> notActionable = {
    Criterion.checkIn,
    Criterion.course,
    Criterion.studyTime,
    Criterion.mobileExercises,
  };

  /// 查询并组装看板。
  Future<TaskBoard> execute(String userId) async {
    try {
      final tasks = await _repository.fetchDailyTasks(userId);
      // 平台实测：Sort 不唯一（签到/知识学习同为 1，模拟考试/手机考试/视频学习为 2/3/3）。
      // 用「Sort + 原始下标」排序，保证同 Sort 时保持服务端顺序（Dart 的 sort 不稳定）。
      final ordered =
          <({int index, DailyTask task})>[
            for (final (index, task) in tasks.indexed)
              (index: index, task: task),
          ]..sort((a, b) {
            final bySort = a.task.sort.compareTo(b.task.sort);
            return bySort != 0 ? bySort : a.index.compareTo(b.index);
          });

      return TaskBoard(
        actionable: ordered
            .where((entry) => !notActionable.contains(entry.task.criterion))
            .map((entry) => entry.task)
            .toList(growable: false),
        pending: ordered
            .where((entry) => notActionable.contains(entry.task.criterion))
            .map((entry) => entry.task)
            .toList(growable: false),
      );
    } on ApiException catch (error) {
      throw UseCaseFailure.fromApi(error);
    } on Object {
      throw const UseCaseFailure('加载今日任务失败，请稍后重试');
    }
  }
}
