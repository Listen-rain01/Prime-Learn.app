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
  static const String _singleKey = 'bank_preset_single_count';
  static const String _multipleKey = 'bank_preset_multiple_count';
  static const String _judgeKey = 'bank_preset_judge_count';
  static const String _paperNameKey = 'bank_preset_paper_name';
  static const String _paperIdKey = 'bank_preset_paper_id';
  static const String _paperTotalKey = 'bank_preset_paper_total';
  static const String _paperPassKey = 'bank_preset_paper_pass';

  final SharedPreferences _prefs;

  /// 读取预设；未设置时返回 null。旧数据缺失的字段为 null。
  BankPreset? read() {
    final id = _prefs.getString(_idKey);
    final name = _prefs.getString(_nameKey);
    if (id == null || id.isEmpty) return null;
    return BankPreset(
      bankId: id,
      bankName: name ?? '',
      questionCount: _prefs.getInt(_questionKey),
      paperCount: _prefs.getInt(_paperKey),
      singleCount: _prefs.getInt(_singleKey),
      multipleCount: _prefs.getInt(_multipleKey),
      judgeCount: _prefs.getInt(_judgeKey),
      paperName: _prefs.getString(_paperNameKey),
      paperId: _prefs.getString(_paperIdKey),
      paperTotalScore: _prefs.getDouble(_paperTotalKey),
      paperPassingGrade: _prefs.getDouble(_paperPassKey),
    );
  }

  /// 保存预设（包含题数/题型/试卷快照）。
  Future<void> save(BankPreset preset) async {
    await _prefs.setString(_idKey, preset.bankId);
    await _prefs.setString(_nameKey, preset.bankName);
    await _writeOptionalInt(_questionKey, preset.questionCount);
    await _writeOptionalInt(_paperKey, preset.paperCount);
    await _writeOptionalInt(_singleKey, preset.singleCount);
    await _writeOptionalInt(_multipleKey, preset.multipleCount);
    await _writeOptionalInt(_judgeKey, preset.judgeCount);
    await _writeOptionalString(_paperNameKey, preset.paperName);
    await _writeOptionalString(_paperIdKey, preset.paperId);
    await _writeOptionalDouble(_paperTotalKey, preset.paperTotalScore);
    await _writeOptionalDouble(_paperPassKey, preset.paperPassingGrade);
  }

  /// 清除预设。
  Future<void> clear() async {
    for (final key in [
      _idKey,
      _nameKey,
      _questionKey,
      _paperKey,
      _singleKey,
      _multipleKey,
      _judgeKey,
      _paperNameKey,
      _paperIdKey,
      _paperTotalKey,
      _paperPassKey,
    ]) {
      await _prefs.remove(key);
    }
  }

  Future<void> _writeOptionalInt(String key, int? value) async {
    if (value == null) {
      await _prefs.remove(key);
    } else {
      await _prefs.setInt(key, value);
    }
  }

  Future<void> _writeOptionalString(String key, String? value) async {
    if (value == null || value.isEmpty) {
      await _prefs.remove(key);
    } else {
      await _prefs.setString(key, value);
    }
  }

  Future<void> _writeOptionalDouble(String key, double? value) async {
    if (value == null) {
      await _prefs.remove(key);
    } else {
      await _prefs.setDouble(key, value);
    }
  }
}
