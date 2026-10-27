import 'package:primelearn/core/network/api_exception.dart';

/// 积分规则页 HTML → 纯文本。
///
/// 平台返回服务端静态 HTML；本项目禁止 WebView，
/// 这里按标签去壳，仅用于文本展示。
class RulesHtmlParser {
  /// 创建解析器。
  const RulesHtmlParser();

  /// 提取纯文本；空内容抛协议异常。
  String parse(String html) {
    if (html.trim().isEmpty) {
      throw const ApiException(
        kind: ApiErrorKind.protocol,
        message: '服务器返回空响应',
      );
    }

    var text = html
        .replaceAll(
          RegExp(r'<script[\s\S]*?</script>', caseSensitive: false),
          '',
        )
        .replaceAll(RegExp(r'<style[\s\S]*?</style>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(
          RegExp(r'</(?:p|div|li|tr|h[1-6]|ul|ol)>', caseSensitive: false),
          '\n',
        )
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&#160;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");

    // 服务端 HTML 里有大量空段落/缩进，逐层规整成「段落间最多一个空行」。
    text = text
        .replaceAll('\r', '')
        .replaceAll(RegExp(r'[ \t\u00a0]+'), ' ')
        .replaceAll(RegExp(r' *\n *'), '\n')
        .replaceAll(RegExp(r'\n{2,}'), '\n\n')
        .trim();

    if (text.isEmpty) {
      throw const ApiException(kind: ApiErrorKind.protocol, message: '积分规则为空');
    }
    return text;
  }
}
