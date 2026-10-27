import 'package:primelearn/features/records/domain/entities/exam_record.dart';
import 'package:primelearn/features/records/domain/entities/point_entry.dart';
import 'package:primelearn/features/records/domain/entities/ranking_board.dart';
import 'package:primelearn/features/records/domain/entities/score_trend_point.dart';

/// 记录（考试记录 + 积分明细 + 排名/趋势）数据接口。
abstract interface class RecordsRepository {
  /// 查询考试记录；[category] 决定 `type` 过滤。
  Future<List<ExamRecord>> fetchExamRecords(
    String userId,
    ExamRecordCategory category,
  );

  /// 查询积分明细。
  Future<List<PointEntry>> fetchPointsLedger(String userId);

  /// 查询成绩排名。
  Future<RankingBoard> fetchMarkRanking({
    required String userId,
    required RankingScope scope,
    required String begin,
    required String end,
  });

  /// 查询学习时长排名。
  Future<RankingBoard> fetchStudyTimeRanking({
    required String userId,
    required RankingScope scope,
    required String begin,
    required String end,
  });

  /// 查询个人成绩趋势。
  Future<List<ScoreTrendPoint>> fetchScoreTrend(String userId);
}
