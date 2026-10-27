/// 竖线分隔响应的统一解析。
///
/// 平台接口（登录、会话、结算等）返回 `|` 分隔文本：
/// 首段为空表示成功，首段非空表示错误文案。
class PipeResponse {
  const PipeResponse._(this.raw, this.parts);

  /// 按原始响应体解析；不做整体 trim，避免破坏首段分隔符。
  factory PipeResponse.parse(String body) =>
      PipeResponse._(body, body.split('|'));

  /// 原始响应体。
  final String raw;

  /// 按 `|` 切分后的段落。
  final List<String> parts;

  /// 响应体是否为空。
  bool get isEmpty => raw.isEmpty;

  /// 首段为空且响应非空才算成功。
  bool get isSuccess => !isEmpty && parts.isNotEmpty && parts.first.isEmpty;

  /// 失败文案；成功时为 null。
  String? get errorMessage {
    if (isSuccess) return null;
    if (isEmpty) return '服务器返回空响应';
    final first = parts.first;
    return first.isEmpty ? '未知错误' : first;
  }

  /// 按下标取段落，越界返回 null。
  String? part(int index) =>
      index >= 0 && index < parts.length ? parts[index] : null;
}
