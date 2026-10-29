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

    if (!_isSuccess(decoded['success'])) {
      throw ApiException(
        kind: ApiErrorKind.protocol,
        message: _failureText(decoded, label),
      );
    }
    return decoded;
  }

  /// 取失败文案。
  ///
  /// 平台不同接口用的字段不同：有的写 `message`，有的写 `error`
  /// （可直接看 `docs/api/手机考试接口文档.md` §5.1：`success=false` 读 `error`）。
  /// 优先 message，其次 error，都没有才用通用文案。
  static String _failureText(Map<String, dynamic> json, String label) {
    for (final key in const ['message', 'error', 'msg']) {
      final text = json[key]?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }
    return '$label失败';
  }

  /// 判定 `success` 字段。
  ///
  /// 平台曾把布尔值序列化成字符串（`"success":"false"`），
  /// 只判 `== false` 会把明确的失败当成成功。
  static bool _isSuccess(Object? value) {
    if (value == null) return true;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final text = value.trim().toLowerCase();
      if (text.isEmpty) return true;
      return text != 'false' && text != '0' && text != 'no';
    }
    return true;
  }

  /// 取出 `data` 数组；缺失时返回空列表，非数组时抛协议异常。
  ///
  /// 单个元素不是对象时跳过（平台偶尔夹带 `null`），但若**一条都解析不出**
  /// 且原数组非空，则抛异常——否则会把「解析失败」伪装成「没有数据」。
  static List<Map<String, dynamic>> list(String body, {required String label}) {
    final data = decode(body, label: label)['data'];
    if (data == null) return const [];
    if (data is! List<dynamic>) {
      throw ApiException(kind: ApiErrorKind.protocol, message: '$label数据格式异常');
    }
    final items = <Map<String, dynamic>>[];
    for (final item in data) {
      if (item is Map<String, dynamic>) items.add(item);
    }
    if (items.isEmpty && data.isNotEmpty) {
      throw ApiException(
        kind: ApiErrorKind.protocol,
        message: '$label数据格式异常（${data.length} 条记录均无法解析）',
      );
    }
    return items;
  }
}
