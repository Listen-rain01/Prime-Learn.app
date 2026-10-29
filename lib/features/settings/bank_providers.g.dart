// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bank_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 本地偏好实例。

@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = SharedPreferencesProvider._();

/// 本地偏好实例。

final class SharedPreferencesProvider
    extends
        $FunctionalProvider<
          AsyncValue<SharedPreferences>,
          SharedPreferences,
          FutureOr<SharedPreferences>
        >
    with
        $FutureModifier<SharedPreferences>,
        $FutureProvider<SharedPreferences> {
  /// 本地偏好实例。
  SharedPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedPreferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedPreferencesHash();

  @$internal
  @override
  $FutureProviderElement<SharedPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SharedPreferences> create(Ref ref) {
    return sharedPreferences(ref);
  }
}

String _$sharedPreferencesHash() => r'ad13470fe866595ad0f58a3e26f11048d94ef22e';

/// 题库 API 实例。

@ProviderFor(bankApi)
final bankApiProvider = BankApiProvider._();

/// 题库 API 实例。

final class BankApiProvider
    extends $FunctionalProvider<BankApi, BankApi, BankApi>
    with $Provider<BankApi> {
  /// 题库 API 实例。
  BankApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bankApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bankApiHash();

  @$internal
  @override
  $ProviderElement<BankApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BankApi create(Ref ref) {
    return bankApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BankApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BankApi>(value),
    );
  }
}

String _$bankApiHash() => r'2730fdcc942303d980150f553e137725858281e3';

/// 题库仓储实例。

@ProviderFor(bankRepository)
final bankRepositoryProvider = BankRepositoryProvider._();

/// 题库仓储实例。

final class BankRepositoryProvider
    extends $FunctionalProvider<BankRepository, BankRepository, BankRepository>
    with $Provider<BankRepository> {
  /// 题库仓储实例。
  BankRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bankRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bankRepositoryHash();

  @$internal
  @override
  $ProviderElement<BankRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BankRepository create(Ref ref) {
    return bankRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BankRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BankRepository>(value),
    );
  }
}

String _$bankRepositoryHash() => r'3beccab61ff3a44f2361f5e9dd84fc9d5347bcd3';

/// 题库预设存储（底层偏好）。

@ProviderFor(bankPresetStore)
final bankPresetStoreProvider = BankPresetStoreProvider._();

/// 题库预设存储（底层偏好）。

final class BankPresetStoreProvider
    extends
        $FunctionalProvider<
          AsyncValue<BankPresetStore>,
          BankPresetStore,
          FutureOr<BankPresetStore>
        >
    with $FutureModifier<BankPresetStore>, $FutureProvider<BankPresetStore> {
  /// 题库预设存储（底层偏好）。
  BankPresetStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bankPresetStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bankPresetStoreHash();

  @$internal
  @override
  $FutureProviderElement<BankPresetStore> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BankPresetStore> create(Ref ref) {
    return bankPresetStore(ref);
  }
}

String _$bankPresetStoreHash() => r'34d3c27194586758d3aab6cc627b364f6c8d3fa6';

/// 题库预设仓储。

@ProviderFor(bankPresetRepository)
final bankPresetRepositoryProvider = BankPresetRepositoryProvider._();

/// 题库预设仓储。

final class BankPresetRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<BankPresetRepository>,
          BankPresetRepository,
          FutureOr<BankPresetRepository>
        >
    with
        $FutureModifier<BankPresetRepository>,
        $FutureProvider<BankPresetRepository> {
  /// 题库预设仓储。
  BankPresetRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bankPresetRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bankPresetRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<BankPresetRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BankPresetRepository> create(Ref ref) {
    return bankPresetRepository(ref);
  }
}

String _$bankPresetRepositoryHash() =>
    r'b9092facf47141da5648d127f23674e1f42b89a9';

/// 当前预设；未设置时为 null。
///
/// 常驻：`DailyAutoRunner` 是 keepAlive，读取常驻 provider 才符合
/// riverpod_lint 的 `only_use_keep_alive_inside_keep_alive`；
/// 且这里只是读本地偏好，没有需要随页面释放的资源。

