import 'package:primelearn/core/errors/no_retry.dart';
import 'package:primelearn/core/errors/use_case_failure.dart';
import 'package:primelearn/core/evidence/write_gateway.dart';
import 'package:primelearn/core/network/api_client.dart';
import 'package:primelearn/core/session/session_store.dart';
import 'package:primelearn/features/checkin/application/perform_check_in.dart';
import 'package:primelearn/features/checkin/data/repositories/check_in_repository_impl.dart';
import 'package:primelearn/features/checkin/data/services/check_in_api.dart';
import 'package:primelearn/features/checkin/domain/entities/check_in_result.dart';
import 'package:primelearn/features/checkin/domain/repositories/check_in_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'check_in_providers.g.dart';

/// 签到 API 实例。
@Riverpod(keepAlive: true)
CheckInApi checkInApi(Ref ref) => CheckInApi(ref.watch(apiClientProvider));

/// 签到仓储实例。
@Riverpod(keepAlive: true)
CheckInRepository checkInRepository(Ref ref) =>
    CheckInRepositoryImpl(ref.watch(checkInApiProvider));

/// 执行签到用例。
@Riverpod(keepAlive: true)
PerformCheckIn performCheckIn(Ref ref) => PerformCheckIn(
  ref.watch(checkInRepositoryProvider),
  ref.watch(writeGatewayProvider),
);

/// 签到状态：null 表示本次未操作。
@Riverpod(retry: noProviderRetry)
class CheckInController extends _$CheckInController {
  @override
  Future<CheckInResult?> build() async => null;

  /// 提交签到；成功后由页面刷新今日任务。
  Future<void> submit() async {
    final session = ref.read(sessionStoreProvider);
    if (session == null) {
      state = AsyncError(const UseCaseFailure('未登录'), StackTrace.current);
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(performCheckInProvider).execute(session.userId),
    );
  }
}
