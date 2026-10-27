// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 会话存储：登录态只放内存，重启后需重新登录。

@ProviderFor(SessionStore)
final sessionStoreProvider = SessionStoreProvider._();

/// 会话存储：登录态只放内存，重启后需重新登录。
final class SessionStoreProvider
    extends $NotifierProvider<SessionStore, Session?> {
  /// 会话存储：登录态只放内存，重启后需重新登录。
  SessionStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionStoreHash();

  @$internal
  @override
  SessionStore create() => SessionStore();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Session? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Session?>(value),
    );
  }
}

String _$sessionStoreHash() => r'c8fee3a097b342482c99d079ed80f92d77bbc671';

/// 会话存储：登录态只放内存，重启后需重新登录。

abstract class _$SessionStore extends $Notifier<Session?> {
  Session? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Session?, Session?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Session?, Session?>,
              Session?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// 账号记忆存储实例。

@ProviderFor(accountMemory)
final accountMemoryProvider = AccountMemoryProvider._();

/// 账号记忆存储实例。

final class AccountMemoryProvider
    extends $FunctionalProvider<AccountMemory, AccountMemory, AccountMemory>
    with $Provider<AccountMemory> {
  /// 账号记忆存储实例。
  AccountMemoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountMemoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountMemoryHash();

  @$internal
  @override
  $ProviderElement<AccountMemory> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AccountMemory create(Ref ref) {
    return accountMemory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountMemory value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountMemory>(value),
    );
  }
}

String _$accountMemoryHash() => r'94492cd516aaed16b20b9c67cf5780603de42505';

/// 已记住的身份证号（登录页用于预填）。

@ProviderFor(rememberedAccount)
final rememberedAccountProvider = RememberedAccountProvider._();

/// 已记住的身份证号（登录页用于预填）。

final class RememberedAccountProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// 已记住的身份证号（登录页用于预填）。
  RememberedAccountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rememberedAccountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rememberedAccountHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return rememberedAccount(ref);
  }
}

String _$rememberedAccountHash() => r'6dad001b161addffcb01ec06f7aad321fea1a057';
