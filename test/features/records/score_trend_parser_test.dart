import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/features/records/data/parsers/score_trend_parser.dart';

void main() {
  const parser = ScoreTrendParser();

  test('解析 rows，并优先使用结束时间', () {
    final points = parser.parse('''
{
  "total": 2,
  "rows": [
    {"ExamName": "手机考试 A", "ExamType": "手机考试", "Mark": 100, "StartTime": "2026-10-27T01:26:44", "EndTime": "2026-10-27T01:26:45.293"},
    {"ExamName": "理论考试 B", "ExamType": "理论考试", "Mark": 88.5, "StartTime": "2026-10-20T09:00:00"}
  ]
}''');

    expect(points, hasLength(2));
    expect(points.first.examName, '手机考试 A');
    expect(points.first.mark, 100);
    expect(points.first.time, DateTime(2026, 10, 27, 1, 26, 45, 293));
    expect(points.last.time, DateTime(2026, 10, 20, 9));
  });

  test('rows 为空返回空列表', () {
    expect(parser.parse('{"total": 0, "rows": []}'), isEmpty);
  });

  test('缺少 rows 返回空列表', () {
    expect(parser.parse('{"total": 0}'), isEmpty);
  });

  test('非法 JSON 抛协议异常', () {
    expect(
      () => parser.parse('{bad}'),
      throwsA(
        isA<ApiException>().having((e) => e.message, 'message', '成绩趋势响应格式异常'),
      ),
    );
  });

  test('rows 不是数组时抛协议异常', () {
    expect(
      () => parser.parse('{"total": 0, "rows": {}}'),
      throwsA(
        isA<ApiException>().having((e) => e.message, 'message', '成绩趋势数据格式异常'),
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
}
