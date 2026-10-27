import 'package:primelearn/core/protocol/json_envelope.dart';
import 'package:primelearn/features/tasks/data/models/daily_task_dto.dart';

/// 今日任务响应解析。
///
/// 响应结构：`{"success": true, "data": [...]}`；
/// `success=false` 时把 `message` 作为用户提示，不重试。
class DailyTasksParser {
  /// 创建解析器。
  const DailyTasksParser();

  /// 解析今日任务列表。
  List<DailyTaskDto> parse(String body) => JsonEnvelope.list(
    body,
    label: '今日任务',
  ).map(DailyTaskDto.fromJson).toList(growable: false);
}
