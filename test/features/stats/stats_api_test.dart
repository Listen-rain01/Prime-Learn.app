import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/features/stats/data/services/stats_api.dart';
import 'package:primelearn/features/stats/domain/entities/ranking_board.dart';

void main() {
  test('成绩排名路径：pid 明文、带范围与日期', () {
    final path = StatsApi.markRankingPath(
      'u1',
      scope: RankingScope.unit,
      begin: '2026-10-01',
      end: '2026-10-31',
    );
    expect(path, contains('/ExamManger/P_ExamDetail/GetMarkRankingList?'));
    expect(path, contains('pid=u1'));
    expect(path, contains('type=1'));
    expect(path, contains('id=0'));
    expect(path, contains('begin=2026-10-01'));
    expect(path, contains('end=2026-10-31'));
  });

  test('集团榜 type=0、id=1', () {
    final path = StatsApi.markRankingPath(
      'u1',
      scope: RankingScope.group,
      begin: '2026-10-01',
      end: '2026-10-31',
    );
    expect(path, contains('type=0'));
    expect(path, contains('id=1'));
  });

  test('学习时长排名表单：pid 做 Esdt 且不二次转义', () {
    final form = StatsApi.studyTimeRankingForm(
      '123',
      scope: RankingScope.unit,
      begin: '2026-10-01',
      end: '2026-10-31',
    );
    expect(form['pid'], '495051%5E2%2C2%2C2');
    expect(form['pid'], isNot(contains('%25')));
    expect(form['type'], '1');
    expect(form['id'], '0');
    expect(form['begin'], '2026-10-01');
    expect(form['end'], '2026-10-31');
    expect(form['page'], '1');
    expect(form['rows'], '20');
  });

  test('学习时长集团榜 id=1', () {
    final form = StatsApi.studyTimeRankingForm(
      'u1',
      scope: RankingScope.group,
      begin: '2026-10-01',
      end: '2026-10-31',
    );
    expect(form['type'], '0');
    expect(form['id'], '1');
  });

  test('积分榜表单：pid/begin/end 做 Esdt，type 明文且无 id 字段', () {
    final form = StatsApi.integralRankingForm(
      '123',
      scope: RankingScope.unit,
      begin: '2026-10-01',
      end: '2026-10-31',
    );
    expect(form['pid'], '495051%5E2%2C2%2C2');
    expect(form['pid'], isNot(contains('%25')));
    expect(form['type'], '1', reason: '单位榜 type=1');
    expect(form['page'], '1');
    expect(form['rows'], '20');
    expect(form.containsKey('id'), isFalse, reason: '积分榜无 id 参数');
    // begin/end 必须 Esdt 编码：含 `%5E`(`^`) 与 `%2C`(`,`) 是 Esdt 标志，
    // 且不再含原文日期。
    expect(form['begin'], isNot('2026-10-01'));
    expect(form['begin'], contains('%5E'));
    expect(form['begin'], contains('%2C'));
    expect(form['begin'], isNot(contains('2026-10-01')));
    expect(form['end'], isNot(contains('2026-10-31')));
  });

  test('积分榜集团榜 type=0', () {
    final form = StatsApi.integralRankingForm(
      'u1',
      scope: RankingScope.group,
      begin: '2026-10-01',
      end: '2026-10-31',
    );
    expect(form['type'], '0');
  });

  test('成绩趋势路径：pid 明文、类型做 URL 编码', () {
    final path = StatsApi.scoreTrendPath('u1');
    expect(path, contains('pid=u1'));
    expect(path, contains('type=%E7%90%86%E8%AE%BA%E8%80%83%E8%AF%95'));
    expect(path, isNot(contains('理论考试')));
  });
}
