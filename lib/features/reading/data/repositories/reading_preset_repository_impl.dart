import 'package:primelearn/features/reading/data/services/reading_preset_store.dart';
import 'package:primelearn/features/reading/domain/entities/reading_catalog.dart';
import 'package:primelearn/features/reading/domain/repositories/reading_preset_repository.dart';

/// 阅读预设仓库实现（直接代理本地存储）。
class ReadingPresetRepositoryImpl implements ReadingPresetRepository {
  /// 创建仓库。
  ReadingPresetRepositoryImpl(this._store);

  final ReadingPresetStore _store;

  @override
  ReadingPreset? read() => _store.read();

  @override
  Future<void> save(ReadingPreset preset) => _store.save(preset);

  @override
  Future<void> clear() => _store.clear();
}
