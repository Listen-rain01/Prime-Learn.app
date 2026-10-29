import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/core/protocol/v_data_extractor.dart';

String _html(String vData) =>
    '<html><script>var vData = $vData;</script></html>';

void main() {
  test('提取普通 vData', () {
    final result = VDataExtractor.extract(
      _html('{"Title":"个人信息","pnum":"E1"}'),
    );
    expect(result.status, VDataStatus.ok);
    expect(result.data!['Title'], '个人信息');
  });

  test('vData 值里含花括号也不会被切断', () {
    final result = VDataExtractor.extract(
      _html('{"Title":"账号{a};b","pnum":"E1"}'),
    );
    expect(result.status, VDataStatus.ok);
    expect(result.data!['Title'], '账号{a};b');
  });

  test('vData 值里含转义引号时仍能配对', () {
    final body = jsonEncode({'Title': '他说"引号"是\\转义', 'pnum': 'E1'});
    final result = VDataExtractor.extract(_html(body));
    expect(result.status, VDataStatus.ok);
    expect(result.data!['Title'], contains('引号'));
  });

  test('嵌套对象按花括号配对', () {
    final result = VDataExtractor.extract(_html('{"a":{"b":{"c":1}},"d":2}'));
    expect(result.status, VDataStatus.ok);
    final nested = result.data!['a'] as Map<String, dynamic>;
    expect(nested['b'], isA<Map<String, dynamic>>());
  });

  test('页面没有 vData 时返回 missing', () {
    expect(
      VDataExtractor.extract('<html>请先登录</html>').status,
      VDataStatus.missing,
    );
  });

  test('vData 存在但不是合法 JSON 时返回 malformed', () {
    expect(
      VDataExtractor.extract(_html('{bad json}')).status,
      VDataStatus.malformed,
    );
  });

  test('vData 是数组时返回 malformed', () {
    expect(
      VDataExtractor.extract(_html('[1,2,3]')).status,
      VDataStatus.malformed,
    );
  });

  test('vData 后没有左花括号时返回 missing 而不是崩溃', () {
    final result = VDataExtractor.extract('<script>var vData = null;</script>');
    expect(result.status, VDataStatus.missing);
  });
}
