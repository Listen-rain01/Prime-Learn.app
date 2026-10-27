import 'dart:convert';

import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/features/records/data/models/score_trend_dto.dart';

/// 个人成绩趋势解析：外层为 `{total, rows}`，没有 `success` 字段。
class ScoreTrendParser {
  /// 创建解析器。
  const ScoreTrendParser();

  /// 解析趋势列表。
  List<ScoreTrendDto> parse(String body) {
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
        message: '成绩趋势响应格式异常',
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw const ApiException(
        kind: ApiErrorKind.protocol,
        message: '成绩趋势响应格式异常',
      );
    }

    final rows = decoded['rows'];
    if (rows == null) return const [];
    if (rows is! List) {
      throw const ApiException(
        kind: ApiErrorKind.protocol,
        message: '成绩趋势数据格式异常',
      );
    }
    return [
      for (final item in rows)
        if (item is Map<String, dynamic>) ScoreTrendDto.fromJson(item),
    ];
  }
}
