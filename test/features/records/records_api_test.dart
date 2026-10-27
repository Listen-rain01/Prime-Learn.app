import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/features/records/data/services/records_api.dart';
import 'package:primelearn/features/records/domain/entities/ranking_board.dart';

void main() {
  test('成绩排名路径：pid 明文、带范围与日期', () {
    final path = RecordsApi.markRankingPath(
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

  test('集团榜 type=0', () {
    final path = RecordsApi.markRankingPath(
      'u1',
      scope: RankingScope.group,
      begin: '2026-10-01',
      end: '2026-10-31',
    );
    expect(path, contains('type=0'));
  });

  test('学习时长排名表单：pid 做 Esdt 且不二次转义', () {
    final form = RecordsApi.studyTimeRankingForm(
      '123',
      scope: RankingScope.unit,
      begin: '2026-10-01',
      end: '2026-10-31',
    );
    expect(form['pid'], '495051%5E2%2C2%2C2');
    expect(form['pid'], isNot(contains('%25')));
    expect(form['type'], '1');
    expect(form['begin'], '2026-10-01');
    expect(form['end'], '2026-10-31');
    expect(form['page'], '1');
    expect(form['rows'], '20');
  });

  test('成绩趋势路径：pid 明文、类型做 URL 编码', () {
    final path = RecordsApi.scoreTrendPath('u1');
    expect(path, contains('pid=u1'));
    expect(path, contains('type=%E7%90%86%E8%AE%BA%E8%80%83%E8%AF%95'));
    expect(path, isNot(contains('理论考试')));
  });
}
