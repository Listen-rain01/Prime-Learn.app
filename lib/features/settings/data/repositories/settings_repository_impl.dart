import 'package:primelearn/features/settings/data/parsers/rules_html_parser.dart';
import 'package:primelearn/features/settings/data/services/settings_api.dart';
import 'package:primelearn/features/settings/domain/repositories/settings_repository.dart';

/// 设置仓储实现。
class SettingsRepositoryImpl implements SettingsRepository {
  /// 创建仓储实现。
  SettingsRepositoryImpl(this._api);

  final SettingsApi _api;
  static const RulesHtmlParser _rulesParser = RulesHtmlParser();

  @override
  Future<String> fetchRulesText(String userId) async {
    final html = await _api.fetchRulesHtml(userId);
    return _rulesParser.parse(html);
  }
}
