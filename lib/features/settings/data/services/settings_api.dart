import 'package:primelearn/core/network/api_client.dart';

/// 设置相关端点。
class SettingsApi {
  /// 创建 API 封装。
  SettingsApi(this._client);

  final ApiClient _client;

  /// 积分规则页（HTML 片段）；`pid` 为明文。
  static String rulesPath(String userId) => '/PersonWap/MyRule?pid=$userId';

  /// 拉取积分规则 HTML。
  ///
  /// 该接口本来就返回 HTML，需跳过「登录页 HTML」检测，否则会被误判为会话失效。
  Future<String> fetchRulesHtml(String userId) =>
      _client.getRaw(rulesPath(userId), expectHtml: true);
}
