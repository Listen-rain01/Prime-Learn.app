import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/features/checkin/data/parsers/check_in_parser.dart';

void main() {
  const parser = CheckInParser();

  test('首次签到解析 message', () {
    final dto = parser.parse(
      '{"success": true, "data": "1239|3", "message": "操作成功"}',
    );
    expect(dto.message, '操作成功');
  });

  test('已签到解析 message', () {
    final dto = parser.parse('{"success": true, "message": "已签到"}');
    expect(dto.message, '已签到');
  });

  test('success=false 抛服务端文案', () {
    expect(
      () => parser.parse('{"success": false, "message": "请重新登录"}'),
      throwsA(isA<ApiException>().having((e) => e.message, 'message', '请重新登录')),
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
}
