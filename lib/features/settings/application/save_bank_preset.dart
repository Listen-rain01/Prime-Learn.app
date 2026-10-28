import 'package:primelearn/core/errors/use_case_failure.dart';
import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/features/exam/domain/entities/exam_paper.dart';
import 'package:primelearn/features/exam/domain/repositories/exam_repository.dart';
import 'package:primelearn/features/settings/domain/entities/bank_catalog.dart';
import 'package:primelearn/features/settings/domain/repositories/bank_preset_repository.dart';

/// 保存题库预设：先校验该题库有可考试卷且所选试卷存在，再落盘。
class SaveBankPreset {
  /// 创建用例。
  SaveBankPreset(this._examRepository, this._presetRepository);

  final ExamRepository _examRepository;
  final BankPresetRepository _presetRepository;

  /// 执行。
  Future<void> execute({
    required String userId,
    required BankPreset preset,
  }) async {
    try {
      final papers = await _examRepository.fetchPapers(
        userId: userId,
        bankId: preset.bankId,
      );
      if (papers.isEmpty) {
        throw const UseCaseFailure('该题库没有可开考试卷，无法用于考试');
      }
      // 试卷必须由用户明确选择；用 ID 反查确保它属于该题库。
      ExamPaper? selected;
      for (final paper in papers) {
        if (paper.id == preset.paperId) selected = paper;
      }
      if (selected == null) {
        throw const UseCaseFailure('所选试卷不存在，请重新选择');
      }
      await _presetRepository.save(
        BankPreset(
          bankId: preset.bankId,
          bankName: preset.bankName,
          questionCount: preset.questionCount,
          paperCount: papers.length,
          singleCount: preset.singleCount,
          multipleCount: preset.multipleCount,
          judgeCount: preset.judgeCount,
          paperId: selected.id,
          paperName: selected.name,
          paperTotalScore: selected.totalScore,
          paperPassingGrade: selected.passingGrade,
        ),
      );
    } on UseCaseFailure {
      rethrow;
    } on ApiException catch (error) {
      throw UseCaseFailure.fromApi(error);
    } on Object {
      throw const UseCaseFailure('保存预设失败，请稍后重试');
    }
  }
}
