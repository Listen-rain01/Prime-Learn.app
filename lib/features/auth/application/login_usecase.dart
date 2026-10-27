import 'package:primelearn/core/errors/use_case_failure.dart';
import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/core/session/session.dart';
import 'package:primelearn/core/utils/id_card_validator.dart';
import 'package:primelearn/features/auth/domain/repositories/auth_repository.dart';

/// 登录用例：预建会话 → 登录 → 校验会话/读取题库。
///
/// 预建会话失败可重试一次（§7）；登录失败直接展示文案，不自动重试。
class LoginUseCase {
  /// 创建用例；重试间隔可注入以便测试。
  LoginUseCase(
    this._repository, {
    this.retryDelay = const Duration(seconds: 1),
  });

  final AuthRepository _repository;

  /// 预建会话失败后的重试间隔。
  final Duration retryDelay;

  /// 执行登录，返回带题库信息的会话。
  Future<Session> execute({
    required String idCard,
    required String password,
  }) async {
    final normalized = idCard.trim();
    if (!IdCardValidator.isValid(normalized)) {
      throw const UseCaseFailure('请输入有效的 18 位身份证号');
    }
    if (password.isEmpty) {
      throw const UseCaseFailure('请输入登录密码');
    }
    await _prepareSession();
    try {
      final session = await _repository.login(
        idCard: normalized,
        password: password,
      );
      final context = await _repository.fetchBankContext(session.userId);
      return session.copyWith(
        bankName: context.bankName,
        examTypeId: context.examTypeId,
      );
    } on ApiException catch (error) {
      throw UseCaseFailure.fromApi(error);
    } on Object {
      throw const UseCaseFailure('登录失败，请稍后重试');
    }
  }

  Future<void> _prepareSession() async {
    try {
      await _repository.ensureSessionCookie();
    } on ApiException catch (error) {
      if (!error.isRetryable) throw UseCaseFailure.fromApi(error);
      await Future<void>.delayed(retryDelay);
      try {
        await _repository.ensureSessionCookie();
      } on ApiException catch (retryError) {
        throw UseCaseFailure.fromApi(retryError);
      }
    }
  }
}
