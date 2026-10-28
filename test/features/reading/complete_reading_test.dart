import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/core/errors/use_case_failure.dart';
import 'package:primelearn/core/evidence/write_evidence.dart';
import 'package:primelearn/core/evidence/write_gateway.dart';
import 'package:primelearn/core/evidence/write_level.dart';
import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/features/reading/application/complete_reading.dart';
import 'package:primelearn/features/reading/domain/entities/reading_catalog.dart';
import 'package:primelearn/features/reading/domain/reading_endpoints.dart';
import 'package:primelearn/features/reading/domain/repositories/reading_repository.dart';

class _FakeReadingRepository implements ReadingRepository {
  String? completedArticle;

  @override
  Future<List<ReadingArticle>> fetchArticles({
    required String userId,
    required String typeId,
  }) async => const [];

  @override
  Future<List<ReadingCategory>> fetchCategories() async => const [];

  @override
  Future<List<ReadingCategory>> fetchChildren({
    required String parentId,
    required String departmentId,
  }) async => const [];

  @override
  Future<bool> completeReading({
    required String userId,
    required String articleId,
  }) async {
    completedArticle = articleId;
    return true;
  }
}

const _preset = ReadingPreset(articleId: 'article-1', title: '顶板伤人事故');

void main() {
  test('证据 verified 时调用接口并返回完成状态', () async {
    final repository = _FakeReadingRepository();
    final useCase = CompleteReading(
      repository,
      const WriteGateway(
        WriteEvidence({studyKnowledgeEndpoint: WriteLevel.verified}),
      ),
    );

    final completed = await useCase.execute(userId: 'u1', preset: _preset);

    expect(completed, isTrue);
    expect(repository.completedArticle, 'article-1');
  });

  test('证据 observed 时阻止写入', () async {
    final repository = _FakeReadingRepository();
    final useCase = CompleteReading(
      repository,
      const WriteGateway(
        WriteEvidence({studyKnowledgeEndpoint: WriteLevel.observed}),
      ),
    );

    await expectLater(
      useCase.execute(userId: 'u1', preset: _preset),
      throwsA(
        isA<UseCaseFailure>().having(
          (e) => e.message,
          'message',
          contains('已阻止写入'),
        ),
      ),
    );
    expect(repository.completedArticle, isNull);
  });

  test('接口失败映射为 UseCaseFailure', () async {
    final useCase = CompleteReading(
      _FailingRepository(),
      const WriteGateway(
        WriteEvidence({studyKnowledgeEndpoint: WriteLevel.verified}),
      ),
    );

    await expectLater(
      useCase.execute(userId: 'u1', preset: _preset),
      throwsA(
        isA<UseCaseFailure>().having((e) => e.message, 'message', '今日已达上限'),
      ),
    );
  });

  test('今日已达上限时返回 false 而不是报错', () async {
    final useCase = CompleteReading(
      _CappedRepository(),
      const WriteGateway(
        WriteEvidence({studyKnowledgeEndpoint: WriteLevel.verified}),
      ),
    );

    final completed = await useCase.execute(userId: 'u1', preset: _preset);

    expect(completed, isFalse);
  });
}

class _CappedRepository extends _FakeReadingRepository {
  @override
  Future<bool> completeReading({
    required String userId,
    required String articleId,
  }) async => false;
}

class _FailingRepository extends _FakeReadingRepository {
  @override
  Future<bool> completeReading({
    required String userId,
    required String articleId,
  }) async {
    throw const ApiException(kind: ApiErrorKind.protocol, message: '今日已达上限');
  }
}
