import 'package:primelearn/core/errors/use_case_failure.dart';
import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/features/settings/domain/entities/person_profile.dart';
import 'package:primelearn/features/settings/domain/repositories/profile_repository.dart';

/// 加载个人信息（MyBaseInfo）。
class LoadProfile {
  /// 创建用例。
  LoadProfile(this._repository);

  final ProfileRepository _repository;

  /// 执行。
  Future<PersonProfile> execute(String userId) async {
    try {
      return await _repository.fetchProfile(userId);
    } on ApiException catch (error) {
      throw UseCaseFailure.fromApi(error);
    } on Object {
      throw const UseCaseFailure('加载个人信息失败，请稍后重试');
    }
  }
}
