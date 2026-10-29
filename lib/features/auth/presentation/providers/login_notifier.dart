import 'package:primelearn/core/errors/use_case_failure.dart';
import 'package:primelearn/core/session/account_memory.dart';
import 'package:primelearn/core/session/session_store.dart';
import 'package:primelearn/features/auth/auth_providers.dart';
import 'package:primelearn/features/auth/presentation/providers/login_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'login_notifier.g.dart';

/// 登录页状态机：负责状态迁移，不碰网络细节。
@Riverpod(keepAlive: true)
class LoginNotifier extends _$LoginNotifier {
  @override
  LoginState build() => const LoginIdle();

  /// 提交登录。
  Future<void> submit({
    required String idCard,
    required String password,
    bool remember = false,
  }) async {
    if (state is LoginSubmitting) return;
    state = const LoginSubmitting();
    try {
      final session = await ref
          .read(loginUseCaseProvider)
          .execute(idCard: idCard, password: password);
      ref.read(sessionStoreProvider.notifier).save(session);
      final memory = ref.read(accountMemoryProvider);
      if (remember) {
        await memory.save(
          SavedAccount(
            idCard: idCard.trim(),
            password: password,
            userName: session.userName,
          ),
        );
      }
      state = LoginSucceeded(session);
    } on UseCaseFailure catch (failure) {
      state = LoginFailed(
        failure.message,
        canRetry: failure.canRetry,
        sessionExpired: failure.sessionExpired,
      );
    } on Object {
      state = const LoginFailed('登录失败，请稍后重试');
    }
  }

  /// 返回可编辑状态（用户重新输入时调用）。
  void reset() => state = const LoginIdle();
}
