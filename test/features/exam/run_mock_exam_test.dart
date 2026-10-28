import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/core/errors/use_case_failure.dart';
import 'package:primelearn/core/evidence/write_evidence.dart';
import 'package:primelearn/core/evidence/write_gateway.dart';
import 'package:primelearn/core/evidence/write_level.dart';
import 'package:primelearn/features/exam/application/run_mock_exam.dart';
import 'package:primelearn/features/exam/domain/entities/exam_page.dart';
import 'package:primelearn/features/exam/domain/entities/exam_paper.dart';
import 'package:primelearn/features/exam/domain/exam_endpoints.dart';
import 'package:primelearn/features/exam/domain/repositories/exam_repository.dart';

class _FakeExamRepository implements ExamRepository {
  final List<String> calls = [];
  bool failFetch = false;

  @override
  Future<String> createExam({
    required String userId,
    required String paperId,
    required int type,
  }) async {
    calls.add('create:$type');
    return 'ksmxid-1';
  }

  @override
  Future<void> enterExam({
    required String ksmxid,
    required String userId,
    required int style,
  }) async {
    calls.add('enter:$style');
  }

  @override
  Future<ExamPageData> fetchExamPage() async {
    calls.add('fetch');
    if (failFetch) return const ExamPageData(questions: [], examTypeName: '');
    final fields = List<String>.filled(22, '');
    fields[1] = 'q1';
    fields[10] = '1';
    fields[13] = 'A';
    fields[14] = '1';
    return ExamPageData(
      questions: [
        ExamQuestion(
          fields: fields,
          type: 1,
          score: 1,
          stem: '题',
          options: const [],
        ),
      ],
      examTypeName: '模拟题库',
      totalCount: 1,
    );
  }

  @override
  Future<void> submitAnswers({
    required String ksmxid,
    required String answer,
  }) async {
    calls.add('submit:${answer.split(',').length}');
  }

  @override
  Future<ExamResult> settleMock(String ksmxid) async {
    calls.add('settle');
    return const ExamResult(score: 100, passed: true, message: '您的分数为：100,合格！');
  }

  @override
  Future<List<ExamPaper>> fetchPapers({
    required String userId,
    required String bankId,
  }) async => const [];
}

const _paper = ExamPaper(
  id: 'paper-1',
  name: '模拟试卷',
  totalScore: 100,
  passingGrade: 80,
);

WriteEvidence _verifiedEvidence() => const WriteEvidence({
  createTempExamEndpoint: WriteLevel.verified,
  enterExamEndpoint: WriteLevel.verified,
  submitAnswersEndpoint: WriteLevel.verified,
  settleMockEndpoint: WriteLevel.verified,
});

void main() {
  test('按顺序完成创建、进入、取题、提交、结算', () async {
    final repository = _FakeExamRepository();
    final useCase = RunMockExam(repository, WriteGateway(_verifiedEvidence()));
    final steps = <MockExamStep>[];

    final result = await useCase.execute(
      userId: 'u1',
      paper: _paper,
      onStep: steps.add,
    );

    expect(result.score, 100);
    expect(result.passed, isTrue);
    expect(repository.calls, [
      'create:1',
      'enter:1',
      'fetch',
      'submit:15',
      'settle',
    ]);
    expect(steps, MockExamStep.values);
  });

  test('任一写接口未验证时整体阻止，不创建考试', () async {
    final repository = _FakeExamRepository();
    final useCase = RunMockExam(
      repository,
      const WriteGateway(
        WriteEvidence({
          createTempExamEndpoint: WriteLevel.verified,
          enterExamEndpoint: WriteLevel.verified,
          submitAnswersEndpoint: WriteLevel.verified,
          settleMockEndpoint: WriteLevel.observed,
        }),
      ),
    );

    await expectLater(
      useCase.execute(userId: 'u1', paper: _paper),
      throwsA(
        isA<UseCaseFailure>().having(
          (e) => e.message,
          'message',
          contains('已阻止写入'),
        ),
      ),
    );
    expect(repository.calls, isEmpty);
  });

  test('取不到试题时停止提交', () async {
    final repository = _FakeExamRepository()..failFetch = true;
    final useCase = RunMockExam(repository, WriteGateway(_verifiedEvidence()));

    await expectLater(
      useCase.execute(userId: 'u1', paper: _paper),
      throwsA(
        isA<UseCaseFailure>().having(
          (e) => e.message,
          'message',
          contains('未获取到试题'),
        ),
      ),
    );
    expect(repository.calls, ['create:1', 'enter:1', 'fetch']);
  });
}
