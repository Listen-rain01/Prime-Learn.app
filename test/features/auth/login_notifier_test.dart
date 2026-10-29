import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/core/session/account_memory.dart';
import 'package:primelearn/core/session/session.dart';
import 'package:primelearn/core/session/session_store.dart';
import 'package:primelearn/features/auth/auth_providers.dart';
import 'package:primelearn/features/auth/domain/entities/bank_context.dart';
import 'package:primelearn/features/auth/domain/repositories/auth_repository.dart';
import 'package:primelearn/features/auth/presentation/providers/login_notifier.dart';
import 'package:primelearn/features/auth/presentation/providers/login_state.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.loginFailure});

  final ApiException? loginFailure;
  int ensureCalls = 0;

  @override
  Future<void> ensureSessionCookie() async => ensureCalls += 1;

  @override
  Future<Session> login({
    required String idCard,
    required String password,
  }) async {
    final failure = loginFailure;
    if (failure != null) throw failure;
    return const Session(userId: 'u1', userName: '张小赞');
  }

  @override
  Future<BankContext> fetchBankContext(String userId) async =>
      const BankContext(bankName: '题库A', examTypeId: 't1');
}

class _FakeAccountMemory extends AccountMemory {
  String? saved;

  @override
  Future<String?> read() async => saved;

  @override
  Future<void> save(String idCard) async => saved = idCard;

  @override
  Future<void> clear() async => saved = null;
}

void main() {
  late _FakeAuthRepository repository;
  late _FakeAccountMemory memory;
  late ProviderContainer container;

  setUp(() {
    repository = _FakeAuthRepository();
    memory = _FakeAccountMemory();
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
        accountMemoryProvider.overrideWithValue(memory),
      ],
    );
    addTearDown(container.dispose);
  });

  test('初始为 LoginIdle', () {
    expect(container.read(loginProvider), isA<LoginIdle>());
  });

  test('提交成功后保存会话并记住账号', () async {
    final controller = container.read(loginProvider.notifier);

    final pending = controller.submit(
      idCard: '610525199001011238',
      password: 'p@ss',
      remember: true,
    );
    expect(container.read(loginProvider), isA<LoginSubmitting>());

    await pending;

    final state = container.read(loginProvider);
    expect(state, isA<LoginSucceeded>());
    expect((state as LoginSucceeded).session.bankName, '题库A');
    expect(container.read(sessionStoreProvider)?.userId, 'u1');
    expect(memory.saved, '610525199001011238');
    expect(repository.ensureCalls, 1);
  });

  test('失败时进入 LoginFailed 且不保存会话', () async {
    repository = _FakeAuthRepository(
      loginFailure: const ApiException(
        kind: ApiErrorKind.protocol,
        message: '密码错误',
      ),
    );
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
        accountMemoryProvider.overrideWithValue(memory),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(loginProvider.notifier)
        .submit(idCard: '610525199001011238', password: 'wrong');

    final state = container.read(loginProvider);
    expect(state, isA<LoginFailed>());
    expect((state as LoginFailed).message, '密码错误');
    expect(container.read(sessionStoreProvider), isNull);
  });

  test('重复提交在提交中会被忽略', () async {
    final controller = container.read(loginProvider.notifier);
    final first = controller.submit(
      idCard: '610525199001011238',
      password: 'p',
    );
    await controller.submit(idCard: '610525199001011238', password: 'p');
    await first;

    expect(container.read(loginProvider), isA<LoginSucceeded>());
    expect(repository.ensureCalls, 1);
  });

  test('reset 回到 LoginIdle', () async {
    final controller = container.read(loginProvider.notifier);
    await controller.submit(idCard: 'bad', password: 'p');
    expect(container.read(loginProvider), isA<LoginFailed>());

    controller.reset();
    expect(container.read(loginProvider), isA<LoginIdle>());
  });
}
