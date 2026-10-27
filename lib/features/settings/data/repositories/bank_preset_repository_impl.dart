import 'package:primelearn/features/settings/data/services/bank_preset_store.dart';
import 'package:primelearn/features/settings/domain/entities/bank_catalog.dart';
import 'package:primelearn/features/settings/domain/repositories/bank_preset_repository.dart';

/// 题库预设仓储实现（基于 shared_preferences）。
class BankPresetRepositoryImpl implements BankPresetRepository {
  /// 创建仓储实现。
  BankPresetRepositoryImpl(this._store);

  final BankPresetStore _store;

  @override
  BankPreset? read() => _store.read();

  @override
  Future<void> save(BankPreset preset) => _store.save(preset);

  @override
  Future<void> clear() => _store.clear();
}
