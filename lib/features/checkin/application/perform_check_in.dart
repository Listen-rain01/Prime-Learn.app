import 'package:primelearn/core/errors/use_case_failure.dart';
import 'package:primelearn/core/evidence/write_blocked.dart';
import 'package:primelearn/core/evidence/write_gateway.dart';
import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/features/checkin/domain/check_in_endpoint.dart';
import 'package:primelearn/features/checkin/domain/entities/check_in_result.dart';
import 'package:primelearn/features/checkin/domain/repositories/check_in_repository.dart';

/// 执行签到：先过写网关，再发请求。
class PerformCheckIn {
  /// 创建用例。
  PerformCheckIn(this._repository, this._gateway);

  final CheckInRepository _repository;
  final WriteGateway _gateway;

  /// 执行。
  Future<CheckInResult> execute(String userId) async {
    try {
      _gateway.ensureAllowed(checkInEndpoint, behavior: '签到');
      return await _repository.checkIn(userId);
    } on WriteBlocked catch (error) {
      throw UseCaseFailure(error.message);
    } on ApiException catch (error) {
      throw UseCaseFailure.fromApi(error);
    } on Object {
      throw const UseCaseFailure('签到失败，请稍后重试');
    }
  }
}
