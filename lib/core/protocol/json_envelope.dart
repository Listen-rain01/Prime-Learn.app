import 'dart:convert';

import 'package:primelearn/core/network/api_exception.dart';

/// `{ "success": bool, "data": ..., "message": string }` 响应信封的通用解析。
///
/// 平台列表型接口结构一致，统一在这里处理空响应、非法 JSON、
/// `success=false` 与 `data` 类型校验，避免每个 parser 重复。
abstract final class JsonEnvelope {
  /// 解析并校验响应信封。
  ///
  /// [label] 用于拼接用户提示，例如 `获取今日任务`。
  static Map<String, dynamic> decode(String body, {required String label}) {
    if (body.isEmpty) {
      throw const ApiException(
        kind: ApiErrorKind.protocol,
        message: '服务器返回空响应',
      );
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(body);
    } on FormatException {
      throw ApiException(kind: ApiErrorKind.protocol, message: '$label响应格式异常');
    }
    if (decoded is! Map<String, dynamic>) {
      throw ApiException(kind: ApiErrorKind.protocol, message: '$label响应格式异常');
    }

    if (decoded['success'] == false) {
      throw ApiException(
        kind: ApiErrorKind.protocol,
        message: decoded['message']?.toString() ?? '$label失败',
      );
    }
    return decoded;
  }

  /// 取出 `data` 数组；缺失时返回空列表，非数组时抛协议异常。
  static List<Map<String, dynamic>> list(String body, {required String label}) {
    final data = decode(body, label: label)['data'];
    if (data == null) return const [];
    if (data is! List<dynamic>) {
      throw ApiException(kind: ApiErrorKind.protocol, message: '$label数据格式异常');
    }
    return [
      for (final item in data)
        if (item is Map<String, dynamic>) item,
    ];
  }
}
