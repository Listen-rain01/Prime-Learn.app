/// 会话失效信号识别。
///
/// 规则见 AGENTS.md §8.11：不能假设过期只表现为 401；
/// 登录页 HTML 是高置信度信号，普通业务错误不得判为过期。
abstract final class SessionDetector {
  /// 判断响应是否为登录页 HTML（高置信度会话失效信号）。
  static bool looksLikeLoginPage(String? contentType, String? body) {
    if (contentType == null ||
        !contentType.toLowerCase().contains('text/html')) {
      return false;
    }
    if (body == null) return false;
    final lower = body.toLowerCase();
    return lower.contains('login') || body.contains('登录');
  }
}
