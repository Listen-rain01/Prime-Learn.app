import 'package:primelearn/core/errors/use_case_failure.dart';
import 'package:primelearn/core/evidence/write_blocked.dart';
import 'package:primelearn/core/evidence/write_gateway.dart';
import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/features/exam/domain/entities/exam_page.dart';
import 'package:primelearn/features/exam/domain/entities/exam_paper.dart';
import 'package:primelearn/features/exam/domain/exam_answer_builder.dart';
import 'package:primelearn/features/exam/domain/exam_endpoints.dart';
import 'package:primelearn/features/exam/domain/repositories/exam_repository.dart';

/// 模拟考试步骤，供页面展示进度。
enum MockExamStep { create, enter, fetch, submit, settle }

/// 执行一场模拟考试：创建 → 进入 → 取题 → 提交 → 结算。
class RunMockExam {
  /// 创建用例。
  RunMockExam(this._repository, this._gateway);

  final ExamRepository _repository;
  final WriteGateway _gateway;

  /// 执行；[onStep] 用于页面进度回调。
  Future<ExamResult> execute({
    required String userId,
    required ExamPaper paper,
    void Function(MockExamStep step)? onStep,
  }) async {
    try {
      // 所有写操作先统一过网关，避免走到一半才发现被拦截。
      _gateway.ensureAllowed(createTempExamEndpoint, behavior: '创建模拟考试');
      _gateway.ensureAllowed(enterExamEndpoint, behavior: '进入模拟考试');
      _gateway.ensureAllowed(submitAnswersEndpoint, behavior: '提交模拟考试答案');
      _gateway.ensureAllowed(settleMockEndpoint, behavior: '结算模拟考试');

      onStep?.call(MockExamStep.create);
      final ksmxid = await _repository.createExam(
        userId: userId,
        paperId: paper.id,
        type: 1,
      );

      onStep?.call(MockExamStep.enter);
      await _repository.enterExam(ksmxid: ksmxid, userId: userId, style: 1);

      onStep?.call(MockExamStep.fetch);
      final page = await _repository.fetchExamPage();
      if (page.questions.isEmpty) {
        throw const UseCaseFailure('未获取到试题，已停止提交');
      }

      onStep?.call(MockExamStep.submit);
      await _repository.submitAnswers(
        ksmxid: ksmxid,
        answer: buildExamAnswer(page.questions),
      );

      onStep?.call(MockExamStep.settle);
      return await _repository.settleMock(ksmxid);
    } on WriteBlocked catch (error) {
      throw UseCaseFailure(error.message);
    } on ApiException catch (error) {
      throw UseCaseFailure.fromApi(error);
    } on UseCaseFailure {
      rethrow;
    } on Object {
      throw const UseCaseFailure('模拟考试失败，请稍后重试');
    }
  }
}
