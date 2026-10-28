import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/core/protocol/settle_crypto.dart';

String _hex(List<int> bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

void main() {
  const crypto = SettleCrypto();

  test('AES-128-ECB PKCS7 黄金向量', () {
    final key = Uint8List.fromList(List<int>.generate(16, (i) => i));
    final plain = Uint8List.fromList([
      0x00,
      0x11,
      0x22,
      0x33,
      0x44,
      0x55,
      0x66,
      0x77,
      0x88,
      0x99,
      0xaa,
      0xbb,
      0xcc,
      0xdd,
      0xee,
      0xff,
    ]);

    final encrypted = crypto.aesEcbEncrypt(plain, key);

    // 明文正好 16 字节时 PKCS7 会追加一个 0x10 填充块，故为两段密文。
    expect(
      _hex(encrypted),
      '69c4e0d86a7b0430d8cdb78070b4c55a'
      '954f64f2e4e86e9eee82d20216684899',
    );
  });

  test('生成 mxid2 / mxid3', () {
    final modulus = Uint8List(128)..fillRange(0, 128, 1);
    modulus[0] = 0x80;
    final xml =
        '<RSAKeyValue><Modulus>${base64Encode(modulus)}</Modulus>'
        '<Exponent>AQAB</Exponent></RSAKeyValue>';

    final payload = crypto.encrypt(ksmxid: 'ksmxid-1', publicKeyXml: xml);

    expect(payload.mxid2, isNotEmpty);
    expect(payload.mxid3, isNotEmpty);
    expect(base64Decode(payload.mxid3), hasLength(128));
  });

  test('缺少公钥时抛 FormatException', () {
    expect(
      () => crypto.encrypt(ksmxid: 'x', publicKeyXml: ''),
      throwsFormatException,
    );
  });
}
