import 'dart:typed_data';

import 'package:primelearn/core/network/api_client.dart';
import 'package:primelearn/core/protocol/esdt_codec.dart';

/// 个人信息端点（docs/api/个人信息接口手册.md §6）。
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

  /// 头像路径；`did`、`pid` 均需 Esdt 编码（已转义，不能再编码一次）。
  static String avatarPath(String userId, String departmentId) {
    final pid = _esdt.encode(userId);
    final did = _esdt.encode(departmentId);
    return '/ArchiveManger/D_PersonManager/GetPersonPhoto?did=$did&pid=$pid';
  }

  /// 个人基础资料载体，返回 HTML（内嵌 vData）。
  Future<String> fetchBaseInfo(String userId) => _client.postForm(
    '/PersonWap/MyBaseInfo',
    baseInfoForm(userId),
    expectHtml: true,
  );

  /// 头像图片流（需要会话 Cookie，因此走 ApiClient 而不是 Image.network）。
  Future<Uint8List> fetchAvatar(String userId, String departmentId) =>
      _client.getBytes(avatarPath(userId, departmentId));
}
