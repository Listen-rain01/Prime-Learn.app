import 'package:primelearn/core/session/session.dart';

/// 登录页状态。
sealed class LoginState {
  const LoginState();
}

/// 初始 / 可编辑状态。
class LoginIdle extends LoginState {
  /// 创建初始状态。
  const LoginIdle();
}

/// 提交中。
class LoginSubmitting extends LoginState {
  /// 创建提交中状态。
  const LoginSubmitting();
}

/// 登录成功。
class LoginSucceeded extends LoginState {
  /// 创建成功状态。
  const LoginSucceeded(this.session);

  /// 登录成功后的会话。
  final Session session;
}

/// 登录失败。
class LoginFailed extends LoginState {
  /// 创建失败状态。
  const LoginFailed(
    this.message, {
    this.canRetry = false,
    this.sessionExpired = false,
  });

  /// 失败文案。
  final String message;

  /// 是否允许重试。
  final bool canRetry;

  /// 是否因会话失效导致。
  final bool sessionExpired;
}
