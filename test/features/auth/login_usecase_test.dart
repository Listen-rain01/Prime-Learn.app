import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:primelearn/core/errors/use_case_failure.dart';
import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/core/session/session.dart';
import 'package:primelearn/features/auth/application/login_usecase.dart';
import 'package:primelearn/features/auth/domain/entities/bank_context.dart';
import 'package:primelearn/features/auth/domain/repositories/auth_repository.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repository;
  late LoginUseCase useCase;

  setUp(() {
    repository = _MockAuthRepository();
    useCase = LoginUseCase(repository, retryDelay: Duration.zero);
  });

  void stubLoginSuccess() {
    when(() => repository.ensureSessionCookie()).thenAnswer((_) async {});
    when(
      () => repository.login(
        idCard: any(named: 'idCard'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => const Session(userId: 'u1', userName: '张小赞'));
    when(() => repository.fetchBankContext('u1')).thenAnswer(
      (_) async => const BankContext(bankName: '题库A', examTypeId: 't1'),
    );
  }

  test('成功：预建会话 → 登录 → 题库信息合并', () async {
    stubLoginSuccess();

    final session = await useCase.execute(
      idCard: ' 610525199001011238 ',
      password: 'p@ss',
    );

    expect(session.userId, 'u1');
    expect(session.userName, '张小赞');
    expect(session.bankName, '题库A');
    expect(session.examTypeId, 't1');
    verify(() => repository.ensureSessionCookie()).called(1);
    verify(
      () => repository.login(idCard: '610525199001011238', password: 'p@ss'),
    ).called(1);
    verify(() => repository.fetchBankContext('u1')).called(1);
  });

  test('空输入：直接失败且不触发任何请求', () async {
    await expectLater(
      useCase.execute(idCard: '  ', password: 'p'),
      throwsA(
        isA<UseCaseFailure>().having(
          (e) => e.message,
          'message',
          '请输入有效的 18 位身份证号',
        ),
      ),
    );
    verifyNever(() => repository.ensureSessionCookie());
    verifyNever(
      () => repository.login(
        idCard: any(named: 'idCard'),
        password: any(named: 'password'),
      ),
    );
  });

  test('密码为空：提示请输入登录密码', () async {
    await expectLater(
      useCase.execute(idCard: '610525199001011238', password: ''),
      throwsA(
        isA<UseCaseFailure>().having((e) => e.message, 'message', '请输入登录密码'),
      ),
    );
    verifyNever(() => repository.ensureSessionCookie());
  });

  test('身份证号不是 18 位：不触发请求', () async {
    await expectLater(
      useCase.execute(idCard: '12345', password: 'p'),
      throwsA(
        isA<UseCaseFailure>().having(
          (e) => e.message,
          'message',
          '请输入有效的 18 位身份证号',
        ),
      ),
    );
    verifyNever(() => repository.ensureSessionCookie());
  });

  test('登录文案失败：原样透出且不重试登录', () async {
    when(() => repository.ensureSessionCookie()).thenAnswer((_) async {});
    when(
      () => repository.login(
        idCard: any(named: 'idCard'),
        password: any(named: 'password'),
      ),
    ).thenThrow(
      const ApiException(kind: ApiErrorKind.protocol, message: '密码错误'),
    );

    await expectLater(
      useCase.execute(idCard: '610525199001011238', password: 'wrong'),
      throwsA(
        isA<UseCaseFailure>()
            .having((e) => e.message, 'message', '密码错误')
            .having((e) => e.canRetry, 'canRetry', isFalse),
      ),
    );
    verify(
      () => repository.login(
        idCard: any(named: 'idCard'),
        password: any(named: 'password'),
      ),
    ).called(1);
    verifyNever(() => repository.fetchBankContext(any()));
  });

  test('预建会话首次失败可重试一次并成功', () async {
    var calls = 0;
    when(() => repository.ensureSessionCookie()).thenAnswer((_) async {
      calls += 1;
      if (calls == 1) {
        throw const ApiException(kind: ApiErrorKind.network, message: '网络不可用');
      }
    });
    when(
      () => repository.login(
        idCard: any(named: 'idCard'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => const Session(userId: 'u1', userName: '张小赞'));
    when(() => repository.fetchBankContext('u1'))
        .thenAnswer((_) async => const BankContext());

    final session = await useCase.execute(
      idCard: '610525199001011238',
      password: 'p',
    );

    expect(session.userId, 'u1');
    expect(calls, 2);
  });

  test('预建会话两次失败：不再登录，标记可重试', () async {
    when(() => repository.ensureSessionCookie()).thenThrow(
      const ApiException(kind: ApiErrorKind.timeout, message: '网络超时'),
    );

    await expectLater(
      useCase.execute(idCard: '610525199001011238', password: 'p'),
      throwsA(
        isA<UseCaseFailure>()
            .having((e) => e.canRetry, 'canRetry', isTrue)
            .having((e) => e.message, 'message', '网络超时'),
      ),
    );
    verify(() => repository.ensureSessionCookie()).called(2);
    verifyNever(
      () => repository.login(
        idCard: any(named: 'idCard'),
        password: any(named: 'password'),
      ),
    );
  });

  test('会话失效：透出 sessionExpired', () async {
    when(() => repository.ensureSessionCookie()).thenAnswer((_) async {});
    when(
      () => repository.login(
        idCard: any(named: 'idCard'),
        password: any(named: 'password'),
      ),
    ).thenThrow(
      const ApiException(kind: ApiErrorKind.sessionExpired, message: '会话已失效'),
    );

    await expectLater(
      useCase.execute(idCard: '610525199001011238', password: 'p'),
      throwsA(
        isA<UseCaseFailure>().having(
          (e) => e.sessionExpired,
          'sessionExpired',
          isTrue,
        ),
      ),
    );
  });
}
