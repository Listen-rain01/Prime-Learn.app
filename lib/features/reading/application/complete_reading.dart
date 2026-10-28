import 'package:primelearn/core/errors/use_case_failure.dart';
import 'package:primelearn/core/evidence/write_blocked.dart';
import 'package:primelearn/core/evidence/write_gateway.dart';
import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/features/reading/domain/entities/reading_catalog.dart';
import 'package:primelearn/features/reading/domain/reading_endpoints.dart';
import 'package:primelearn/features/reading/domain/repositories/reading_repository.dart';

/// 完成阅读：先过写网关，再调用计分接口。
class CompleteReading {
  /// 创建用例。
  CompleteReading(this._repository, this._gateway);

  final ReadingRepository _repository;
  final WriteGateway _gateway;

  /// 执行；返回 `true` 表示本次完成，`false` 表示今日已达上限。
  Future<bool> execute({
    required String userId,
    required ReadingPreset preset,
  }) async {
    try {
      _gateway.ensureAllowed(studyKnowledgeEndpoint, behavior: '完成阅读');
      return await _repository.completeReading(
        userId: userId,
        articleId: preset.articleId,
      );
    } on WriteBlocked catch (error) {
      throw UseCaseFailure(error.message);
    } on ApiException catch (error) {
      throw UseCaseFailure.fromApi(error);
    } on Object {
      throw const UseCaseFailure('完成阅读失败，请稍后重试');
    }
  }
}
