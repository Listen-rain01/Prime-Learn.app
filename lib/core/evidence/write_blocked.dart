/// 写操作被证据网关拦截时抛出；调用方不得发出 HTTP。
class WriteBlocked implements Exception {
  /// 创建拦截异常。
  const WriteBlocked(this.message);

  /// 面向用户的说明。
  final String message;

  @override
  String toString() => 'WriteBlocked($message)';
}
