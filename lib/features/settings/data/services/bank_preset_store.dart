import 'package:primelearn/features/settings/domain/entities/bank_catalog.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 题库预设的本地存储（非敏感偏好，用 shared_preferences）。
class BankPresetStore {
  /// 创建存储。
  BankPresetStore(this._prefs);

  static const String _idKey = 'bank_preset_id';
  static const String _nameKey = 'bank_preset_name';

  final SharedPreferences _prefs;

  /// 读取预设；未设置时返回 null。
  BankPreset? read() {
    final id = _prefs.getString(_idKey);
    final name = _prefs.getString(_nameKey);
    if (id == null || id.isEmpty) return null;
    return BankPreset(bankId: id, bankName: name ?? '');
  }

  /// 保存预设。
  Future<void> save(BankPreset preset) async {
    await _prefs.setString(_idKey, preset.bankId);
    await _prefs.setString(_nameKey, preset.bankName);
  }

  /// 清除预设。
  Future<void> clear() async {
    await _prefs.remove(_idKey);
    await _prefs.remove(_nameKey);
  }
}
