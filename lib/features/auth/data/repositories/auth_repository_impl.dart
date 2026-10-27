import 'package:primelearn/core/session/session.dart';
import 'package:primelearn/features/auth/data/parsers/exam_context_parser.dart';
import 'package:primelearn/features/auth/data/parsers/login_response_parser.dart';
import 'package:primelearn/features/auth/data/services/auth_api.dart';
import 'package:primelearn/features/auth/domain/entities/bank_context.dart';
import 'package:primelearn/features/auth/domain/repositories/auth_repository.dart';

/// 认证仓储实现：负责调接口与 DTO → Entity 映射。
class AuthRepositoryImpl implements AuthRepository {
  /// 创建仓储实现。
  AuthRepositoryImpl(this._api);

  final AuthApi _api;
  static const LoginResponseParser _loginParser = LoginResponseParser();
  static const ExamContextParser _contextParser = ExamContextParser();

  @override
  Future<void> ensureSessionCookie() => _api.fetchValidateCode();

  @override
  Future<Session> login({
    required String idCard,
    required String password,
  }) async {
    final body = await _api.login(idCard: idCard, password: password);
    final dto = _loginParser.parse(body);
    return Session(userId: dto.userId, userName: dto.userName);
  }

  @override
  Future<BankContext> fetchBankContext(String userId) async {
    final body = await _api.firstIndexOne(userId);
    final dto = _contextParser.parse(body);
    return BankContext(bankName: dto.bankName, examTypeId: dto.examTypeId);
  }
}
