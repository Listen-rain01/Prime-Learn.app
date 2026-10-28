import 'package:primelearn/features/settings/domain/entities/bank_catalog.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 题库预设的本地存储（非敏感偏好，用 shared_preferences）。
class BankPresetStore {
  /// 创建存储。
  BankPresetStore(this._prefs);

  static const String _idKey = 'bank_preset_id';
  static const String _nameKey = 'bank_preset_name';
  static const String _questionKey = 'bank_preset_question_count';
  static const String _paperKey = 'bank_preset_paper_count';

  final SharedPreferences _prefs;

  /// 读取预设；未设置时返回 null。旧数据没有题数/试卷数时对应字段为 null。
  BankPreset? read() {
    final id = _prefs.getString(_idKey);
    final name = _prefs.getString(_nameKey);
    if (id == null || id.isEmpty) return null;
    return BankPreset(
      bankId: id,
      bankName: name ?? '',
      questionCount: _prefs.getInt(_questionKey),
      paperCount: _prefs.getInt(_paperKey),
    );
  }

  /// 保存预设（包含题数/试卷数快照）。
  Future<void> save(BankPreset preset) async {
    await _prefs.setString(_idKey, preset.bankId);
    await _prefs.setString(_nameKey, preset.bankName);
    await _writeOptionalInt(_questionKey, preset.questionCount);
    await _writeOptionalInt(_paperKey, preset.paperCount);
  }

  /// 清除预设。
  Future<void> clear() async {
    await _prefs.remove(_idKey);
    await _prefs.remove(_nameKey);
    await _prefs.remove(_questionKey);
    await _prefs.remove(_paperKey);
  }

  Future<void> _writeOptionalInt(String key, int? value) async {
    if (value == null) {
      await _prefs.remove(key);
    } else {
      await _prefs.setInt(key, value);
    }
  }
}
