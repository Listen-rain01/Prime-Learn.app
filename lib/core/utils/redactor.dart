/// 日志与展示脱敏工具。
///
/// 规则见 AGENTS.md §9.4：身份证前 6 后 4，密码/Cookie/加密串不得出现在日志。
/// 纯函数、无依赖，按 AGENTS.md §3.2 归属 `core/utils`。
abstract final class Redactor {
  /// 身份证脱敏：保留前 6 位与后 4 位。
  static String idCard(String value) {
    final trimmed = value.trim();
    if (trimmed.length <= 10) return '***';
    final head = trimmed.substring(0, 6);
    final tail = trimmed.substring(trimmed.length - 4);
    return '$head******$tail';
  }

  /// 手机号脱敏：保留前 3 位与后 4 位。
  static String phone(String value) {
    final trimmed = value.trim();
    if (trimmed.length < 7) return '***';
    final head = trimmed.substring(0, 3);
    final tail = trimmed.substring(trimmed.length - 4);
    return '$head****$tail';
  }

  /// 任意敏感值替换为固定占位符。
  static String secret(String value) => value.isEmpty ? '' : '***';
}
