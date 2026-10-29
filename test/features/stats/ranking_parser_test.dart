import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/features/stats/data/parsers/ranking_parser.dart';

void main() {
  const parser = RankingParser();

  test('解析 message 中的我的排名与榜单条目', () {
    final board = parser.parse('''
{
  "success": true,
  "message": "张小赞|12|96.5",
  "data": [
    {"Cur": 1, "PersonName": "田小平", "DepartmentFullName": "运输区", "Mark": 99.5, "Ranking": 1, "AllCount": 100},
    {"Cur": 2, "PersonName": "张小赞", "DepartmentFullName": "设备维修队", "Mark": 96.5, "Ranking": 2, "AllCount": 100}
  ]
}''');

    expect(board.myName, '张小赞');
    expect(board.myRank, 12);
    expect(board.myMark, 96.5);
    expect(board.entries, hasLength(2));
    expect(board.entries.first.personName, '田小平');
    expect(board.entries.first.department, '运输区');
    expect(board.entries.first.mark, 99.5);
    expect(board.entries.first.allCount, 100);
    expect(board.entries.first.rank, 1);
  });

  test('学习时长榜：Mark 为空、时长在 AllCount', () {
    final board = parser.parse(
      '''
{"success": true, "message": "张小赞|489|1793|0|1952",
 "data": [{"PersonName": "李四", "Ranking": 1, "Mark": null, "AllCount": 154710}]}''',
    );

    expect(board.myMark, 1793);
    expect(board.entries.single.mark, 0);
    expect(board.entries.single.allCount, 154710);
  });

  test('积分榜：Mark 恒为 null、积分在 AllCount，message 为「姓名|排名|积分」', () {
    // 样本来自真实环境（docs/api/samples/accumulate-ranking/response.json）。
    final board = parser.parse('''
{
  "success": true,
  "message": "聂伟|54|1055",
  "data": [
    {"Cur": 1, "PersonName": "曹朋涛", "DepartmentFullName": "澄合矿业/西卓煤矿/机电队", "Mark": null, "AllCount": 1295, "Ranking": 1},
    {"Cur": 2, "PersonName": "王照平", "DepartmentFullName": "澄合矿业/西卓煤矿/准备队", "Mark": null, "AllCount": 1295, "Ranking": 2}
  ]
}''');

    expect(board.myName, '聂伟');
    expect(board.myRank, 54);
    expect(board.myMark, 1055);
    expect(board.entries, hasLength(2));
    expect(board.entries.first.personName, '曹朋涛');
    expect(board.entries.first.department, '澄合矿业/西卓煤矿/机电队');
    expect(board.entries.first.mark, 0, reason: 'Mark 为 null 时应解析为 0');
    expect(board.entries.first.allCount, 1295, reason: '积分在 AllCount');
    expect(board.entries.first.rank, 1);
  });

  test('缺少 message 时我的排名为 null', () {
    final board = parser.parse('{"success": true, "data": []}');
    expect(board.myRank, isNull);
    expect(board.myMark, isNull);
    expect(board.entries, isEmpty);
  });

  test('message 格式不符时不影响榜单解析', () {
    final board = parser.parse(
      '''
{"success": true, "message": "只有姓名", "data": [{"PersonName": "李四", "Mark": 80, "Ranking": 3}]}''',
    );
    expect(board.myRank, isNull);
    expect(board.entries.single.personName, '李四');
    expect(board.entries.single.mark, 80);
  });

  test('success=false 时抛接口异常并带服务端文案', () {
    expect(
      () => parser.parse('{"success": false, "message": "会话已过期", "data": []}'),
      throwsA(isA<ApiException>().having((e) => e.message, 'message', '会话已过期')),
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
