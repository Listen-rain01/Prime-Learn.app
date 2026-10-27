import 'package:primelearn/core/errors/use_case_failure.dart';
import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/features/records/domain/entities/ranking_board.dart';
import 'package:primelearn/features/records/domain/repositories/records_repository.dart';

/// 加载榜单（成绩榜 / 学习时长榜）。
class LoadRanking {
  /// 创建用例。
  LoadRanking(this._repository);

  final RecordsRepository _repository;

  /// 执行。
  Future<RankingBoard> execute({
    required String userId,
    required RankingKind kind,
    required RankingScope scope,
    required String begin,
    required String end,
  }) async {
    try {
      return switch (kind) {
        RankingKind.mark => await _repository.fetchMarkRanking(
          userId: userId,
          scope: scope,
          begin: begin,
          end: end,
        ),
        RankingKind.studyTime => await _repository.fetchStudyTimeRanking(
          userId: userId,
          scope: scope,
          begin: begin,
          end: end,
        ),
      };
    } on ApiException catch (error) {
      throw UseCaseFailure.fromApi(error);
    } on Object {
      throw const UseCaseFailure('加载排名失败，请稍后重试');
    }
  }
}
