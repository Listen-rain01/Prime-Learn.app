import 'dart:convert';

import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/features/settings/data/models/person_profile_dto.dart';

/// 个人信息响应解析。
///
/// `POST /PersonWap/MyBaseInfo` 返回 HTML，基础资料在 HTML 内嵌的
/// `var vData = { ... };` 里，因此需要先从 HTML 中提取 JSON。
/// 只读取白名单字段，其余内容（含照片路径等）不保留。
class PersonProfileParser {
  /// 创建解析器。
  const PersonProfileParser();

  /// 从 HTML 中解析个人信息。
  PersonProfileDto parse(String html) {
    if (html.isEmpty) {
      throw const ApiException(
        kind: ApiErrorKind.protocol,
        message: '服务器返回空响应',
      );
    }

    final jsonText = _extractVData(html);
    if (jsonText == null) {
      throw const ApiException(
        kind: ApiErrorKind.protocol,
        message: '个人信息响应缺少数据',
      );
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(jsonText);
    } on FormatException {
      throw const ApiException(
        kind: ApiErrorKind.protocol,
        message: '个人信息数据格式异常',
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw const ApiException(
        kind: ApiErrorKind.protocol,
        message: '个人信息数据格式异常',
      );
    }

    final dto = PersonProfileDto.fromVData(decoded);
    if (dto.name.isEmpty && dto.idCard.isEmpty) {
      throw const ApiException(kind: ApiErrorKind.protocol, message: '个人信息为空');
    }
    return dto;
  }

  /// 找到 `vData` 后第一个 `{`，按花括号配对截取 JSON（跳过字符串内的括号）。
  String? _extractVData(String html) {
    final marker = html.indexOf('vData');
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
        if (depth == 0) return html.substring(start, index + 1);
      }
    }
    return null;
  }
}
