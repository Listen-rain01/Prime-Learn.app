import 'dart:typed_data';

import 'package:primelearn/core/errors/use_case_failure.dart';
import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/features/settings/domain/repositories/profile_repository.dart';

/// 加载头像（`GetPersonPhoto`）。
class LoadAvatar {
  /// 创建用例。
  LoadAvatar(this._repository);

  final ProfileRepository _repository;

  /// 执行。
  Future<Uint8List> execute(String userId, String departmentId) async {
    try {
      final bytes = await _repository.fetchAvatar(userId, departmentId);
      if (bytes.isEmpty) {
        throw const UseCaseFailure('头像为空');
      }
      return bytes;
    } on UseCaseFailure {
      rethrow;
    } on ApiException catch (error) {
      throw UseCaseFailure.fromApi(error);
    } on Object {
      throw const UseCaseFailure('加载头像失败');
    }
  }
}
