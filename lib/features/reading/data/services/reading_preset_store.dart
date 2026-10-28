import 'package:primelearn/features/reading/domain/entities/reading_catalog.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 阅读预设的本地存储。
class ReadingPresetStore {
  /// 创建存储。
  ReadingPresetStore(this._prefs);

  static const String _idKey = 'reading_preset_article_id';
  static const String _titleKey = 'reading_preset_title';
  static const String _typeIdKey = 'reading_preset_type_id';
  static const String _typeNameKey = 'reading_preset_type_name';

  final SharedPreferences _prefs;

  /// 读取预设；未设置返回 null。
  ReadingPreset? read() {
    final id = _prefs.getString(_idKey);
    if (id == null || id.isEmpty) return null;
    return ReadingPreset(
      articleId: id,
      title: _prefs.getString(_titleKey) ?? '',
      typeId: _prefs.getString(_typeIdKey) ?? '',
      typeName: _prefs.getString(_typeNameKey) ?? '',
    );
  }

  /// 保存预设。
  Future<void> save(ReadingPreset preset) async {
    await _prefs.setString(_idKey, preset.articleId);
    await _prefs.setString(_titleKey, preset.title);
    await _prefs.setString(_typeIdKey, preset.typeId);
    await _prefs.setString(_typeNameKey, preset.typeName);
  }

  /// 清除预设。
  Future<void> clear() async {
    for (final key in [_idKey, _titleKey, _typeIdKey, _typeNameKey]) {
      await _prefs.remove(key);
    }
  }
}
