import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/features/auth/data/parsers/login_response_parser.dart';

void main() {
  const parser = LoginResponseParser();

  test('成功解析 userId / 姓名 / 返回码', () {
    final dto = parser.parse(
      '|ec5dab3e-0000-0000-0000-000000000000|张小赞|hash|0008',
    );
    expect(dto.userId, 'ec5dab3e-0000-0000-0000-000000000000');
    expect(dto.userName, '张小赞');
    expect(dto.sessionHash, 'hash');
    expect(dto.returnCode, '0008');
  });

  test('失败文案原样抛出为协议异常', () {
    expect(
      () => parser.parse('密码错误'),
      throwsA(
        isA<ApiException>()
            .having((e) => e.kind, 'kind', ApiErrorKind.protocol)
            .having((e) => e.message, 'message', '密码错误'),
      ),
    );
  });

  test('空响应抛协议异常', () {
    expect(
      () => parser.parse(''),
      throwsA(
        isA<ApiException>().having((e) => e.message, 'message', '服务器返回空响应'),
      ),
    );
  });

  test('缺少 userId 抛协议异常', () {
    expect(
      () => parser.parse('||张小赞|hash|0008'),
      throwsA(
        isA<ApiException>().having((e) => e.message, 'message', '登录响应缺少用户标识'),
      ),
    );
  });
}
