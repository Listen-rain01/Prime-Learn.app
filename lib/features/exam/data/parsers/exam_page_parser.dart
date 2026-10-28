import 'dart:convert';

import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/features/exam/domain/entities/exam_page.dart';

/// 考试页 HTML 解析：提取 `var vData` 并展开题目。
class ExamPageParser {
  /// 创建解析器。
  const ExamPageParser();

  /// 解析考试页。
  ExamPageData parse(String html) {
    final vData = _extractVData(html);
    final rawArray = vData['AllQuestionArray'];
    if (rawArray is! String || rawArray.trim().isEmpty) {
      throw const ApiException(
        kind: ApiErrorKind.protocol,
        message: '未获取到试题数据',
      );
    }

    final questions = <ExamQuestion>[];
    for (final record in rawArray.split('|')) {
      if (record.trim().isEmpty) continue;
      final fields = record.split(',');
      // 平台会省略尾部空字段，提交答案只需要前 15 个字段。
      if (fields.length < 15) {
        throw const ApiException(
          kind: ApiErrorKind.protocol,
          message: '试题字段数量异常',
        );
      }
      questions.add(
        ExamQuestion(
          fields: fields,
          type: _asInt(fields[14]),
          score: _asInt(fields[10]),
          stem: fields.length > 15 ? _decode(fields[15]) : '',
          options: fields.length > 16
              ? fields[16]
                    .split('#')
                    .map(_decode)
                    .where((text) => text.trim().isNotEmpty)
                    .toList(growable: false)
              : const [],
        ),
      );
    }

    return ExamPageData(
      questions: questions,
      examTypeName: _asText(vData['ExamTypeName']),
      totalCount: _asInt(vData['AllCount']),
    );
  }

  Map<String, dynamic> _extractVData(String html) {
    final marker = html.indexOf('var vData');
    if (marker < 0) {
      throw const ApiException(
        kind: ApiErrorKind.protocol,
        message: '考试页缺少 vData',
      );
    }
    final start = html.indexOf('{', marker);
    final end = html.indexOf('};', start);
    if (start < 0 || end < 0) {
      throw const ApiException(
        kind: ApiErrorKind.protocol,
        message: '考试页 vData 格式异常',
      );
    }
    final Object? decoded;
    try {
      decoded = jsonDecode(html.substring(start, end + 1));
    } on FormatException {
      throw const ApiException(
        kind: ApiErrorKind.protocol,
        message: '考试页 vData 解析失败',
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw const ApiException(
        kind: ApiErrorKind.protocol,
        message: '考试页 vData 类型异常',
      );
    }
    return decoded;
  }

  String _decode(String value) {
    try {
      return Uri.decodeComponent(value).trim();
    } on ArgumentError {
      return value.trim();
    }
  }

  int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim()) ?? 0;
    return 0;
  }

  String _asText(Object? value) => value?.toString().trim() ?? '';
}
