/// 平台 `Esdt` 参数混淆。
///
/// 算法（docs/api/登录接口文档.md §3）：
/// 1. 对输入逐个 UTF-16 码元取十进制字符串并拼接；
/// 2. 追加 `^`；
/// 3. 追加每个十进制串的长度，用 `,` 连接；
/// 4. 对结果执行 ECMAScript 遗留 `escape()`。
///
/// 注意：这只是平台协议混淆，不构成加密。
class EsdtCodec {
  /// 创建编码器。
  const EsdtCodec();

  /// 需要原样保留的字符（ECMAScript `escape()` 规则）。
  static const String _preserved =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789@*_+-./';

  /// 将明文编码为平台要求的 `Esdt` 参数。
  String encode(String input) {
    if (input.isEmpty) return '';
    final digits = StringBuffer();
    final lengths = <String>[];
    for (final unit in input.codeUnits) {
      final decimal = unit.toString();
      digits.write(decimal);
      lengths.add('${decimal.length}');
    }
    final raw = '$digits^${lengths.join(',')}';
    return _escape(raw);
  }

  String _escape(String text) {
    final buffer = StringBuffer();
    for (final unit in text.codeUnits) {
      final char = String.fromCharCode(unit);
      if (_preserved.contains(char)) {
        buffer.write(char);
      } else if (unit < 0x100) {
        buffer.write('%${_hex(unit, 2)}');
      } else {
        buffer.write('%u${_hex(unit, 4)}');
      }
    }
    return buffer.toString();
  }

  String _hex(int value, int width) =>
      value.toRadixString(16).toUpperCase().padLeft(width, '0');
}
