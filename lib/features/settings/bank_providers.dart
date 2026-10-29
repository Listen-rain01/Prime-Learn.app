import 'package:primelearn/core/errors/no_retry.dart';
import 'package:primelearn/core/evidence/write_gateway.dart';
import 'package:primelearn/core/network/api_client.dart';
import 'package:primelearn/core/session/session_store.dart';
import 'package:primelearn/features/exam/exam_providers.dart';
import 'package:primelearn/features/settings/application/ensure_bank_preset.dart';
import 'package:primelearn/features/settings/application/save_bank_preset.dart';
import 'package:primelearn/features/settings/data/repositories/bank_preset_repository_impl.dart';
import 'package:primelearn/features/settings/data/repositories/bank_repository_impl.dart';
import 'package:primelearn/features/settings/data/services/bank_api.dart';
import 'package:primelearn/features/settings/data/services/bank_preset_store.dart';
import 'package:primelearn/features/settings/domain/entities/bank_catalog.dart';
import 'package:primelearn/features/settings/domain/repositories/bank_preset_repository.dart';
import 'package:primelearn/features/settings/domain/repositories/bank_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'bank_providers.g.dart';

/// 子分类查询参数。
typedef BankChildQuery = ({
  String unitId,
  String styleId,
  String code,
  String departmentId,
});

/// 题库查询参数。
typedef BankOptionQuery = ({
  String unitId,
  String styleId,
  String departmentId,
  String year,
});

/// 本地偏好实例。
@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(Ref ref) =>
    SharedPreferences.getInstance();

/// 题库 API 实例。
@Riverpod(keepAlive: true)
BankApi bankApi(Ref ref) => BankApi(ref.watch(apiClientProvider));

/// 题库仓储实例。
@Riverpod(keepAlive: true)
BankRepository bankRepository(Ref ref) =>
    BankRepositoryImpl(ref.watch(bankApiProvider));

/// 题库预设存储（底层偏好）。
@Riverpod(keepAlive: true)
Future<BankPresetStore> bankPresetStore(Ref ref) async =>
    BankPresetStore(await ref.watch(sharedPreferencesProvider.future));

/// 题库预设仓储。
@Riverpod(keepAlive: true)
Future<BankPresetRepository> bankPresetRepository(Ref ref) async =>
    BankPresetRepositoryImpl(await ref.watch(bankPresetStoreProvider.future));

/// 当前预设；未设置时为 null。
///
/// 常驻：`DailyAutoRunner` 是 keepAlive，读取常驻 provider 才符合
/// riverpod_lint 的 `only_use_keep_alive_inside_keep_alive`；
/// 且这里只是读本地偏好，没有需要随页面释放的资源。
@Riverpod(keepAlive: true, retry: noProviderRetry)
Future<BankPreset?> bankPreset(Ref ref) async {
  final repository = await ref.watch(bankPresetRepositoryProvider.future);
  return repository.read();
}

/// 保存预设（先校验可考试卷）。
@Riverpod(keepAlive: true)
Future<SaveBankPreset> saveBankPreset(Ref ref) async => SaveBankPreset(
  ref.watch(examRepositoryProvider),
  await ref.watch(bankPresetRepositoryProvider.future),
);

/// 执行前的题库对齐用例。
@Riverpod(keepAlive: true)
EnsureBankPreset ensureBankPreset(Ref ref) => EnsureBankPreset(
  ref.watch(bankRepositoryProvider),
  ref.watch(writeGatewayProvider),
);

/// 单位列表。
@Riverpod(retry: noProviderRetry)
Future<List<BankUnit>> bankUnits(Ref ref) async {
  final session = ref.watch(sessionStoreProvider);
  if (session == null) return const [];
  return ref.watch(bankRepositoryProvider).fetchUnits(session.userId);
}

/// 大类列表。
@Riverpod(retry: noProviderRetry)
Future<List<BankStyle>> bankStyles(Ref ref, String unitId) async {
  final session = ref.watch(sessionStoreProvider);
  if (session == null) return const [];
  return ref.watch(bankRepositoryProvider).fetchStyles(session.userId, unitId);
}

/// 子分类列表。
@Riverpod(retry: noProviderRetry)
Future<List<BankStyle>> bankChildren(Ref ref, BankChildQuery query) => ref
    .watch(bankRepositoryProvider)
    .fetchChildren(
      unitId: query.unitId,
      styleId: query.styleId,
      code: query.code,
      departmentId: query.departmentId,
    );

/// 题库列表。
@Riverpod(retry: noProviderRetry)
Future<List<BankOption>> bankOptions(Ref ref, BankOptionQuery query) => ref
    .watch(bankRepositoryProvider)
    .fetchOptions(
      unitId: query.unitId,
      styleId: query.styleId,
      departmentId: query.departmentId,
      year: query.year,
    );
