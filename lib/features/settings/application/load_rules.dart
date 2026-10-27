import 'package:primelearn/core/errors/use_case_failure.dart';
import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/features/settings/domain/repositories/settings_repository.dart';

/// 加载积分规则文本。
class LoadRules {
  /// 创建用例。
  LoadRules(this._repository);

  final SettingsRepository _repository;

  /// 执行。
  Future<String> execute(String userId) async {
    try {
      return await _repository.fetchRulesText(userId);
    } on ApiException catch (error) {
      throw UseCaseFailure.fromApi(error);
    } on Object {
      throw const UseCaseFailure('加载积分规则失败，请稍后重试');
    }
  }
}
