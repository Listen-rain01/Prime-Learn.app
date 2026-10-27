import 'package:primelearn/features/records/domain/entities/exam_record.dart';
import 'package:primelearn/features/records/domain/entities/point_entry.dart';

/// 记录（考试记录 + 积分明细）数据接口。
abstract interface class RecordsRepository {
  /// 查询考试记录；[category] 决定 `type` 过滤。
  Future<List<ExamRecord>> fetchExamRecords(
    String userId,
    ExamRecordCategory category,
  );

  /// 查询积分明细。
  Future<List<PointEntry>> fetchPointsLedger(String userId);
}
