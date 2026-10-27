import 'package:primelearn/features/tasks/domain/entities/daily_task.dart';

/// 今日任务数据接口。
abstract interface class TasksRepository {
  /// 查询今日任务列表；失败抛 `ApiException`。
  Future<List<DailyTask>> fetchDailyTasks(String userId);
}
