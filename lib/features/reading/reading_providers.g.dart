// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 阅读 API。

@ProviderFor(readingApi)
final readingApiProvider = ReadingApiProvider._();

/// 阅读 API。

final class ReadingApiProvider
    extends $FunctionalProvider<ReadingApi, ReadingApi, ReadingApi>
    with $Provider<ReadingApi> {
  /// 阅读 API。
  ReadingApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: noProviderRetry,
        name: r'readingApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readingApiHash();

  @$internal
  @override
  $ProviderElement<ReadingApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReadingApi create(Ref ref) {
    return readingApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReadingApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReadingApi>(value),
    );
  }
}

String _$readingApiHash() => r'6a3bcbdf44146551c58ad467f4cdd673e710208a';

/// 阅读仓库。

@ProviderFor(readingRepository)
final readingRepositoryProvider = ReadingRepositoryProvider._();

/// 阅读仓库。

final class ReadingRepositoryProvider
    extends
        $FunctionalProvider<
          ReadingRepository,
          ReadingRepository,
          ReadingRepository
        >
    with $Provider<ReadingRepository> {
  /// 阅读仓库。
  ReadingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: noProviderRetry,
        name: r'readingRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readingRepositoryHash();

  @$internal
  @override
  $ProviderElement<ReadingRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReadingRepository create(Ref ref) {
    return readingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReadingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReadingRepository>(value),
    );
  }
}

String _$readingRepositoryHash() => r'44099fad664a4c2d35e64a68eab1bfb98edd583f';

/// 阅读预设依赖的本地偏好。

@ProviderFor(readingPreferences)
final readingPreferencesProvider = ReadingPreferencesProvider._();

/// 阅读预设依赖的本地偏好。

final class ReadingPreferencesProvider
    extends
        $FunctionalProvider<
          AsyncValue<SharedPreferences>,
          SharedPreferences,
          FutureOr<SharedPreferences>
        >
    with
        $FutureModifier<SharedPreferences>,
        $FutureProvider<SharedPreferences> {
  /// 阅读预设依赖的本地偏好。
  ReadingPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: noProviderRetry,
        name: r'readingPreferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readingPreferencesHash();

  @$internal
  @override
  $FutureProviderElement<SharedPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SharedPreferences> create(Ref ref) {
    return readingPreferences(ref);
  }
}

String _$readingPreferencesHash() =>
    r'94252a11989d59d7492ad59486298c9dd6d1d144';

/// 阅读预设存储。

@ProviderFor(readingPresetStore)
final readingPresetStoreProvider = ReadingPresetStoreProvider._();

/// 阅读预设存储。

final class ReadingPresetStoreProvider
    extends
        $FunctionalProvider<
          AsyncValue<ReadingPresetStore>,
          ReadingPresetStore,
          FutureOr<ReadingPresetStore>
        >
    with
        $FutureModifier<ReadingPresetStore>,
        $FutureProvider<ReadingPresetStore> {
  /// 阅读预设存储。
  ReadingPresetStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: noProviderRetry,
        name: r'readingPresetStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readingPresetStoreHash();

  @$internal
  @override
  $FutureProviderElement<ReadingPresetStore> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ReadingPresetStore> create(Ref ref) {
    return readingPresetStore(ref);
  }
}

String _$readingPresetStoreHash() =>
    r'5a0a59c09d6ac437cfd0f799bc4a41b0e16af96e';

/// 阅读预设仓库。

@ProviderFor(readingPresetRepository)
final readingPresetRepositoryProvider = ReadingPresetRepositoryProvider._();

/// 阅读预设仓库。

final class ReadingPresetRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<ReadingPresetRepository>,
          ReadingPresetRepository,
          FutureOr<ReadingPresetRepository>
        >
    with
        $FutureModifier<ReadingPresetRepository>,
        $FutureProvider<ReadingPresetRepository> {
  /// 阅读预设仓库。
  ReadingPresetRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: noProviderRetry,
        name: r'readingPresetRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readingPresetRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<ReadingPresetRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ReadingPresetRepository> create(Ref ref) {
    return readingPresetRepository(ref);
  }
}

String _$readingPresetRepositoryHash() =>
    r'cbe72af9e2227c247a881be1b0d4bbf2731a7f8b';

/// 当前阅读预设。

@ProviderFor(readingPreset)
final readingPresetProvider = ReadingPresetProvider._();

/// 当前阅读预设。

