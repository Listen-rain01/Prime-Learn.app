import 'package:primelearn/features/exam/domain/entities/exam_page.dart';

/// 构造 `DoWriteAnswerAll` 的 answer 串。
///
/// 平台要求：每条题取 0–14 字段，字段 4 回填字段 13（正确答案），
/// 题目之间用 `|` 连接。
String buildExamAnswer(Iterable<ExamQuestion> questions) => questions
    .map((question) {
      final fields = question.fields.sublist(0, 15);
      fields[4] = fields[13];
      return fields.join(',');
    })
    .join('|');
