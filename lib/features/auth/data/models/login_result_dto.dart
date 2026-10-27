/// 登录接口返回结构（`|<userId>|<userName>|<sessionHash>|<returnCode>`）。
class LoginResultDto {
  /// 创建 DTO。
  const LoginResultDto({
    required this.userId,
    required this.userName,
    this.sessionHash,
    this.returnCode,
  });

  /// 用户标识，即后续接口的 `pid`。
  final String userId;

  /// 用户姓名。
  final String userName;

  /// 会话哈希（不落盘、不打日志）。
  final String? sessionHash;

  /// 返回码，例如 `0008`。
  final String? returnCode;
}
