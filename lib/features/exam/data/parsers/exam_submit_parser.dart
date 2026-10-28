import 'package:primelearn/core/network/api_exception.dart';

/// `DoWriteAnswerAll` 响应解析。
///
/// 平台返回的是非标准 JSON（键未加引号）：
/// `{totalCount:1,success:true,error:"",...}`，不能直接用 jsonDecode。
class ExamSubmitParser {
  /// 创建解析器。
  const ExamSubmitParser();

  /// 解析；成功返回，失败抛 [ApiException]。
  void parse(String body) {
    if (body.trim().isEmpty) {
      throw const ApiException(
        kind: ApiErrorKind.protocol,
        message: '提交答案返回空响应',
      );
    }
    final normalized = body.replaceAll(RegExp(r'\s+'), '');
    if (RegExp(r'"?success"?\s*:\s*true').hasMatch(normalized)) return;
    if (RegExp(r'"?success"?\s*:\s*false').hasMatch(normalized)) {
      throw const ApiException(kind: ApiErrorKind.protocol, message: '提交答案失败');
    }
    throw const ApiException(
      kind: ApiErrorKind.protocol,
      message: '提交答案响应格式异常',
    );
  }
}
