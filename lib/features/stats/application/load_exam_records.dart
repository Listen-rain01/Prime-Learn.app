import 'package:primelearn/core/errors/use_case_failure.dart';
import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/features/stats/domain/entities/exam_record.dart';
import 'package:primelearn/features/stats/domain/repositories/stats_repository.dart';

/// 加载考试记录：按开始时间倒序。
class LoadExamRecords {
  /// 创建用例。
  LoadExamRecords(this._repository);

  final StatsRepository _repository;

  /// 查询指定分类的考试记录。
  Future<List<ExamRecord>> execute(
    String userId,
    ExamRecordCategory category,
  ) async {
    try {
      final records = await _repository.fetchExamRecords(userId, category);
      return [...records]..sort((a, b) => _time(b).compareTo(_time(a)));
    } on ApiException catch (error) {
      throw UseCaseFailure.fromApi(error);
    } on Object {
      throw const UseCaseFailure('加载考试记录失败，请稍后重试');
    }
  }

  DateTime _time(ExamRecord record) =>
      record.startTime ?? DateTime.fromMillisecondsSinceEpoch(0);
}
