// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 设置 API 实例。

@ProviderFor(settingsApi)
final settingsApiProvider = SettingsApiProvider._();

/// 设置 API 实例。

final class SettingsApiProvider
    extends $FunctionalProvider<SettingsApi, SettingsApi, SettingsApi>
    with $Provider<SettingsApi> {
  /// 设置 API 实例。
  SettingsApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsApiHash();

  @$internal
  @override
  $ProviderElement<SettingsApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SettingsApi create(Ref ref) {
    return settingsApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsApi>(value),
    );
  }
}

String _$settingsApiHash() => r'05b262e4bd9fe564f407cef4cf65fac75759dae5';

/// 设置仓储实例。

@ProviderFor(settingsRepository)
final settingsRepositoryProvider = SettingsRepositoryProvider._();

/// 设置仓储实例。

final class SettingsRepositoryProvider
    extends
        $FunctionalProvider<
          SettingsRepository,
          SettingsRepository,
          SettingsRepository
        >
    with $Provider<SettingsRepository> {
  /// 设置仓储实例。
  SettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<SettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SettingsRepository create(Ref ref) {
    return settingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsRepository>(value),
    );
  }
}

String _$settingsRepositoryHash() =>
    r'db72820aa7beb66134ba8e3c55b42e98503ddf69';

/// 加载积分规则用例。

@ProviderFor(loadRules)
final loadRulesProvider = LoadRulesProvider._();

/// 加载积分规则用例。

final class LoadRulesProvider
    extends $FunctionalProvider<LoadRules, LoadRules, LoadRules>
    with $Provider<LoadRules> {
  /// 加载积分规则用例。
  LoadRulesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loadRulesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loadRulesHash();

  @$internal
  @override
  $ProviderElement<LoadRules> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LoadRules create(Ref ref) {
    return loadRules(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoadRules value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoadRules>(value),
    );
  }
}

String _$loadRulesHash() => r'521582029403aa792d39e0cc2d6cf7564c367561';

/// 积分规则纯文本。

@ProviderFor(rulesText)
final rulesTextProvider = RulesTextProvider._();

/// 积分规则纯文本。

final class RulesTextProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// 积分规则纯文本。
  RulesTextProvider._()
    : super(
        from: null,
        argument: null,
        retry: noProviderRetry,
        name: r'rulesTextProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rulesTextHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return rulesText(ref);
  }
}

String _$rulesTextHash() => r'd369777845b28aee9a44a850ae3ab6406176c902';
