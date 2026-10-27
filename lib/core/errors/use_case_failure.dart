import 'package:primelearn/core/network/api_exception.dart';

/// 用例失败：application 层向 presentation 暴露的唯一失败类型。
class UseCaseFailure implements Exception {
  /// 创建用例失败。
  const UseCaseFailure(
    this.message, {
    this.canRetry = false,
    this.sessionExpired = false,
  });

  /// 由接口异常映射为用例失败。
  factory UseCaseFailure.fromApi(ApiException error) => UseCaseFailure(
    error.message,
    canRetry: error.isRetryable,
    sessionExpired: error.isSessionExpired,
  );

  /// 面向用户的中文提示。
  final String message;

  /// 是否允许用户手动重试。
  final bool canRetry;

  /// 是否因会话失效导致。
  final bool sessionExpired;

  @override
  String toString() => 'UseCaseFailure($message)';
}