final class ReadingPresetProvider
    extends
        $FunctionalProvider<
          AsyncValue<ReadingPreset?>,
          ReadingPreset?,
          FutureOr<ReadingPreset?>
        >
    with $FutureModifier<ReadingPreset?>, $FutureProvider<ReadingPreset?> {
  /// 当前阅读预设。
  ReadingPresetProvider._()
    : super(
        from: null,
        argument: null,
        retry: noProviderRetry,
        name: r'readingPresetProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readingPresetHash();

  @$internal
  @override
  $FutureProviderElement<ReadingPreset?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ReadingPreset?> create(Ref ref) {
    return readingPreset(ref);
  }
}

String _$readingPresetHash() => r'd4d5bcaf786622b36bb346425515dc89459591c8';

/// 保存阅读预设用例。

@ProviderFor(saveReadingPreset)
final saveReadingPresetProvider = SaveReadingPresetProvider._();

/// 保存阅读预设用例。

final class SaveReadingPresetProvider
    extends
        $FunctionalProvider<
          AsyncValue<SaveReadingPreset>,
          SaveReadingPreset,
          FutureOr<SaveReadingPreset>
        >
    with
        $FutureModifier<SaveReadingPreset>,
        $FutureProvider<SaveReadingPreset> {
  /// 保存阅读预设用例。
  SaveReadingPresetProvider._()
    : super(
        from: null,
        argument: null,
        retry: noProviderRetry,
        name: r'saveReadingPresetProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saveReadingPresetHash();

  @$internal
  @override
  $FutureProviderElement<SaveReadingPreset> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SaveReadingPreset> create(Ref ref) {
    return saveReadingPreset(ref);
  }
}

String _$saveReadingPresetHash() => r'7192a4c609a5c8d659d3d8a33c19da62be475517';

/// 完成阅读用例。

@ProviderFor(completeReading)
final completeReadingProvider = CompleteReadingProvider._();

/// 完成阅读用例。

final class CompleteReadingProvider
    extends
        $FunctionalProvider<CompleteReading, CompleteReading, CompleteReading>
    with $Provider<CompleteReading> {
  /// 完成阅读用例。
  CompleteReadingProvider._()
    : super(
        from: null,
        argument: null,
        retry: noProviderRetry,
        name: r'completeReadingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$completeReadingHash();

  @$internal
  @override
  $ProviderElement<CompleteReading> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CompleteReading create(Ref ref) {
    return completeReading(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CompleteReading value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CompleteReading>(value),
    );
  }
}

String _$completeReadingHash() => r'8d2d0e9adb2f96f6a30c959f208769d5e64b913a';

/// 一级分类。

@ProviderFor(readingCategories)
final readingCategoriesProvider = ReadingCategoriesProvider._();

/// 一级分类。

final class ReadingCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ReadingCategory>>,
          List<ReadingCategory>,
          FutureOr<List<ReadingCategory>>
        >
    with
        $FutureModifier<List<ReadingCategory>>,
        $FutureProvider<List<ReadingCategory>> {
  /// 一级分类。
  ReadingCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: noProviderRetry,
        name: r'readingCategoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readingCategoriesHash();

  @$internal
  @override
  $FutureProviderElement<List<ReadingCategory>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ReadingCategory>> create(Ref ref) {
    return readingCategories(ref);
  }
}

String _$readingCategoriesHash() => r'efdab5ac826d221aa0e3765fe170c819a0fe0095';

/// 子分类。

@ProviderFor(readingChildren)
final readingChildrenProvider = ReadingChildrenFamily._();

/// 子分类。

final class ReadingChildrenProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ReadingCategory>>,
          List<ReadingCategory>,
          FutureOr<List<ReadingCategory>>
        >
    with
        $FutureModifier<List<ReadingCategory>>,
        $FutureProvider<List<ReadingCategory>> {
  /// 子分类。
  ReadingChildrenProvider._({
    required ReadingChildrenFamily super.from,
    required ReadingChildQuery super.argument,
  }) : super(
         retry: noProviderRetry,
         name: r'readingChildrenProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$readingChildrenHash();

  @override
  String toString() {
    return r'readingChildrenProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ReadingCategory>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ReadingCategory>> create(Ref ref) {
    final argument = this.argument as ReadingChildQuery;
    return readingChildren(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ReadingChildrenProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$readingChildrenHash() => r'a89e2253af2fc738d121f2b33d388ce185ef18ca';

/// 子分类。

final class ReadingChildrenFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<ReadingCategory>>,
          ReadingChildQuery
        > {
  ReadingChildrenFamily._()
    : super(
        retry: noProviderRetry,
        name: r'readingChildrenProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 子分类。

  ReadingChildrenProvider call(ReadingChildQuery query) =>
      ReadingChildrenProvider._(argument: query, from: this);

  @override
  String toString() => r'readingChildrenProvider';
}

/// 分类下的文章。

@ProviderFor(readingArticles)
final readingArticlesProvider = ReadingArticlesFamily._();

/// 分类下的文章。

final class ReadingArticlesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ReadingArticle>>,
          List<ReadingArticle>,
          FutureOr<List<ReadingArticle>>
        >
    with
        $FutureModifier<List<ReadingArticle>>,
        $FutureProvider<List<ReadingArticle>> {
  /// 分类下的文章。
  ReadingArticlesProvider._({
    required ReadingArticlesFamily super.from,
    required String super.argument,
  }) : super(
         retry: noProviderRetry,
         name: r'readingArticlesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$readingArticlesHash();

  @override
  String toString() {
    return r'readingArticlesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ReadingArticle>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ReadingArticle>> create(Ref ref) {
    final argument = this.argument as String;
    return readingArticles(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ReadingArticlesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$readingArticlesHash() => r'1c6489f33aea7e50a6ea16b7aa86ed22c76ac1a2';

/// 分类下的文章。

final class ReadingArticlesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<ReadingArticle>>, String> {
  ReadingArticlesFamily._()
    : super(
        retry: noProviderRetry,
        name: r'readingArticlesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 分类下的文章。

  ReadingArticlesProvider call(String typeId) =>
      ReadingArticlesProvider._(argument: typeId, from: this);

  @override
  String toString() => r'readingArticlesProvider';
}
