import 'package:primelearn/features/settings/domain/entities/bank_catalog.dart';

/// 题库预设本地存储接口。
abstract interface class BankPresetRepository {
  /// 读取预设；未设置返回 null。
  BankPreset? read();

  /// 保存预设。
  Future<void> save(BankPreset preset);

  /// 清除预设。
  Future<void> clear();
}
