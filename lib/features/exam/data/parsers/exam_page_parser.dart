import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/core/protocol/v_data_extractor.dart';
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
      publicKeyXml: _asText(vData['my']),
    );
  }

  Map<String, dynamic> _extractVData(String html) {
    final result = VDataExtractor.extract(html);
    switch (result.status) {
      case VDataStatus.missing:
        throw const ApiException(
          kind: ApiErrorKind.protocol,
          message: '考试页缺少 vData',
        );
      case VDataStatus.malformed:
        throw const ApiException(
          kind: ApiErrorKind.protocol,
          message: '考试页 vData 解析失败',
        );
      case VDataStatus.ok:
        return result.data!;
    }
  }

  /// 解码平台写入的 URL 编码文本。
  ///
  /// 平台对题干/选项做 URL 编码；遇到非法转义（裸 `%`、非 UTF-8 字节）
  /// 时退回原文，不能因为一个字符让整场考试不可解析。
  String _decode(String value) {
    try {
      return Uri.decodeComponent(value).trim();
    } on ArgumentError {
      return value.trim();
    } on FormatException {
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
