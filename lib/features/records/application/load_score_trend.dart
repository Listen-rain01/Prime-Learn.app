import 'package:primelearn/core/errors/use_case_failure.dart';
import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/features/records/domain/entities/score_trend_point.dart';
import 'package:primelearn/features/records/domain/repositories/records_repository.dart';

/// 加载个人成绩趋势。
class LoadScoreTrend {
  /// 创建用例。
  LoadScoreTrend(this._repository);

  final RecordsRepository _repository;

  /// 执行。
  Future<List<ScoreTrendPoint>> execute(String userId) async {
    try {
      return await _repository.fetchScoreTrend(userId);
    } on ApiException catch (error) {
      throw UseCaseFailure.fromApi(error);
    } on Object {
      throw const UseCaseFailure('加载成绩趋势失败，请稍后重试');
    }
  }
}
