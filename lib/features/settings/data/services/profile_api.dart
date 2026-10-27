import 'package:primelearn/core/network/api_client.dart';
import 'package:primelearn/core/protocol/esdt_codec.dart';

/// 个人信息端点（docs/api/个人信息接口手册.md §6.1）。
class ProfileApi {
  /// 创建 API 封装。
  ProfileApi(this._client);

  final ApiClient _client;
  static const EsdtCodec _esdt = EsdtCodec();

  /// 请求体：`pid=Esdt(pid)&sstype=0`。
  static Map<String, String> baseInfoForm(String userId) => {
    'pid': _esdt.encode(userId),
    'sstype': '0',
  };

  /// 个人基础资料载体，返回 HTML（内嵌 vData）。
  Future<String> fetchBaseInfo(String userId) => _client.postForm(
    '/PersonWap/MyBaseInfo',
    baseInfoForm(userId),
    expectHtml: true,
  );
}
