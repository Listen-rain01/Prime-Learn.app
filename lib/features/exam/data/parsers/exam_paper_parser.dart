import 'package:primelearn/core/protocol/json_envelope.dart';
import 'package:primelearn/features/exam/data/models/exam_paper_dto.dart';

/// 可考试卷解析：`{totalCount, success, error, data[]}`。
class ExamPaperParser {
  /// 创建解析器。
  const ExamPaperParser();

  /// 解析试卷列表。
  List<ExamPaperDto> parse(String body) => JsonEnvelope.list(
    body,
    label: '可考试卷',
  ).map(ExamPaperDto.fromJson).toList(growable: false);
}
