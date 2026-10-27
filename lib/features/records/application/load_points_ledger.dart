import 'package:primelearn/core/errors/use_case_failure.dart';
import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/features/records/domain/entities/point_entry.dart';
import 'package:primelearn/features/records/domain/repositories/records_repository.dart';

/// 加载积分明细：按入账时间倒序。
class LoadPointsLedger {
  /// 创建用例。
  LoadPointsLedger(this._repository);

  final RecordsRepository _repository;

  /// 查询积分明细。
  Future<List<PointEntry>> execute(String userId) async {
    try {
      final entries = await _repository.fetchPointsLedger(userId);
      return [...entries]..sort((a, b) => _time(b).compareTo(_time(a)));
    } on ApiException catch (error) {
      throw UseCaseFailure.fromApi(error);
    } on Object {
      throw const UseCaseFailure('加载积分明细失败，请稍后重试');
    }
  }

  DateTime _time(PointEntry entry) =>
      entry.date ?? DateTime.fromMillisecondsSinceEpoch(0);
}
