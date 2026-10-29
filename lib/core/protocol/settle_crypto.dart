import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

/// 手机考试结算加密：AES-128-ECB + RSA PKCS#1 v1.5。
///
/// 协议见 `docs/api/手机考试接口文档.md` §5.7。
class SettleCrypto {
  /// 创建加密器。
  const SettleCrypto();

  /// 生成 `mxid2` / `mxid3`。
  SettlePayload encrypt({
    required String ksmxid,
    required String publicKeyXml,
  }) {
    final modulus = _xmlValue(publicKeyXml, 'Modulus');
    final exponent = _xmlValue(publicKeyXml, 'Exponent');
    if (modulus.isEmpty || exponent.isEmpty) {
      throw const FormatException('缺少 RSA 公钥');
    }
    final key = _randomKey();
    final aesKeyB64 = base64Encode(key);
    final mxid2 = base64Encode(
      _aesEcb(Uint8List.fromList(utf8.encode(ksmxid)), key),
    );
    final mxid3 = base64Encode(
      _rsaEncrypt(utf8.encode(aesKeyB64), modulus, exponent),
    );
    return SettlePayload(mxid2: mxid2, mxid3: mxid3);
  }

  Uint8List _randomKey() {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(16, (_) => random.nextInt(256)),
    );
  }

  /// AES-128-ECB + PKCS7；公开给测试做黄金向量校验。
  Uint8List aesEcbEncrypt(Uint8List data, Uint8List key) {
    final cipher = PaddedBlockCipher('AES/ECB/PKCS7');
    cipher.init(
      true,
      PaddedBlockCipherParameters<KeyParameter, Null>(KeyParameter(key), null),
    );
    return cipher.process(data);
  }

  Uint8List _aesEcb(Uint8List data, Uint8List key) => aesEcbEncrypt(data, key);

  Uint8List _rsaEncrypt(List<int> data, String modulusB64, String exponentB64) {
    final modulus = _bigIntFromBase64(modulusB64, 'Modulus');
    final exponent = _bigIntFromBase64(exponentB64, 'Exponent');
    final publicKey = RSAPublicKey(modulus, exponent);
    // PKCS#1 v1.5 需要 11 字节填充；明文超过模数-11 会抛底层 ArgumentError，
    // 提前给出可定位的报错，避免被上层误报成「考试失败」。
    final maxBytes = (modulus.bitLength + 7) ~/ 8 - 11;
    if (data.length > maxBytes) {
      throw FormatException('RSA 公钥过短：可用 $maxBytes 字节，需要 ${data.length} 字节');
    }
    final cipher = PKCS1Encoding(RSAEngine());
    cipher.init(true, PublicKeyParameter<RSAPublicKey>(publicKey));
    return cipher.process(Uint8List.fromList(data));
  }

  BigInt _bigIntFromBase64(String value, String field) {
    // 平台公钥是 Base64；XML 换行、缩进或手工拼接常带空白，
    // 标准 Base64 解码器不接受空白字符，这里先剔除。
    final cleaned = value.replaceAll(RegExp(r'\s+'), '');
    if (cleaned.isEmpty) {
      throw FormatException('RSA 公钥 $field 为空');
    }
    final List<int> bytes;
    try {
      bytes = base64Decode(cleaned);
    } on FormatException {
      throw FormatException('RSA 公钥 $field 不是合法 Base64');
    }
    var result = BigInt.zero;
    for (final byte in bytes) {
      result = (result << 8) | BigInt.from(byte);
    }
    return result;
  }

  /// 从 RSAKeyValue XML 中取标签内容。
  ///
  /// 兼容标签带属性（`<Modulus id="x">`）、大小写差异与值跨行的写法：
  /// 真实的 XML 序列化器（如 .NET `ToXmlString`）会缩进换行。
  String _xmlValue(String xml, String tag) {
    final pattern = RegExp(
      '<$tag(?:\\s[^>]*)?>([\\s\\S]*?)</$tag>',
      caseSensitive: false,
    );
    return pattern.firstMatch(xml)?.group(1)?.trim() ?? '';
  }
}

/// 结算加密参数。
class SettlePayload {
  /// 创建参数。
  const SettlePayload({required this.mxid2, required this.mxid3});

  /// AES 加密后的 `ksmxid`（Base64）。
  final String mxid2;

  /// RSA 加密后的 AES 密钥（Base64）。
  final String mxid3;
}
