import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/features/exam/data/repositories/exam_repository_impl.dart';
import 'package:primelearn/features/exam/data/services/exam_api.dart';
import 'package:primelearn/features/exam/domain/entities/exam_page.dart';

/// 只覆写结算返回，其余走真实仓储逻辑。
class _StubExamApi implements ExamApi {
  _StubExamApi(this.settleBody);

  final String settleBody;

  @override
  Future<String> settleMock(String ksmxid) async => settleBody;

  @override
  Future<String> settleMobile({
    required String ksmxid,
    required String mxid2,
    required String mxid3,
  }) async => settleBody;

  @override
  Future<String> createExam({
    required String userId,
    required String paperId,
    required int type,
  }) async => '';

  @override
  Future<String> enterExam({
    required String ksmxid,
    required String userId,
    required int style,
  }) async => '';

  @override
  Future<String> fetchExamPage() async => '';

  @override
  Future<String> fetchPapers(String userId, String bankId) async => '';

  @override
  Future<String> submitAnswers({
    required String ksmxid,
    required String answer,
  }) async => '';
}

void main() {
  Future<ExamResult> settle(String body) async =>
      ExamRepositoryImpl(_StubExamApi(body)).settleMock('k');

  test('整数分数 + 合格', () async {
    final r = await settle('您的分数为：100,合格！|100|合格！');
    expect(r.score, 100);
    expect(r.passed, isTrue);
    expect(r.message, '您的分数为：100,合格！');
  });

  test('「未合格」必须判为不合格', () async {
    final r = await settle('您的分数为：40,未合格|40|未合格');
    expect(r.score, 40);
    expect(r.passed, isFalse, reason: '未合格 同时含「合格」，不能被判成合格');
  });

  test('「不合格」判为不合格', () async {
    final r = await settle('|0|不合格');
    expect(r.passed, isFalse);
  });

  test('小数分数可解析（平台可能返回 100.0）', () async {
    final r = await settle('您的分数为：100,合格！|100.0|合格！');
    expect(r.score, 100);
    expect(r.passed, isTrue);
  });

  test('86.5 分保留四舍五入后的整数分', () async {
    final r = await settle('|86.5|合格');
    expect(r.score, 87);
    expect(r.passed, isTrue);
  });

  test('error 文本判失败', () async {
    await expectLater(
      settle('error'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          '结算失败：考试会话无效或已结算',
        ),
      ),
    );
  });

  test('空响应判失败', () async {
    await expectLater(
      settle('   '),
      throwsA(
        isA<ApiException>().having((e) => e.message, 'message', '结算返回空响应'),
      ),
    );
  });

  test('分数段无法解析时报协议异常', () async {
    await expectLater(
      settle('|abc|合格'),
      throwsA(
        isA<ApiException>().having((e) => e.message, 'message', '无法解析结算分数'),
      ),
    );
  });

  test('缺少分数段时报协议异常', () async {
    await expectLater(settle('只有文案'), throwsA(isA<ApiException>()));
  });

  test('缺少合格段时按不合格处理', () async {
    final r = await settle('|100');
    expect(r.score, 100);
    expect(r.passed, isFalse);
  });
}
