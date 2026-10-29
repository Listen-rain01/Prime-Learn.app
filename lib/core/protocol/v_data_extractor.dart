import 'dart:convert';

/// 提取结果状态。
enum VDataStatus {
  /// 页面里没有 `vData` 标记。
  missing,

  /// 找到了标记，但 JSON 非法或不是对象。
  malformed,

  /// 解析成功。
  ok,
}

/// `vData` 的提取结果。
class VDataResult {
  /// 创建结果。
  const VDataResult(this.status, [this.data]);

  /// 结果状态。
  final VDataStatus status;

  /// 解析出的对象；仅 [VDataStatus.ok] 时非空。
  final Map<String, dynamic>? data;
}

/// 从平台 HTML 页面中提取内嵌的 `var vData = { ... };`。
///
/// 平台把 JSON 直接写进页面脚本，三个页面（考试页、个人信息、题库单位）
/// 都是同一形态，因此统一在这里处理，避免各处各写一份正则/截取逻辑。
///
/// 区分「没有 vData」（可能是接口返回了别的页面）与「vData 存在但坏掉」
/// （格式回归），让上层能给出不同提示。
abstract final class VDataExtractor {
  /// 标记名，页面里写作 `var vData`。
  static const String _marker = 'vData';

  /// 提取并解析 `vData`。
  static VDataResult extract(String html) {
    final marker = html.indexOf(_marker);
    if (marker < 0) return const VDataResult(VDataStatus.missing);

    // 标记之后先出现的若不是 `{`，说明 vData 被写成了数组/字面量等非对象；
    // 与「页面里根本没有 vData」是两种不同的问题，不能混为一谈。
    final start = html.indexOf('{', marker);
    final bracket = html.indexOf('[', marker);
    final looksNonObject = start < 0 || (bracket >= 0 && bracket < start);
    if (looksNonObject) {
      final jsonText =
          _scan(html, marker, open: '[', close: ']') ??
          _scan(html, marker, open: '{', close: '}');
      if (jsonText == null) return const VDataResult(VDataStatus.missing);
      // 能取到字面量但不是对象 → 格式异常。
      return const VDataResult(VDataStatus.malformed);
    }

    final jsonText = _scan(html, marker, open: '{', close: '}');
    if (jsonText == null) return const VDataResult(VDataStatus.missing);
    try {
      final decoded = jsonDecode(jsonText);
      if (decoded is! Map<String, dynamic>) {
        return const VDataResult(VDataStatus.malformed);
      }
      return VDataResult(VDataStatus.ok, decoded);
    } on FormatException {
      return const VDataResult(VDataStatus.malformed);
    }
  }

  /// 从 [marker] 之后第一个 [open] 开始，按配对规则截取到对应的 [close]。
  ///
  /// 用**括号配对**而不是查找第一个 `};`：题干、选项、地址等字段
  /// 可能包含 `}`、`;` 字符，按字面量截断会切坏 JSON。
  /// 配对时跳过字符串内部的内容与转义字符（字符串只由 `"` 界定）。
  static String? _scan(
    String html,
    int marker, {
    required String open,
    required String close,
  }) {
    final start = html.indexOf(open, marker);
    if (start < 0) return null;

    var depth = 0;
    var inString = false;
    var escaped = false;
    for (var index = start; index < html.length; index++) {
      final char = html[index];
      if (inString) {
        if (escaped) {
          escaped = false;
        } else if (char == r'\') {
          escaped = true;
        } else if (char == '"') {
          inString = false;
        }
        continue;
      }
      if (char == '"') {
        inString = true;
      } else if (char == open) {
        depth += 1;
      } else if (char == close) {
        depth -= 1;
        if (depth == 0) return html.substring(start, index + 1);
      }
    }
    return null;
  }
}
