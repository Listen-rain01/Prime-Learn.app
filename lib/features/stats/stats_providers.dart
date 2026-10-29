import 'package:primelearn/core/errors/no_retry.dart';
import 'package:primelearn/core/network/api_client.dart';
import 'package:primelearn/core/session/session_store.dart';
import 'package:primelearn/features/records/application/load_exam_records.dart';
import 'package:primelearn/features/records/application/load_points_ledger.dart';
import 'package:primelearn/features/records/application/load_ranking.dart';
import 'package:primelearn/features/records/application/load_score_trend.dart';
import 'package:primelearn/features/records/data/repositories/records_repository_impl.dart';
import 'package:primelearn/features/records/data/services/records_api.dart';
import 'package:primelearn/features/records/domain/entities/exam_record.dart';
import 'package:primelearn/features/records/domain/entities/point_entry.dart';
import 'package:primelearn/features/records/domain/entities/ranking_board.dart';
import 'package:primelearn/features/records/domain/entities/score_trend_point.dart';
import 'package:primelearn/features/records/domain/repositories/records_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'records_providers.g.dart';

/// 榜单查询参数（record 具备值相等，可直接作为 family 参数）。
typedef RankingQuery = ({
  RankingKind kind,
  RankingScope scope,
  String begin,
  String end,
});

/// 记录 API 实例。
@Riverpod(keepAlive: true)
RecordsApi recordsApi(Ref ref) => RecordsApi(ref.watch(apiClientProvider));

/// 记录仓储实例。
@Riverpod(keepAlive: true)
RecordsRepository recordsRepository(Ref ref) =>
    RecordsRepositoryImpl(ref.watch(recordsApiProvider));

/// 加载考试记录用例。
@Riverpod(keepAlive: true)
LoadExamRecords loadExamRecords(Ref ref) =>
    LoadExamRecords(ref.watch(recordsRepositoryProvider));

/// 加载积分明细用例。
@Riverpod(keepAlive: true)
LoadPointsLedger loadPointsLedger(Ref ref) =>
    LoadPointsLedger(ref.watch(recordsRepositoryProvider));

/// 加载榜单用例。
@Riverpod(keepAlive: true)
LoadRanking loadRanking(Ref ref) =>
    LoadRanking(ref.watch(recordsRepositoryProvider));

/// 加载成绩趋势用例。
@Riverpod(keepAlive: true)
LoadScoreTrend loadScoreTrend(Ref ref) =>
    LoadScoreTrend(ref.watch(recordsRepositoryProvider));

/// 指定分类的考试记录。
@Riverpod(retry: noProviderRetry)
Future<List<ExamRecord>> examRecords(
  Ref ref,
  ExamRecordCategory category,
) async {
  final session = ref.watch(sessionStoreProvider);
  if (session == null) return const [];
  return ref.watch(loadExamRecordsProvider).execute(session.userId, category);
}

/// 积分明细。
@Riverpod(retry: noProviderRetry)
Future<List<PointEntry>> pointsLedger(Ref ref) async {
  final session = ref.watch(sessionStoreProvider);
  if (session == null) return const [];
  return ref.watch(loadPointsLedgerProvider).execute(session.userId);
}

/// 榜单。
@Riverpod(retry: noProviderRetry)
Future<RankingBoard> ranking(Ref ref, RankingQuery query) async {
  final session = ref.watch(sessionStoreProvider);
  if (session == null) return const RankingBoard();
  return ref
      .watch(loadRankingProvider)
      .execute(
        userId: session.userId,
        kind: query.kind,
        scope: query.scope,
        begin: query.begin,
        end: query.end,
      );
}

/// 个人成绩趋势。
@Riverpod(retry: noProviderRetry)
Future<List<ScoreTrendPoint>> scoreTrend(Ref ref) async {
  final session = ref.watch(sessionStoreProvider);
  if (session == null) return const [];
  return ref.watch(loadScoreTrendProvider).execute(session.userId);
}
