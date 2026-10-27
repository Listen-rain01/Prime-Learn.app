import 'dart:convert';

import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/features/settings/domain/entities/bank_catalog.dart';

/// 单位解析：从 `SelectExamType` 页面 HTML 的 `vData.Units` 提取。
///
/// 实测格式（`^` 分段、`,` 分字段）：
/// `1,股份,股份,股份^<guid>,澄合矿业,澄合矿业,^<guid>,澄合矿业/西卓煤矿,西卓煤矿,chxzmk`
class BankUnitParser {
  /// 创建解析器。
  const BankUnitParser();

  /// 解析单位列表。
  List<BankUnit> parse(String html) {
    final units = _extractUnits(html);
    if (units == null) {
      throw const ApiException(
        kind: ApiErrorKind.protocol,
        message: '题库单位数据缺失',
      );
    }
    final result = <BankUnit>[];
    for (final raw in units.split('^')) {
      final parts = raw.split(',');
      if (parts.length < 3) continue;
      final id = parts[0].trim();
      final name = parts[2].trim().isEmpty ? parts[1].trim() : parts[2].trim();
      if (id.isEmpty || name.isEmpty) continue;
      result.add(BankUnit(id: id, name: name));
    }
    if (result.isEmpty) {
      throw const ApiException(
        kind: ApiErrorKind.protocol,
        message: '题库单位数据为空',
      );
    }
    return result;
  }

  String? _extractUnits(String html) {
    final marker = html.indexOf('var vData');
    if (marker < 0) return null;
    final start = html.indexOf('{', marker);
    if (start < 0) return null;

    var depth = 0;
    var inString = false;
    var escaped = false;
    for (var index = start; index < html.length; index++) {
      final char = html[index];
      if (inString) {
        if (escaped) {
          escaped = false;
        } else if (char == r'\') {
          escaped = true;
        } else if (char == '"') {
          inString = false;
        }
        continue;
      }
      if (char == '"') {
        inString = true;
      } else if (char == '{') {
        depth += 1;
      } else if (char == '}') {
        depth -= 1;
        if (depth == 0) {
          final jsonText = html.substring(start, index + 1);
          final decoded = jsonDecode(jsonText);
          if (decoded is Map<String, dynamic>) {
            final units = decoded['Units'];
            return units is String ? units : null;
          }
          return null;
        }
      }
    }
    return null;
  }
}
