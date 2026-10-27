import 'package:primelearn/core/session/session.dart';
import 'package:primelearn/features/auth/domain/entities/bank_context.dart';

/// 认证数据接口：用例只依赖这里，不依赖 Dio 或解析细节。
abstract interface class AuthRepository {
  /// 预建会话（GetValidateCode），使服务端下发 `ASP.NET_SessionId`。
  Future<void> ensureSessionCookie();

  /// 提交账号密码并解析登录响应；失败抛 `ApiException`。
  Future<Session> login({required String idCard, required String password});

  /// 校验会话有效性并读取当前题库。
  Future<BankContext> fetchBankContext(String userId);
}
