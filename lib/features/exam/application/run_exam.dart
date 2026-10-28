import 'package:primelearn/core/errors/use_case_failure.dart';
import 'package:primelearn/core/evidence/write_blocked.dart';
import 'package:primelearn/core/evidence/write_gateway.dart';
import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/core/protocol/settle_crypto.dart';
import 'package:primelearn/features/exam/domain/entities/exam_page.dart';
import 'package:primelearn/features/exam/domain/entities/exam_paper.dart';
import 'package:primelearn/features/exam/domain/exam_answer_builder.dart';
import 'package:primelearn/features/exam/domain/exam_endpoints.dart';
import 'package:primelearn/features/exam/domain/repositories/exam_repository.dart';

/// 考试类型：模拟 / 手机。
enum ExamKind {
  /// 模拟考试（type=1 / style=1 / CEndTimeMobil）。
  mock,

  /// 手机考试（type=2 / style=0 / CEndTimeOne 加密结算）。
  mobile,
}

extension ExamKindX on ExamKind {
  /// `CreateTempExamOne.type`。
  int get createType => this == ExamKind.mock ? 1 : 2;

  /// `SetOnlineTestOne.style`。
  int get enterStyle => this == ExamKind.mock ? 1 : 0;

  /// 结算接口。
  String get settleEndpoint =>
      this == ExamKind.mock ? settleMockEndpoint : settleMobileEndpoint;
}

/// 考试步骤，供页面展示进度。
enum ExamStep { create, enter, fetch, submit, settle }

/// 执行一场考试：创建 → 进入 → 取题 → 提交 → 结算。
class RunExam {
  /// 创建用例。
  RunExam(this._repository, this._gateway);

  final ExamRepository _repository;
  final WriteGateway _gateway;

  /// 执行；[onStep] 用于页面进度回调。
  Future<ExamResult> execute({
    required ExamKind kind,
    required String userId,
    required ExamPaper paper,
    void Function(ExamStep step)? onStep,
  }) async {
    try {
      // 所有写操作先统一过网关，避免走到一半才发现被拦截。
      _gateway.ensureAllowed(createTempExamEndpoint, behavior: '创建考试');
      _gateway.ensureAllowed(enterExamEndpoint, behavior: '进入考试');
      _gateway.ensureAllowed(submitAnswersEndpoint, behavior: '提交考试答案');
      _gateway.ensureAllowed(kind.settleEndpoint, behavior: '结算考试');

      onStep?.call(ExamStep.create);
      final ksmxid = await _repository.createExam(
        userId: userId,
        paperId: paper.id,
        type: kind.createType,
      );

      onStep?.call(ExamStep.enter);
      await _repository.enterExam(
        ksmxid: ksmxid,
        userId: userId,
        style: kind.enterStyle,
      );

      onStep?.call(ExamStep.fetch);
      final page = await _repository.fetchExamPage();
      if (page.questions.isEmpty) {
        throw const UseCaseFailure('未获取到试题，已停止提交');
      }

      onStep?.call(ExamStep.submit);
      await _repository.submitAnswers(
        ksmxid: ksmxid,
        answer: buildExamAnswer(page.questions),
      );

      onStep?.call(ExamStep.settle);
      final ExamResult settled;
      if (kind == ExamKind.mock) {
        settled = await _repository.settleMock(ksmxid);
      } else {
        final payload = const SettleCrypto().encrypt(
          ksmxid: ksmxid,
          publicKeyXml: page.publicKeyXml,
        );
        settled = await _repository.settleMobile(
          ksmxid: ksmxid,
          mxid2: payload.mxid2,
          mxid3: payload.mxid3,
        );
      }
      return ExamResult(
        score: settled.score,
        passed: settled.passed,
        message: settled.message,
        questionCount: page.questions.length,
      );
    } on WriteBlocked catch (error) {
      throw UseCaseFailure(error.message);
    } on ApiException catch (error) {
      throw UseCaseFailure.fromApi(error);
    } on FormatException {
      throw const UseCaseFailure('结算公钥缺失，无法加密');
    } on UseCaseFailure {
      rethrow;
    } on Object {
      throw const UseCaseFailure('考试失败，请稍后重试');
    }
  }
}
