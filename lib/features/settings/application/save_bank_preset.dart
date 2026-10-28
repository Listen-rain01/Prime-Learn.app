import 'package:primelearn/core/errors/use_case_failure.dart';
import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/features/exam/domain/repositories/exam_repository.dart';
import 'package:primelearn/features/settings/domain/entities/bank_catalog.dart';
import 'package:primelearn/features/settings/domain/repositories/bank_preset_repository.dart';

/// 保存题库预设：先校验该题库有可考试卷，再落盘。
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
      // 只有一份试卷时把试卷信息一并存快照，便于卡片展示；多份时不猜默认。
      final singlePaper = papers.length == 1 ? papers.first : null;
      await _presetRepository.save(
        BankPreset(
          bankId: preset.bankId,
          bankName: preset.bankName,
          questionCount: preset.questionCount,
          paperCount: papers.length,
          singleCount: preset.singleCount,
          multipleCount: preset.multipleCount,
          judgeCount: preset.judgeCount,
          paperName: singlePaper?.name,
          paperTotalScore: singlePaper?.totalScore,
          paperPassingGrade: singlePaper?.passingGrade,
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
