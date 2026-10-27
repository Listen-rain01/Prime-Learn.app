/// 错误种类，用于上层决定是否重试、是否跳转登录页。
enum ApiErrorKind {
  /// 网络不可达。
  network,

  /// 连接/接收超时。
  timeout,

  /// 服务端 5xx 或非预期状态码。
  server,

  /// 协议解析失败（空响应、文案错误、字段缺失）。
  protocol,

  /// 会话失效。
  sessionExpired,

  /// 请求被取消。
  cancelled,

  /// 未知错误。
  unknown,
}

/// 统一接口异常：数据层唯一向外抛出的异常类型。
class ApiException implements Exception {
  /// 创建接口异常。
  const ApiException({
    required this.kind,
    required this.message,
    this.endpoint,
    this.statusCode,
  });

  /// 错误种类。
  final ApiErrorKind kind;

  /// 面向用户的中文提示。
  final String message;

  /// 接口路径（不含 query 中的敏感值）。
  final String? endpoint;

  /// HTTP 状态码。
  final int? statusCode;

  /// 是否属于可重试的网络类错误（仅查询允许重试）。
  bool get isRetryable =>
      kind == ApiErrorKind.network || kind == ApiErrorKind.timeout;

  /// 是否为会话失效。
  bool get isSessionExpired => kind == ApiErrorKind.sessionExpired;

  @override
  String toString() => 'ApiException(kind: $kind, message: $message)';
}
