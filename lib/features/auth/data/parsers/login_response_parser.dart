import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/core/protocol/pipe_response.dart';
import 'package:primelearn/features/auth/data/models/login_result_dto.dart';

/// 登录响应解析：`|<userId>|<userName>|<sessionHash>|<returnCode>`。
class LoginResponseParser {
  /// 创建解析器。
  const LoginResponseParser();

  /// 解析登录响应；失败时抛出携带平台文案的 [ApiException]。
  LoginResultDto parse(String body) {
    final response = PipeResponse.parse(body);
    if (!response.isSuccess) {
      throw ApiException(
        kind: ApiErrorKind.protocol,
        message: response.errorMessage ?? '登录失败',
      );
    }
    final userId = response.part(1);
    if (userId == null || userId.isEmpty) {
      throw const ApiException(
        kind: ApiErrorKind.protocol,
        message: '登录响应缺少用户标识',
      );
    }
    return LoginResultDto(
      userId: userId,
      userName: response.part(2) ?? '',
      sessionHash: response.part(3),
      returnCode: response.part(4),
    );
  }
}
