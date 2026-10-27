import 'dart:typed_data';

import 'package:primelearn/core/errors/no_retry.dart';
import 'package:primelearn/core/network/api_client.dart';
import 'package:primelearn/core/session/session_store.dart';
import 'package:primelearn/features/settings/application/load_avatar.dart';
import 'package:primelearn/features/settings/application/load_profile.dart';
import 'package:primelearn/features/settings/data/repositories/profile_repository_impl.dart';
import 'package:primelearn/features/settings/data/services/profile_api.dart';
import 'package:primelearn/features/settings/domain/entities/person_profile.dart';
import 'package:primelearn/features/settings/domain/repositories/profile_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_providers.g.dart';

/// 个人信息 API 实例。
@Riverpod(keepAlive: true)
ProfileApi profileApi(Ref ref) => ProfileApi(ref.watch(apiClientProvider));

/// 个人信息仓储实例。
@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) =>
    ProfileRepositoryImpl(ref.watch(profileApiProvider));

/// 加载个人信息用例。
@Riverpod(keepAlive: true)
LoadProfile loadProfile(Ref ref) =>
    LoadProfile(ref.watch(profileRepositoryProvider));

/// 加载头像用例。
@Riverpod(keepAlive: true)
LoadAvatar loadAvatar(Ref ref) =>
    LoadAvatar(ref.watch(profileRepositoryProvider));

/// 当前登录用户的个人信息；未登录时为 null。
@Riverpod(retry: noProviderRetry)
Future<PersonProfile?> personProfile(Ref ref) async {
  final session = ref.watch(sessionStoreProvider);
  if (session == null) return null;
  return ref.watch(loadProfileProvider).execute(session.userId);
}

/// 头像字节；与个人资料解耦，慢或失败都不阻塞资料展示。
@Riverpod(retry: noProviderRetry)
Future<Uint8List?> profileAvatar(Ref ref) async {
  final profile = await ref.watch(personProfileProvider.future);
  final session = ref.watch(sessionStoreProvider);
  final departmentId = profile?.departmentId;
  if (profile == null || session == null || departmentId == null) return null;
  try {
    return await ref
        .watch(loadAvatarProvider)
        .execute(session.userId, departmentId);
  } on Object {
    // 头像属可选资源：失败回退姓名首字，不向界面抛错。
    return null;
  }
}
