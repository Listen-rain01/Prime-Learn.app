import 'package:primelearn/features/stats/data/models/exam_record_dto.dart';
import 'package:primelearn/features/stats/data/models/point_entry_dto.dart';
import 'package:primelearn/features/stats/data/models/ranking_dto.dart';
import 'package:primelearn/features/stats/data/models/score_trend_dto.dart';
import 'package:primelearn/features/stats/data/parsers/ranking_parser.dart';
import 'package:primelearn/features/stats/data/parsers/score_trend_parser.dart';
import 'package:primelearn/features/stats/data/services/stats_api.dart';
import 'package:primelearn/features/stats/domain/entities/exam_record.dart';
import 'package:primelearn/features/stats/domain/entities/point_entry.dart';
import 'package:primelearn/features/stats/domain/entities/ranking_board.dart';
import 'package:primelearn/features/stats/domain/entities/score_trend_point.dart';
import 'package:primelearn/features/stats/domain/repositories/stats_repository.dart';

/// 记录仓储实现：DTO → Entity。
class StatsRepositoryImpl implements StatsRepository {
  /// 创建仓储实现。
  StatsRepositoryImpl(this._api);

  final StatsApi _api;
  static const ExamRecordsParser _examParser = ExamRecordsParser();
  static const PointsLedgerParser _pointParser = PointsLedgerParser();
  static const RankingParser _rankingParser = RankingParser();
  static const ScoreTrendParser _trendParser = ScoreTrendParser();

  @override
  Future<List<ExamRecord>> fetchExamRecords(
    String userId,
    ExamRecordCategory category,
  ) async {
    final body = await _api.fetchExamRecords(userId, category);
    return _examParser.parse(body).map(_toExamRecord).toList(growable: false);
  }

  @override
  Future<List<PointEntry>> fetchPointsLedger(String userId) async {
    final body = await _api.fetchPointsLedger(userId);
    return _pointParser.parse(body).map(_toPointEntry).toList(growable: false);
  }

  @override
  Future<RankingBoard> fetchMarkRanking({
    required String userId,
    required RankingScope scope,
    required String begin,
    required String end,
  }) async {
    final body = await _api.fetchMarkRanking(
      userId,
      scope: scope,
      begin: begin,
      end: end,
    );
    return _toBoard(_rankingParser.parse(body));
  }

  @override
  Future<RankingBoard> fetchStudyTimeRanking({
    required String userId,
    required RankingScope scope,
    required String begin,
    required String end,
  }) async {
    final body = await _api.fetchStudyTimeRanking(
      userId,
      scope: scope,
      begin: begin,
      end: end,
    );
    return _toBoard(_rankingParser.parse(body));
  }

  @override
  Future<RankingBoard> fetchIntegralRanking({
    required String userId,
    required RankingScope scope,
    required String begin,
    required String end,
  }) async {
    final body = await _api.fetchIntegralRanking(
      userId,
      scope: scope,
      begin: begin,
      end: end,
    );
    return _toBoard(_rankingParser.parse(body));
  }

  @override
  Future<List<ScoreTrendPoint>> fetchScoreTrend(String userId) async {
    final body = await _api.fetchScoreTrend(userId);
    return _trendParser.parse(body).map(_toTrendPoint).toList(growable: false);
  }

  ExamRecord _toExamRecord(ExamRecordDto dto) => ExamRecord(
    examName: dto.examName,
    examType: dto.examType,
    mark: dto.mark,
    qualified: dto.qualified,
    state: dto.state,
    startTime: dto.startTime,
    endTime: dto.endTime,
  );

  PointEntry _toPointEntry(PointEntryDto dto) => PointEntry(
    name: dto.name,
    amount: dto.amount,
    date: dto.date,
    reduceName: dto.reduceName,
  );

  RankingBoard _toBoard(RankingBoardDto dto) => RankingBoard(
    myName: dto.myName,
    myRank: dto.myRank,
    myMark: dto.myMark,
    entries: dto.entries
        .map(
          (entry) => RankingEntry(
            rank: entry.rank,
            personName: entry.personName,
            department: entry.department,
            mark: entry.mark,
            allCount: entry.allCount,
          ),
        )
        .toList(growable: false),
  );

  ScoreTrendPoint _toTrendPoint(ScoreTrendDto dto) => ScoreTrendPoint(
    examName: dto.examName,
    examType: dto.examType,
    mark: dto.mark,
    time: dto.time,
  );
}
