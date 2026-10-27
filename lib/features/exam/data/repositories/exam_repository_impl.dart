import 'package:primelearn/features/exam/data/models/exam_paper_dto.dart';
import 'package:primelearn/features/exam/data/parsers/exam_paper_parser.dart';
import 'package:primelearn/features/exam/data/services/exam_api.dart';
import 'package:primelearn/features/exam/domain/entities/exam_paper.dart';
import 'package:primelearn/features/exam/domain/repositories/exam_repository.dart';

/// 考试仓储实现。
class ExamRepositoryImpl implements ExamRepository {
  /// 创建仓储实现。
  ExamRepositoryImpl(this._api);

  final ExamApi _api;
  static const ExamPaperParser _parser = ExamPaperParser();

  @override
  Future<List<ExamPaper>> fetchPapers({
    required String userId,
    required String bankId,
  }) async {
    final body = await _api.fetchPapers(userId, bankId);
    return _parser.parse(body).map(toExamPaper).toList(growable: false);
  }
}
