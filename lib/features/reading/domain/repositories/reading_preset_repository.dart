import 'package:primelearn/features/reading/domain/entities/reading_catalog.dart';

/// 阅读预设的本地存储接口。
abstract interface class ReadingPresetRepository {
  /// 读取预设；未设置返回 null。
  ReadingPreset? read();

  /// 保存预设。
  Future<void> save(ReadingPreset preset);

  /// 清除预设。
  Future<void> clear();
}
