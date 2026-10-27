import 'package:primelearn/features/exam/domain/entities/exam_paper.dart';

/// 考试数据接口。
abstract interface class ExamRepository {
  /// 查询某题库下的可考试卷。
  Future<List<ExamPaper>> fetchPapers({
    required String userId,
    required String bankId,
  });
}
