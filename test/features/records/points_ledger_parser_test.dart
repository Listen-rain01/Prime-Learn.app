import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/features/records/data/models/point_entry_dto.dart';

void main() {
  const parser = PointsLedgerParser();

  test('解析积分明细', () {
    const body = '''
{
  "success": true,
  "data": [
    {
      "PersonAccumulateId": null,
      "PersonId": "ec5dab3e-...",
      "Accumulate": 2,
      "ExamDetailId": "",
      "AccumulateName": "签到",
      "AccumulateDate": "2026-10-27T01:45:24.977",
      "CreateDate": null,
      "ReduceName": "",
      "ReduceType": 0
    }
  ]
}''';

    final entry = parser.parse(body).single;
    expect(entry.name, '签到');
    expect(entry.amount, 2);
    expect(entry.date, DateTime(2026, 10, 27, 1, 45, 24, 977));
    expect(entry.reduceName, isNull);
  });

  test('支持负分与字符串数字', () {
    const body =
        '{"success":true,"data":[{"AccumulateName":"扣减","Accumulate":"-3"}]}';
    final entry = parser.parse(body).single;
    expect(entry.amount, -3);
    expect(entry.date, isNull);
  });

  test('success=false 抛平台文案', () {
    expect(
      () => parser.parse('{"success":false,"message":"查询失败"}'),
      throwsA(isA<ApiException>().having((e) => e.message, 'message', '查询失败')),
    );
  });

  test('空响应抛协议异常', () {
    expect(() => parser.parse(''), throwsA(isA<ApiException>()));
  });
}
