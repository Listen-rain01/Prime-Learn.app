import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/features/auth/data/parsers/exam_context_parser.dart';

void main() {
  const parser = ExamContextParser();

  test('成功解析题库名称与题库 ID', () {
    final dto = parser.parse('|0|0008|user-id|2025陕西煤业题库|...|abc|x');
    expect(dto.bankName, '2025陕西煤业题库');
    expect(dto.examTypeId, 'abc');
  });

  test('题库字段为空时返回 null', () {
    final dto = parser.parse('|0|0008|user-id|||');
    expect(dto.bankName, isNull);
    expect(dto.examTypeId, isNull);
  });

  test('会话失效文案抛协议异常', () {
    expect(
      () => parser.parse('登录已过期'),
      throwsA(
        isA<ApiException>()
            .having((e) => e.kind, 'kind', ApiErrorKind.protocol)
            .having((e) => e.message, 'message', '登录已过期'),
      ),
    );
  });

  test('空响应抛协议异常', () {
    expect(() => parser.parse(''), throwsA(isA<ApiException>()));
  });
}
