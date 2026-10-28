import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/core/errors/use_case_failure.dart';
import 'package:primelearn/core/evidence/write_evidence.dart';
import 'package:primelearn/core/evidence/write_gateway.dart';
import 'package:primelearn/core/evidence/write_level.dart';
import 'package:primelearn/features/exam/application/run_exam.dart';
import 'package:primelearn/features/exam/domain/entities/exam_page.dart';
import 'package:primelearn/features/exam/domain/entities/exam_paper.dart';
import 'package:primelearn/features/exam/domain/exam_endpoints.dart';
import 'package:primelearn/features/exam/domain/repositories/exam_repository.dart';

class _FakeExamRepository implements ExamRepository {
  final List<String> calls = [];
  String? mobileMxid2;
  String? mobileMxid3;
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
    final modulus = Uint8List(128)..fillRange(0, 128, 1);
    modulus[0] = 0x80;
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
      examTypeName: '考试题库',
      totalCount: 1,
      publicKeyXml:
          '<RSAKeyValue><Modulus>${base64Encode(modulus)}</Modulus>'
          '<Exponent>AQAB</Exponent></RSAKeyValue>',
    );
  }

  @override
  Future<void> submitAnswers({
    required String ksmxid,
    required String answer,
  }) async {
    calls.add('submit');
  }

  @override
  Future<ExamResult> settleMock(String ksmxid) async {
    calls.add('settleMock');
    return const ExamResult(score: 100, passed: true, message: '合格');
  }

  @override
  Future<ExamResult> settleMobile({
    required String ksmxid,
    required String mxid2,
    required String mxid3,
  }) async {
    calls.add('settleMobile');
    mobileMxid2 = mxid2;
    mobileMxid3 = mxid3;
    return const ExamResult(score: 100, passed: true, message: '合格');
  }

  @override
  Future<List<ExamPaper>> fetchPapers({
    required String userId,
    required String bankId,
  }) async => const [];
}

const _paper = ExamPaper(
  id: 'paper-1',
  name: '试卷',
  totalScore: 100,
  passingGrade: 80,
);

WriteEvidence _evidence({bool mobileVerified = false}) => WriteEvidence({
  createTempExamEndpoint: WriteLevel.verified,
  enterExamEndpoint: WriteLevel.verified,
  submitAnswersEndpoint: WriteLevel.verified,
  settleMockEndpoint: WriteLevel.verified,
  if (mobileVerified) settleMobileEndpoint: WriteLevel.verified,
});

void main() {
  test('模拟考试按 type=1 / style=1 执行并走空加密结算', () async {
    final repository = _FakeExamRepository();
    final useCase = RunExam(repository, WriteGateway(_evidence()));
    final steps = <ExamStep>[];

    final result = await useCase.execute(
      kind: ExamKind.mock,
      userId: 'u1',
      paper: _paper,
      onStep: steps.add,
    );

    expect(result.score, 100);
    expect(repository.calls, [
      'create:1',
      'enter:1',
      'fetch',
      'submit',
      'settleMock',
    ]);
    expect(steps, ExamStep.values);
  });

  test('手机考试按 type=2 / style=0 执行并携带加密参数', () async {
    final repository = _FakeExamRepository();
    final useCase = RunExam(
      repository,
      WriteGateway(_evidence(mobileVerified: true)),
    );

    final result = await useCase.execute(
      kind: ExamKind.mobile,
      userId: 'u1',
      paper: _paper,
    );

    expect(result.score, 100);
    expect(repository.calls, [
      'create:2',
      'enter:0',
      'fetch',
      'submit',
      'settleMobile',
    ]);
    expect(repository.mobileMxid2, isNotEmpty);
    expect(repository.mobileMxid3, isNotEmpty);
  });

  test('结算未验证时整体阻止，不创建考试', () async {
    final repository = _FakeExamRepository();
    final useCase = RunExam(repository, WriteGateway(_evidence()));

    await expectLater(
      useCase.execute(kind: ExamKind.mobile, userId: 'u1', paper: _paper),
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
    final useCase = RunExam(repository, WriteGateway(_evidence()));

    await expectLater(
      useCase.execute(kind: ExamKind.mock, userId: 'u1', paper: _paper),
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
