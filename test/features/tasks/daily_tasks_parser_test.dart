import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/features/tasks/data/parsers/daily_tasks_parser.dart';

void main() {
  const parser = DailyTasksParser();

  test('解析成功响应', () {
    const body = '''
{
  "success": true,
  "data": [
    {
      "AccumulateName": "签到",
      "AccumulateRule": "每日签到1分，连续登录每日多1分，每日最多3分",
      "Accumulate": 1,
      "MaxAccumulate": 3,
      "CurAccumulate": 2,
      "CurAccumulateState": "已签到",
      "Criterion": "CheckIn",
      "Sort": 1
    }
  ]
}''';

    final tasks = parser.parse(body);
    expect(tasks, hasLength(1));
    expect(tasks.single.name, '签到');
    expect(tasks.single.criterion, 'CheckIn');
    expect(tasks.single.score, 1);
    expect(tasks.single.maxScore, 3);
    expect(tasks.single.currentScore, 2);
    expect(tasks.single.progressText, '已签到');
    expect(tasks.single.sort, 1);
  });

  test('数字为字符串时也能解析', () {
    const body = '''
{"success":true,"data":[{"AccumulateName":"手机考试","MaxAccumulate":"16","CurAccumulate":"8","Accumulate":"8","Criterion":"MobileExam","Sort":"4"}]}''';

    final task = parser.parse(body).single;
    expect(task.maxScore, 16);
    expect(task.currentScore, 8);
    expect(task.score, 8);
    expect(task.sort, 4);
  });

  test('success=false 抛出平台文案', () {
    const body = '{"success":false,"message":"登录已失效"}';
    expect(
      () => parser.parse(body),
      throwsA(
        isA<ApiException>()
            .having((e) => e.kind, 'kind', ApiErrorKind.protocol)
            .having((e) => e.message, 'message', '登录已失效'),
      ),
    );
  });

  test('data 为空数组返回空列表', () {
    expect(parser.parse('{"success":true,"data":[]}'), isEmpty);
  });

  test('data 缺失返回空列表', () {
    expect(parser.parse('{"success":true}'), isEmpty);
  });

  test('空响应抛协议异常', () {
    expect(
      () => parser.parse(''),
      throwsA(
        isA<ApiException>().having((e) => e.message, 'message', '服务器返回空响应'),
      ),
    );
  });

  test('非法 JSON 抛协议异常', () {
    expect(
      () => parser.parse('<html>error</html>'),
      throwsA(
        isA<ApiException>().having((e) => e.message, 'message', '今日任务响应格式异常'),
      ),
    );
  });

  test('忽略非对象元素', () {
    const body =
        '{"success":true,"data":[1,"x",null,{"Criterion":"CheckIn","AccumulateName":"签到"}]}';
    expect(parser.parse(body), hasLength(1));
  });
}
