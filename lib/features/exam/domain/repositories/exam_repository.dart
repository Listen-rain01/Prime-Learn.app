import 'package:primelearn/features/exam/domain/entities/exam_page.dart';
import 'package:primelearn/features/exam/domain/entities/exam_paper.dart';

/// 考试数据接口。
abstract interface class ExamRepository {
  /// 查询某题库下的可考试卷。
  Future<List<ExamPaper>> fetchPapers({
    required String userId,
    required String bankId,
  });

  /// 创建临时考试，返回 `ksmxid`。
  Future<String> createExam({
    required String userId,
    required String paperId,
    required int type,
  });

  /// 进入考试。
  Future<void> enterExam({
    required String ksmxid,
    required String userId,
    required int style,
  });

  /// 获取试题页。
  Future<ExamPageData> fetchExamPage();

  /// 提交全部答案。
  Future<void> submitAnswers({required String ksmxid, required String answer});

  /// 模拟考试结算。
  Future<ExamResult> settleMock(String ksmxid);
}
