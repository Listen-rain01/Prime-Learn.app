import 'package:primelearn/features/tasks/data/models/daily_task_dto.dart';
import 'package:primelearn/features/tasks/data/parsers/daily_tasks_parser.dart';
import 'package:primelearn/features/tasks/data/services/tasks_api.dart';
import 'package:primelearn/features/tasks/domain/entities/daily_task.dart';
import 'package:primelearn/features/tasks/domain/repositories/tasks_repository.dart';

/// 今日任务仓储实现：DTO → Entity。
class TasksRepositoryImpl implements TasksRepository {
  /// 创建仓储实现。
  TasksRepositoryImpl(this._api);

  final TasksApi _api;
  static const DailyTasksParser _parser = DailyTasksParser();

  @override
  Future<List<DailyTask>> fetchDailyTasks(String userId) async {
    final body = await _api.fetchDailyTasks(userId);
    return _parser.parse(body).map(_toEntity).toList(growable: false);
  }

  DailyTask _toEntity(DailyTaskDto dto) => DailyTask(
    criterion: Criterion.fromWire(dto.criterion),
    name: dto.name,
    rule: dto.rule,
    score: dto.score,
    maxScore: dto.maxScore,
    currentScore: dto.currentScore,
    progressText: dto.progressText,
    sort: dto.sort,
  );
}
