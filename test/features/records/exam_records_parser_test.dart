import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/features/records/data/models/exam_record_dto.dart';

void main() {
  const parser = ExamRecordsParser();

  test('解析考试记录', () {
    const body = '''
{
  "success": true,
  "data": [
    {
      "ExamDetailId": "31bfb3d5-8309-4d67-9723-7a5e1e415710",
      "PersonId": "ec5dab3e-...",
      "State": "已交卷",
      "ShowState": "已交卷",
      "StartTime": "2026-10-08T15:08:09.48",
      "EndTime": "2026-10-08T15:12:21.5",
      "PaperId": "529e111b-...",
      "ExamName": "2025陕西煤业题库",
      "ExamType": "手机考试",
      "Mark": 100,
      "WhetherQualified": true
    }
  ]
}''';

    final record = parser.parse(body).single;
    expect(record.examName, '2025陕西煤业题库');
    expect(record.examType, '手机考试');
    expect(record.mark, 100);
    expect(record.qualified, isTrue);
    expect(record.state, '已交卷');
    expect(record.startTime, DateTime(2026, 10, 8, 15, 8, 9, 480));
  });

  test('Mark 为小数/字符串时也能解析', () {
    const body = '''
{"success":true,"data":[{"ExamName":"A","Mark":"96.5","WhetherQualified":"true","ExamType":"手机模拟"}]}''';
    final record = parser.parse(body).single;
    expect(record.mark, 96.5);
    expect(record.qualified, isTrue);
    expect(record.startTime, isNull);
  });

  test('字段缺失时回退默认值', () {
    const body = '{"success":true,"data":[{}]}';
    final record = parser.parse(body).single;
    expect(record.examName, '');
    expect(record.mark, 0);
    expect(record.qualified, isFalse);
    expect(record.state, '');
  });

  test('success=false 抛平台文案', () {
    expect(
      () => parser.parse('{"success":false,"message":"登录已失效"}'),
      throwsA(isA<ApiException>().having((e) => e.message, 'message', '登录已失效')),
    );
  });

  test('空响应与非法 JSON 抛协议异常', () {
    expect(() => parser.parse(''), throwsA(isA<ApiException>()));
    expect(
      () => parser.parse('<html>login</html>'),
      throwsA(
        isA<ApiException>().having((e) => e.message, 'message', '我的考试记录响应格式异常'),
      ),
    );
  });

  test('data 缺失返回空列表', () {
    expect(parser.parse('{"success":true}'), isEmpty);
  });
}