@ProviderFor(bankPreset)
final bankPresetProvider = BankPresetProvider._();

/// 当前预设；未设置时为 null。
///
/// 常驻：`DailyAutoRunner` 是 keepAlive，读取常驻 provider 才符合
/// riverpod_lint 的 `only_use_keep_alive_inside_keep_alive`；
/// 且这里只是读本地偏好，没有需要随页面释放的资源。

final class BankPresetProvider
    extends
        $FunctionalProvider<
          AsyncValue<BankPreset?>,
          BankPreset?,
          FutureOr<BankPreset?>
        >
    with $FutureModifier<BankPreset?>, $FutureProvider<BankPreset?> {
  /// 当前预设；未设置时为 null。
  ///
  /// 常驻：`DailyAutoRunner` 是 keepAlive，读取常驻 provider 才符合
  /// riverpod_lint 的 `only_use_keep_alive_inside_keep_alive`；
  /// 且这里只是读本地偏好，没有需要随页面释放的资源。
  BankPresetProvider._()
    : super(
        from: null,
        argument: null,
        retry: noProviderRetry,
        name: r'bankPresetProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bankPresetHash();

  @$internal
  @override
  $FutureProviderElement<BankPreset?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BankPreset?> create(Ref ref) {
    return bankPreset(ref);
  }
}

String _$bankPresetHash() => r'365d7e093c74c8f5711e12376ffe050e9cf021fa';

/// 保存预设（先校验可考试卷）。

@ProviderFor(saveBankPreset)
final saveBankPresetProvider = SaveBankPresetProvider._();

/// 保存预设（先校验可考试卷）。

final class SaveBankPresetProvider
    extends
        $FunctionalProvider<
          AsyncValue<SaveBankPreset>,
          SaveBankPreset,
          FutureOr<SaveBankPreset>
        >
    with $FutureModifier<SaveBankPreset>, $FutureProvider<SaveBankPreset> {
  /// 保存预设（先校验可考试卷）。
  SaveBankPresetProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saveBankPresetProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saveBankPresetHash();

  @$internal
  @override
  $FutureProviderElement<SaveBankPreset> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SaveBankPreset> create(Ref ref) {
    return saveBankPreset(ref);
  }
}

String _$saveBankPresetHash() => r'b54fcbd5e0d22b5b4c06d312b4528ee9bb8314ce';

/// 执行前的题库对齐用例。

@ProviderFor(ensureBankPreset)
final ensureBankPresetProvider = EnsureBankPresetProvider._();

/// 执行前的题库对齐用例。

final class EnsureBankPresetProvider
    extends
        $FunctionalProvider<
          EnsureBankPreset,
          EnsureBankPreset,
          EnsureBankPreset
        >
    with $Provider<EnsureBankPreset> {
  /// 执行前的题库对齐用例。
  EnsureBankPresetProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ensureBankPresetProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ensureBankPresetHash();

  @$internal
  @override
  $ProviderElement<EnsureBankPreset> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  EnsureBankPreset create(Ref ref) {
    return ensureBankPreset(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EnsureBankPreset value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EnsureBankPreset>(value),
    );
  }
}

String _$ensureBankPresetHash() => r'ec4919b35717426bc400d10dc93136b632aa5c0f';

/// 单位列表。

@ProviderFor(bankUnits)
final bankUnitsProvider = BankUnitsProvider._();

/// 单位列表。

final class BankUnitsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BankUnit>>,
          List<BankUnit>,
          FutureOr<List<BankUnit>>
        >
    with $FutureModifier<List<BankUnit>>, $FutureProvider<List<BankUnit>> {
  /// 单位列表。
  BankUnitsProvider._()
    : super(
        from: null,
        argument: null,
        retry: noProviderRetry,
        name: r'bankUnitsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bankUnitsHash();

  @$internal
  @override
  $FutureProviderElement<List<BankUnit>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BankUnit>> create(Ref ref) {
    return bankUnits(ref);
  }
}

String _$bankUnitsHash() => r'2332e1c6677d865620c9698b011958499699053d';

/// 大类列表。

@ProviderFor(bankStyles)
final bankStylesProvider = BankStylesFamily._();

/// 大类列表。

final class BankStylesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BankStyle>>,
          List<BankStyle>,
          FutureOr<List<BankStyle>>
        >
    with $FutureModifier<List<BankStyle>>, $FutureProvider<List<BankStyle>> {
  /// 大类列表。
  BankStylesProvider._({
    required BankStylesFamily super.from,
    required String super.argument,
  }) : super(
         retry: noProviderRetry,
         name: r'bankStylesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bankStylesHash();

  @override
  String toString() {
    return r'bankStylesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<BankStyle>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BankStyle>> create(Ref ref) {
    final argument = this.argument as String;
    return bankStyles(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BankStylesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bankStylesHash() => r'1a07e4dd8c5f05ba9893dea06b2f3a1ec97e02d5';

/// 大类列表。

final class BankStylesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<BankStyle>>, String> {
  BankStylesFamily._()
    : super(
        retry: noProviderRetry,
        name: r'bankStylesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 大类列表。

  BankStylesProvider call(String unitId) =>
      BankStylesProvider._(argument: unitId, from: this);

  @override
  String toString() => r'bankStylesProvider';
}

/// 子分类列表。

@ProviderFor(bankChildren)
final bankChildrenProvider = BankChildrenFamily._();

/// 子分类列表。

final class BankChildrenProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BankStyle>>,
          List<BankStyle>,
          FutureOr<List<BankStyle>>
        >
    with $FutureModifier<List<BankStyle>>, $FutureProvider<List<BankStyle>> {
  /// 子分类列表。
  BankChildrenProvider._({
    required BankChildrenFamily super.from,
    required BankChildQuery super.argument,
  }) : super(
         retry: noProviderRetry,
         name: r'bankChildrenProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bankChildrenHash();

  @override
  String toString() {
    return r'bankChildrenProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<BankStyle>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BankStyle>> create(Ref ref) {
    final argument = this.argument as BankChildQuery;
    return bankChildren(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BankChildrenProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bankChildrenHash() => r'09493c8aef467e0b086b9907c68dd61653ec4634';

/// 子分类列表。

final class BankChildrenFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<BankStyle>>, BankChildQuery> {
  BankChildrenFamily._()
    : super(
        retry: noProviderRetry,
        name: r'bankChildrenProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 子分类列表。

  BankChildrenProvider call(BankChildQuery query) =>
      BankChildrenProvider._(argument: query, from: this);

  @override
  String toString() => r'bankChildrenProvider';
}

/// 题库列表。

@ProviderFor(bankOptions)
final bankOptionsProvider = BankOptionsFamily._();

/// 题库列表。

final class BankOptionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BankOption>>,
          List<BankOption>,
          FutureOr<List<BankOption>>
        >
    with $FutureModifier<List<BankOption>>, $FutureProvider<List<BankOption>> {
  /// 题库列表。
  BankOptionsProvider._({
    required BankOptionsFamily super.from,
    required BankOptionQuery super.argument,
  }) : super(
         retry: noProviderRetry,
         name: r'bankOptionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bankOptionsHash();

  @override
  String toString() {
    return r'bankOptionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<BankOption>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BankOption>> create(Ref ref) {
    final argument = this.argument as BankOptionQuery;
    return bankOptions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BankOptionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bankOptionsHash() => r'76f1d12e5485556e000ec33332e2d1cba71411cf';

/// 题库列表。

final class BankOptionsFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<List<BankOption>>, BankOptionQuery> {
  BankOptionsFamily._()
    : super(
        retry: noProviderRetry,
        name: r'bankOptionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 题库列表。

  BankOptionsProvider call(BankOptionQuery query) =>
      BankOptionsProvider._(argument: query, from: this);

  @override
  String toString() => r'bankOptionsProvider';
}
