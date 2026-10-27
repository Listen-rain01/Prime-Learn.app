import 'package:primelearn/features/records/data/models/exam_record_dto.dart';
import 'package:primelearn/features/records/data/models/point_entry_dto.dart';
import 'package:primelearn/features/records/data/services/records_api.dart';
import 'package:primelearn/features/records/domain/entities/exam_record.dart';
import 'package:primelearn/features/records/domain/entities/point_entry.dart';
import 'package:primelearn/features/records/domain/repositories/records_repository.dart';

/// 记录仓储实现：DTO → Entity。
class RecordsRepositoryImpl implements RecordsRepository {
  /// 创建仓储实现。
  RecordsRepositoryImpl(this._api);

  final RecordsApi _api;
  static const ExamRecordsParser _examParser = ExamRecordsParser();
  static const PointsLedgerParser _pointParser = PointsLedgerParser();

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
}
