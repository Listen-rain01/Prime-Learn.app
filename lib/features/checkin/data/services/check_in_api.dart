import 'package:primelearn/core/network/api_client.dart';
import 'package:primelearn/core/protocol/esdt_codec.dart';
import 'package:primelearn/features/checkin/domain/check_in_endpoint.dart';

/// 签到端点（docs/api/签到接口文档.md §4.1）。
class CheckInApi {
  /// 创建 API 封装。
  CheckInApi(this._client);

  final ApiClient _client;
  static const EsdtCodec _esdt = EsdtCodec();

  /// 请求表单：`pid` 需 Esdt 编码。
  static Map<String, String> form(String userId) => {
    'pid': _esdt.encode(userId),
  };

  /// 执行签到（幂等）。
  Future<String> checkIn(String userId) =>
      _client.postForm(checkInEndpoint, form(userId));
}
