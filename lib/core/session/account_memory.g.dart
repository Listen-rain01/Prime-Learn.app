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

/// 已记住的账号列表（登录页账号切换用）。

@ProviderFor(savedAccounts)
final savedAccountsProvider = SavedAccountsProvider._();

/// 已记住的账号列表（登录页账号切换用）。

final class SavedAccountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SavedAccount>>,
          List<SavedAccount>,
          FutureOr<List<SavedAccount>>
        >
    with
        $FutureModifier<List<SavedAccount>>,
        $FutureProvider<List<SavedAccount>> {
  /// 已记住的账号列表（登录页账号切换用）。
  SavedAccountsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedAccountsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedAccountsHash();

  @$internal
  @override
  $FutureProviderElement<List<SavedAccount>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SavedAccount>> create(Ref ref) {
    return savedAccounts(ref);
  }
}

String _$savedAccountsHash() => r'1bb0d56d392735a32de2dbb991eb0e9e89c0c98a';

/// 最近登录的账号（登录页预填）。

@ProviderFor(rememberedAccount)
final rememberedAccountProvider = RememberedAccountProvider._();

/// 最近登录的账号（登录页预填）。

final class RememberedAccountProvider
    extends
        $FunctionalProvider<
          AsyncValue<SavedAccount?>,
          SavedAccount?,
          FutureOr<SavedAccount?>
        >
    with $FutureModifier<SavedAccount?>, $FutureProvider<SavedAccount?> {
  /// 最近登录的账号（登录页预填）。
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
  $FutureProviderElement<SavedAccount?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SavedAccount?> create(Ref ref) {
    return rememberedAccount(ref);
  }
}

String _$rememberedAccountHash() => r'82227160a3a173339effe8c337066f33051ccd70';
