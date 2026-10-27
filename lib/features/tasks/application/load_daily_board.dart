import 'package:primelearn/core/errors/use_case_failure.dart';
import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/features/tasks/domain/entities/task_board.dart';
import 'package:primelearn/features/tasks/domain/repositories/tasks_repository.dart';

/// 加载今日任务看板。
///
/// 直接使用接口返回顺序：平台的 `Sort` 并不唯一（实测签到/知识学习同为 1），
/// 客户端再做任何排序都只是猜测，保持原样最忠实。
class LoadDailyBoard {
  /// 创建用例。
  LoadDailyBoard(this._repository);

  final TasksRepository _repository;

  /// 查询今日任务。
  Future<TaskBoard> execute(String userId) async {
    try {
      final tasks = await _repository.fetchDailyTasks(userId);
      return TaskBoard(tasks: List.unmodifiable(tasks));
    } on ApiException catch (error) {
      throw UseCaseFailure.fromApi(error);
    } on Object {
      throw const UseCaseFailure('加载今日任务失败，请稍后重试');
    }
  }
}
