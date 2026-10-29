import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:primelearn/core/errors/use_case_failure.dart';
import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/features/stats/application/load_ranking.dart';
import 'package:primelearn/features/stats/application/load_score_trend.dart';
import 'package:primelearn/features/stats/domain/entities/ranking_board.dart';
import 'package:primelearn/features/stats/domain/entities/score_trend_point.dart';
import 'package:primelearn/features/stats/domain/repositories/stats_repository.dart';

class _MockStatsRepository extends Mock implements StatsRepository {}

void main() {
  late _MockStatsRepository repository;

  setUpAll(() => registerFallbackValue(RankingScope.unit));

  setUp(() {
    repository = _MockStatsRepository();
  });

  test('成绩榜调用 fetchMarkRanking 并透传参数', () async {
    when(
      () => repository.fetchMarkRanking(
        userId: any(named: 'userId'),
        scope: any(named: 'scope'),
        begin: any(named: 'begin'),
        end: any(named: 'end'),
      ),
    ).thenAnswer(
      (_) async => const RankingBoard(myName: '张小赞', myRank: 12, myMark: 96.5),
    );

    final board = await LoadRanking(repository).execute(
      userId: 'u1',
      kind: RankingKind.mark,
      scope: RankingScope.unit,
      begin: '2026-10-01',
      end: '2026-10-31',
    );

    expect(board.myRank, 12);
    verify(
      () => repository.fetchMarkRanking(
        userId: 'u1',
        scope: RankingScope.unit,
        begin: '2026-10-01',
        end: '2026-10-31',
      ),
    ).called(1);
    verifyNever(
      () => repository.fetchStudyTimeRanking(
        userId: any(named: 'userId'),
        scope: any(named: 'scope'),
        begin: any(named: 'begin'),
        end: any(named: 'end'),
      ),
    );
  });

  test('学习时长榜调用 fetchStudyTimeRanking', () async {
    when(
      () => repository.fetchStudyTimeRanking(
        userId: any(named: 'userId'),
        scope: any(named: 'scope'),
        begin: any(named: 'begin'),
        end: any(named: 'end'),
      ),
    ).thenAnswer((_) async => const RankingBoard());

    final board = await LoadRanking(repository).execute(
      userId: 'u1',
      kind: RankingKind.studyTime,
      scope: RankingScope.group,
      begin: '2026-10-01',
      end: '2026-10-31',
    );

    expect(board.isEmpty, isTrue);
    verify(
      () => repository.fetchStudyTimeRanking(
        userId: 'u1',
        scope: RankingScope.group,
        begin: '2026-10-01',
        end: '2026-10-31',
      ),
    ).called(1);
  });

  test('积分榜调用 fetchIntegralRanking 并透传参数', () async {
    when(
      () => repository.fetchIntegralRanking(
        userId: any(named: 'userId'),
        scope: any(named: 'scope'),
        begin: any(named: 'begin'),
        end: any(named: 'end'),
      ),
    ).thenAnswer(
      (_) async => const RankingBoard(myName: '聂伟', myRank: 54, myMark: 1055),
    );

    final board = await LoadRanking(repository).execute(
      userId: 'u1',
      kind: RankingKind.integral,
      scope: RankingScope.unit,
      begin: '2026-10-01',
      end: '2026-10-31',
    );

    expect(board.myRank, 54);
    expect(board.myMark, 1055);
    verify(
      () => repository.fetchIntegralRanking(
        userId: 'u1',
        scope: RankingScope.unit,
        begin: '2026-10-01',
        end: '2026-10-31',
      ),
    ).called(1);
    verifyNever(
      () => repository.fetchMarkRanking(
        userId: any(named: 'userId'),
        scope: any(named: 'scope'),
        begin: any(named: 'begin'),
        end: any(named: 'end'),
      ),
    );
  });

  test('会话失效映射为 sessionExpired', () async {
    when(
      () => repository.fetchMarkRanking(
        userId: any(named: 'userId'),
        scope: any(named: 'scope'),
        begin: any(named: 'begin'),
        end: any(named: 'end'),
      ),
    ).thenThrow(
      const ApiException(kind: ApiErrorKind.sessionExpired, message: '会话已失效'),
    );

    await expectLater(
      LoadRanking(repository).execute(
        userId: 'u1',
        kind: RankingKind.mark,
        scope: RankingScope.unit,
        begin: '2026-10-01',
        end: '2026-10-31',
      ),
      throwsA(
        isA<UseCaseFailure>()
            .having((e) => e.sessionExpired, 'sessionExpired', isTrue)
            .having((e) => e.message, 'message', '会话已失效'),
      ),
    );
  });

  test('成绩趋势返回列表', () async {
    when(() => repository.fetchScoreTrend(any())).thenAnswer(
      (_) async => const [
        ScoreTrendPoint(examName: '手机考试', examType: '手机考试', mark: 100),
      ],
    );

    final points = await LoadScoreTrend(repository).execute('u1');

    expect(points.single.examName, '手机考试');
  });

  test('成绩趋势其他异常映射为通用失败', () async {
    when(() => repository.fetchScoreTrend(any())).thenThrow('boom');

    await expectLater(
      LoadScoreTrend(repository).execute('u1'),
      throwsA(
        isA<UseCaseFailure>().having(
          (e) => e.message,
          'message',
          '加载成绩趋势失败，请稍后重试',
        ),
      ),
    );
  });
}
