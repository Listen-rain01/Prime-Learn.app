/// 设置数据接口。
abstract interface class SettingsRepository {
  /// 积分规则纯文本。
  Future<String> fetchRulesText(String userId);
}
