import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/core/protocol/pipe_response.dart';
import 'package:primelearn/features/auth/data/models/exam_context_dto.dart';

/// 会话校验响应解析：首段空 = 有效，下标 4 = 题库名，下标 6 = 题库 ID。
class ExamContextParser {
  /// 创建解析器。
  const ExamContextParser();

  /// 解析 FirstIndexOne 响应；失败时抛出 [ApiException]。
  ExamContextDto parse(String body) {
    final response = PipeResponse.parse(body);
    if (!response.isSuccess) {
      throw ApiException(
        kind: ApiErrorKind.protocol,
        message: response.errorMessage ?? '会话校验失败',
      );
    }
    final bankName = response.part(4);
    final examTypeId = response.part(6);
    return ExamContextDto(
      bankName: bankName == null || bankName.isEmpty ? null : bankName,
      examTypeId: examTypeId == null || examTypeId.isEmpty ? null : examTypeId,
    );
  }
}
