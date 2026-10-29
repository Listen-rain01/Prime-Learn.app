import 'package:primelearn/core/errors/no_retry.dart';
import 'package:primelearn/core/evidence/write_gateway.dart';
import 'package:primelearn/core/network/api_client.dart';
import 'package:primelearn/core/session/session_store.dart';
import 'package:primelearn/features/reading/application/complete_reading.dart';
import 'package:primelearn/features/reading/application/save_reading_preset.dart';
import 'package:primelearn/features/reading/data/repositories/reading_preset_repository_impl.dart';
import 'package:primelearn/features/reading/data/repositories/reading_repository_impl.dart';
import 'package:primelearn/features/reading/data/services/reading_api.dart';
import 'package:primelearn/features/reading/data/services/reading_preset_store.dart';
import 'package:primelearn/features/reading/domain/entities/reading_catalog.dart';
import 'package:primelearn/features/reading/domain/repositories/reading_preset_repository.dart';
import 'package:primelearn/features/reading/domain/repositories/reading_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'reading_providers.g.dart';

/// 阅读 API。
@Riverpod(keepAlive: true, retry: noProviderRetry)
ReadingApi readingApi(Ref ref) => ReadingApi(ref.watch(apiClientProvider));

/// 阅读仓库。
@Riverpod(keepAlive: true, retry: noProviderRetry)
ReadingRepository readingRepository(Ref ref) =>
    ReadingRepositoryImpl(ref.watch(readingApiProvider));

/// 阅读预设依赖的本地偏好。
@Riverpod(keepAlive: true, retry: noProviderRetry)
Future<SharedPreferences> readingPreferences(Ref ref) =>
    SharedPreferences.getInstance();

/// 阅读预设存储。
@Riverpod(keepAlive: true, retry: noProviderRetry)
Future<ReadingPresetStore> readingPresetStore(Ref ref) async =>
    ReadingPresetStore(await ref.watch(readingPreferencesProvider.future));

/// 阅读预设仓库。
@Riverpod(keepAlive: true, retry: noProviderRetry)
Future<ReadingPresetRepository> readingPresetRepository(Ref ref) async =>
    ReadingPresetRepositoryImpl(
      await ref.watch(readingPresetStoreProvider.future),
    );

/// 当前阅读预设。
///
/// 常驻：`DailyAutoRunner` 是 keepAlive，读取常驻 provider 才符合
/// riverpod_lint 的 `only_use_keep_alive_inside_keep_alive`；
/// 且这里只是读本地偏好，没有需要随页面释放的资源。
@Riverpod(keepAlive: true, retry: noProviderRetry)
Future<ReadingPreset?> readingPreset(Ref ref) async =>
    (await ref.watch(readingPresetRepositoryProvider.future)).read();

/// 保存阅读预设用例。
@Riverpod(retry: noProviderRetry)
Future<SaveReadingPreset> saveReadingPreset(Ref ref) async =>
    SaveReadingPreset(await ref.watch(readingPresetRepositoryProvider.future));

/// 完成阅读用例。
@Riverpod(keepAlive: true, retry: noProviderRetry)
CompleteReading completeReading(Ref ref) => CompleteReading(
  ref.watch(readingRepositoryProvider),
  ref.watch(writeGatewayProvider),
);

/// 一级分类。
@Riverpod(retry: noProviderRetry)
Future<List<ReadingCategory>> readingCategories(Ref ref) =>
    ref.watch(readingRepositoryProvider).fetchCategories();

/// 子分类查询参数。
typedef ReadingChildQuery = ({String parentId, String departmentId});

/// 子分类。
@Riverpod(retry: noProviderRetry)
Future<List<ReadingCategory>> readingChildren(
  Ref ref,
  ReadingChildQuery query,
) => ref
    .watch(readingRepositoryProvider)
    .fetchChildren(parentId: query.parentId, departmentId: query.departmentId);

/// 分类下的文章。
@Riverpod(retry: noProviderRetry)
Future<List<ReadingArticle>> readingArticles(Ref ref, String typeId) {
  final session = ref.watch(sessionStoreProvider);
  if (session == null) return Future.value(const []);
  return ref
      .watch(readingRepositoryProvider)
      .fetchArticles(userId: session.userId, typeId: typeId);
}
