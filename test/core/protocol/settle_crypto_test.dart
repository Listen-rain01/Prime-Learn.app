import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/core/protocol/settle_crypto.dart';

String _xml(String modulus, {String exponent = 'AQAB'}) =>
    '<RSAKeyValue><Modulus>$modulus</Modulus>'
    '<Exponent>$exponent</Exponent></RSAKeyValue>';

String _modulus128() {
  final bytes = Uint8List(128)..fillRange(0, 128, 7);
  bytes[0] = 0x80;
  return base64Encode(bytes);
}

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
    final hex = crypto
        .aesEcbEncrypt(plain, key)
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    // 明文正好 16 字节时 PKCS7 会追加一个 0x10 填充块，故为两段密文。
    expect(
      hex,
      '69c4e0d86a7b0430d8cdb78070b4c55a'
      '954f64f2e4e86e9eee82d20216684899',
    );
  });

  test('生成 mxid2 / mxid3', () {
    final xml = _xml(_modulus128());
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

  test('XML 缩进换行（.NET ToXmlString 风格）可加密', () {
    final xml =
        '<RSAKeyValue>\n  <Modulus>${_modulus128()}</Modulus>\n'
        '  <Exponent>AQAB</Exponent>\n</RSAKeyValue>';
    expect(
      () => crypto.encrypt(ksmxid: 'k', publicKeyXml: xml),
      returnsNormally,
    );
  });

  test('Modulus 值内部含换行时剔除空白后仍可加密', () {
    final m = _modulus128();
    final wrapped = '${m.substring(0, 64)}\n${m.substring(64)}';
    expect(
      () => crypto.encrypt(ksmxid: 'k', publicKeyXml: _xml(wrapped)),
      returnsNormally,
    );
  });

  test('Modulus 值内部含空格时剔除空白后仍可加密', () {
    final m = _modulus128();
    final spaced = '${m.substring(0, 20)} ${m.substring(20)}';
    expect(
      () => crypto.encrypt(ksmxid: 'k', publicKeyXml: _xml(spaced)),
      returnsNormally,
    );
  });

  test('标签带属性时可解析', () {
    final xml =
        '<RSAKeyValue><Modulus id="m">${_modulus128()}</Modulus>'
        '<Exponent>AQAB</Exponent></RSAKeyValue>';
    expect(
      () => crypto.encrypt(ksmxid: 'k', publicKeyXml: xml),
      returnsNormally,
    );
  });

  test('标签大小写不一致时可解析', () {
    final m = _modulus128();
    final xml =
        '<rsakeyvalue><modulus>$m</modulus>'
        '<exponent>AQAB</exponent></rsakeyvalue>';
    expect(
      () => crypto.encrypt(ksmxid: 'k', publicKeyXml: xml),
      returnsNormally,
    );
  });

  test('Modulus 不是合法 Base64 时报 FormatException', () {
    expect(
      () => crypto.encrypt(ksmxid: 'x', publicKeyXml: _xml('not base64!!!')),
      throwsFormatException,
    );
  });

  test('模数过短时给出可定位的报错', () {
    final tiny = base64Encode(List<int>.filled(32, 1));
    expect(
      () => crypto.encrypt(ksmxid: 'x', publicKeyXml: _xml(tiny)),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('RSA 公钥过短'),
        ),
      ),
    );
  });

  test('每次加密使用不同随机密钥（填充随机化）', () {
    final a = crypto.encrypt(ksmxid: 'k', publicKeyXml: _xml(_modulus128()));
    final b = crypto.encrypt(ksmxid: 'k', publicKeyXml: _xml(_modulus128()));
    expect(a.mxid3, isNot(b.mxid3));
  });
}
