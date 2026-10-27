import 'package:primelearn/core/errors/use_case_failure.dart';
import 'package:primelearn/core/evidence/write_blocked.dart';
import 'package:primelearn/core/evidence/write_gateway.dart';
import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/features/settings/domain/bank_endpoints.dart';
import 'package:primelearn/features/settings/domain/entities/bank_catalog.dart';
import 'package:primelearn/features/settings/domain/repositories/bank_repository.dart';

/// 执行考试/答题前对齐题库预设。
///
/// 当前题库与预设一致返回 false；不一致则经写网关切换并返回 true。
class EnsureBankPreset {
  /// 创建用例。
  EnsureBankPreset(this._repository, this._gateway);

  final BankRepository _repository;
  final WriteGateway _gateway;

  /// 执行。
  Future<bool> execute({
    required String userId,
    required String currentBankId,
    required BankPreset preset,
  }) async {
    if (currentBankId == preset.bankId) return false;
    try {
      _gateway.ensureAllowed(bankSaveEndpoint, behavior: '题库切换');
      await _repository.saveBank(userId, preset.bankId);
      return true;
    } on WriteBlocked catch (error) {
      throw UseCaseFailure(error.message);
    } on ApiException catch (error) {
      throw UseCaseFailure.fromApi(error);
    } on Object {
      throw const UseCaseFailure('切换题库失败，请稍后重试');
    }
  }
}
