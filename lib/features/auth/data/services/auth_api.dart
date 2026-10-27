import 'package:primelearn/core/network/api_client.dart';
import 'package:primelearn/core/protocol/esdt_codec.dart';

/// 认证相关端点（docs/api/登录接口文档.md §5）。
class AuthApi {
  /// 创建 API 封装。
  AuthApi(this._client);

  final ApiClient _client;
  static const EsdtCodec _esdt = EsdtCodec();

  /// 预建会话：GET /Home/GetValidateCode。
  Future<void> fetchValidateCode() => _client.getValidateCode();

  /// 登录：POST /PersonWap/GetPersonInfo，账号密码需 Esdt 编码。
  Future<String> login({required String idCard, required String password}) =>
      _client.postForm('/PersonWap/GetPersonInfo', {
        'idcard': _esdt.encode(idCard),
        'pwd': _esdt.encode(password),
        'yzm': 'auto',
        'openid': '',
        'style': '0',
        'auto': 'true',
      });

  /// 会话校验 / 当前题库：POST /PersonWap/FirstIndexOne。
  Future<String> firstIndexOne(String userId) =>
      _client.postForm('/PersonWap/FirstIndexOne', {'pid': userId});
}
