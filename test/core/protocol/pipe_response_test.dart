import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/core/protocol/pipe_response.dart';

void main() {
  test('登录成功：首段为空', () {
    final response = PipeResponse.parse(
      '|ec5dab3e-0000-0000-0000-000000000000|张小赞|hash|0008',
    );
    expect(response.isSuccess, isTrue);
    expect(response.errorMessage, isNull);
    expect(response.part(1), 'ec5dab3e-0000-0000-0000-000000000000');
    expect(response.part(2), '张小赞');
    expect(response.part(4), '0008');
  });

  test('失败：首段为错误文案', () {
    final response = PipeResponse.parse('密码错误');
    expect(response.isSuccess, isFalse);
    expect(response.errorMessage, '密码错误');
  });

  test('空响应判为失败', () {
    final response = PipeResponse.parse('');
    expect(response.isSuccess, isFalse);
    expect(response.errorMessage, '服务器返回空响应');
  });

  test('首段空但无后续内容也判为成功（结构完整）', () {
    final response = PipeResponse.parse('|');
    expect(response.isSuccess, isTrue);
    expect(response.part(1), '');
  });

  test('越界下标返回 null', () {
    final response = PipeResponse.parse('|a|b');
    expect(response.part(9), isNull);
    expect(response.part(-1), isNull);
  });
}
