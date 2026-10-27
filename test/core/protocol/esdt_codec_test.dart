import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/core/protocol/esdt_codec.dart';

void main() {
  const codec = EsdtCodec();

  test('文档 §3 示例：123', () {
    expect(codec.encode('123'), '495051%5E2%2C2%2C2');
  });

  test('文档 §3 示例：A1', () {
    expect(codec.encode('A1'), '6549%5E2%2C2');
  });

  test('空串编码为空串', () {
    expect(codec.encode(''), '');
  });

  test('消费独立生成的黄金向量', () {
    final file = File('test/vectors/esdt/vectors.json');
    expect(file.existsSync(), isTrue, reason: '向量文件缺失');
    final decoded = jsonDecode(file.readAsStringSync());
    final vectors =
        (decoded as Map<String, dynamic>)['vectors'] as List<dynamic>;
    expect(vectors, isNotEmpty);

    for (final item in vectors) {
      final map = item as Map<String, dynamic>;
      final input = map['input'] as String;
      final expected = map['expected'] as String;
      expect(
        codec.encode(input),
        expected,
        reason: 'Esdt 编码与向量不一致：input=$input',
      );
    }
  });
}
