import 'dart:convert';

import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/features/tasks/data/models/daily_task_dto.dart';

/// 今日任务响应解析。
///
/// 响应结构：`{"success": true, "data": [...]}`；
/// `success=false` 时把 `message` 作为用户提示，不重试。
class DailyTasksParser {
  /// 创建解析器。
  const DailyTasksParser();

  /// 解析今日任务列表。
  List<DailyTaskDto> parse(String body) {
    if (body.isEmpty) {
      throw const ApiException(
        kind: ApiErrorKind.protocol,
        message: '服务器返回空响应',
      );
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(body);
    } on FormatException {
      throw const ApiException(
        kind: ApiErrorKind.protocol,
        message: '今日任务响应格式异常',
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw const ApiException(
        kind: ApiErrorKind.protocol,
        message: '今日任务响应格式异常',
      );
    }

    if (decoded['success'] == false) {
      throw ApiException(
        kind: ApiErrorKind.protocol,
        message: decoded['message']?.toString() ?? '获取今日任务失败',
      );
    }

    final data = decoded['data'];
    if (data == null) return const [];
    if (data is! List<dynamic>) {
      throw const ApiException(
        kind: ApiErrorKind.protocol,
        message: '今日任务数据格式异常',
      );
    }

    final tasks = <DailyTaskDto>[];
    for (final item in data) {
      if (item is Map<String, dynamic>) {
        tasks.add(DailyTaskDto.fromJson(item));
      }
    }
    return tasks;
  }
}
