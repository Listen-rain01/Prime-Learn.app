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
    final publicKey = RSAPublicKey(
      _bigIntFromBase64(modulusB64),
      _bigIntFromBase64(exponentB64),
    );
    final cipher = PKCS1Encoding(RSAEngine());
    cipher.init(true, PublicKeyParameter<RSAPublicKey>(publicKey));
    return cipher.process(Uint8List.fromList(data));
  }

  BigInt _bigIntFromBase64(String value) {
    final bytes = base64Decode(value);
    var result = BigInt.zero;
    for (final byte in bytes) {
      result = (result << 8) | BigInt.from(byte);
    }
    return result;
  }

  String _xmlValue(String xml, String tag) {
    final match = RegExp('<$tag>(.*?)</$tag>').firstMatch(xml);
    return match?.group(1)?.trim() ?? '';
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
