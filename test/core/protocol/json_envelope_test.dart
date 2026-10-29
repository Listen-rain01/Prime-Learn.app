import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/core/protocol/json_envelope.dart';

void main() {
  test('success=false 时优先取 message', () {
    expect(
      () => JsonEnvelope.decode(
        '{"success":false,"message":"已达到或超过每日最多积分!"}',
        label: '完成阅读',
      ),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          '已达到或超过每日最多积分!',
        ),
      ),
    );
  });

  test('success=false 且只有 error 字段时取 error（平台部分接口如此）', () {
    expect(
      () => JsonEnvelope.decode(
        '{"success":false,"error":"当前账号未分配题库","data":null}',
        label: '可考试卷',
      ),
      throwsA(
        isA<ApiException>().having((e) => e.message, 'message', '当前账号未分配题库'),
      ),
    );
  });

  test('success 为字符串 "false" 时也判失败', () {
    expect(
      () => JsonEnvelope.decode(
        '{"success":"false","message":"令牌失效"}',
        label: '今日任务',
      ),
      throwsA(isA<ApiException>().having((e) => e.message, 'message', '令牌失效')),
    );
  });

  test('success 为字符串 "true" 时按成功处理', () {
    final decoded = JsonEnvelope.decode(
      '{"success":"true","data":[]}',
      label: '今日任务',
    );
    expect(decoded['success'], 'true');
  });

  test('success 缺失时按成功处理（部分接口没有该字段）', () {
    final decoded = JsonEnvelope.decode('{"total":1,"rows":[]}', label: '趋势');
    expect(decoded['total'], 1);
  });

  test('data 为 null 时返回空列表', () {
    expect(
      JsonEnvelope.list('{"success":true,"data":null}', label: '记录'),
      isEmpty,
    );
  });

  test('部分元素不是对象时跳过，其余保留', () {
    final list = JsonEnvelope.list(
      '{"success":true,"data":[1,"x",null,{"A":1}]}',
      label: '记录',
    );
    expect(list, hasLength(1));
  });

  test('全部元素都不是对象时报协议异常，而不是伪装成空', () {
    expect(
      () => JsonEnvelope.list('{"success":true,"data":["a","b"]}', label: '记录'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          contains('数据格式异常'),
        ),
      ),
    );
  });

  test('data 不是数组时报协议异常', () {
    expect(
      () => JsonEnvelope.list('{"success":true,"data":{}}', label: '记录'),
      throwsA(isA<ApiException>()),
    );
  });

  test('空响应报协议异常', () {
    expect(
      () => JsonEnvelope.decode('', label: '记录'),
      throwsA(
        isA<ApiException>().having((e) => e.message, 'message', '服务器返回空响应'),
      ),
    );
  });

  test('非法 JSON 报协议异常', () {
    expect(
      () => JsonEnvelope.decode('{bad}', label: '记录'),
      throwsA(
        isA<ApiException>().having((e) => e.message, 'message', '记录响应格式异常'),
      ),
    );
  });
}
