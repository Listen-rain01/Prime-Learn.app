import 'package:primelearn/core/network/api_exception.dart';

/// `DoWriteAnswerAll` 响应解析。
///
/// 平台返回的是非标准 JSON（键未加引号）：
/// `{totalCount:1,success:true,error:"",...}`，不能直接用 jsonDecode。
class ExamSubmitParser {
  /// 创建解析器。
  const ExamSubmitParser();

  /// 匹配**整键** `success`：必须位于 `{`/`,` 之后或串首，
  /// 避免把 `notsuccess:true`、或 error 文案里的 `success:true` 当成结果。
  static final RegExp _successKey = RegExp(
    r'''(?:^|[{,])"?[sS]uccess"?:([A-Za-z]+)''',
  );

  /// 提取 `error` 文案（可能为空串）。
  static final RegExp _errorValue = RegExp(r'''"?[eE]rror"?:"([^"]*)"''');

  /// 解析；成功返回，失败抛 [ApiException]。
  void parse(String body) {
    if (body.trim().isEmpty) {
      throw const ApiException(
        kind: ApiErrorKind.protocol,
        message: '提交答案返回空响应',
      );
    }
    final normalized = body.replaceAll(RegExp(r'\s+'), '');
    final match = _successKey.firstMatch(normalized);
    if (match == null) {
      throw const ApiException(
        kind: ApiErrorKind.protocol,
        message: '提交答案响应格式异常',
      );
    }
    // 只认第一个 success 键，且必须是 true/false 字面量。
    final value = match.group(1)?.toLowerCase();
    if (value == 'true') return;
    if (value == 'false') {
      final error = _errorValue.firstMatch(normalized)?.group(1)?.trim() ?? '';
      throw ApiException(
        kind: ApiErrorKind.protocol,
        message: error.isEmpty ? '提交答案失败' : '提交答案失败：$error',
      );
    }
    throw const ApiException(
      kind: ApiErrorKind.protocol,
      message: '提交答案响应格式异常',
    );
  }
}
