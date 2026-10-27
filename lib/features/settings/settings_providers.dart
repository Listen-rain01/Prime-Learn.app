import 'package:primelearn/core/errors/no_retry.dart';
import 'package:primelearn/core/network/api_client.dart';
import 'package:primelearn/core/session/session_store.dart';
import 'package:primelearn/features/settings/application/load_rules.dart';
import 'package:primelearn/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:primelearn/features/settings/data/services/settings_api.dart';
import 'package:primelearn/features/settings/domain/repositories/settings_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_providers.g.dart';

/// 设置 API 实例。
@Riverpod(keepAlive: true)
SettingsApi settingsApi(Ref ref) => SettingsApi(ref.watch(apiClientProvider));

/// 设置仓储实例。
@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) =>
    SettingsRepositoryImpl(ref.watch(settingsApiProvider));

/// 加载积分规则用例。
@Riverpod(keepAlive: true)
LoadRules loadRules(Ref ref) =>
    LoadRules(ref.watch(settingsRepositoryProvider));

/// 积分规则纯文本。
@Riverpod(retry: noProviderRetry)
Future<String> rulesText(Ref ref) async {
  final session = ref.watch(sessionStoreProvider);
  if (session == null) return '';
  return ref.watch(loadRulesProvider).execute(session.userId);
}
