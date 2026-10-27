// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_memory.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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
