import 'package:primelearn/core/errors/use_case_failure.dart';
import 'package:primelearn/features/reading/domain/entities/reading_catalog.dart';
import 'package:primelearn/features/reading/domain/repositories/reading_preset_repository.dart';

/// 保存阅读预设。
class SaveReadingPreset {
  /// 创建用例。
  SaveReadingPreset(this._repository);

  final ReadingPresetRepository _repository;

  /// 执行。
  Future<void> execute(ReadingPreset preset) async {
    if (preset.articleId.isEmpty) {
      throw const UseCaseFailure('请先选择要阅读的文章');
    }
    await _repository.save(preset);
  }
}
