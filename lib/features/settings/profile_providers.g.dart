// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 个人信息 API 实例。

@ProviderFor(profileApi)
final profileApiProvider = ProfileApiProvider._();

/// 个人信息 API 实例。

final class ProfileApiProvider
    extends $FunctionalProvider<ProfileApi, ProfileApi, ProfileApi>
    with $Provider<ProfileApi> {
  /// 个人信息 API 实例。
  ProfileApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileApiHash();

  @$internal
  @override
  $ProviderElement<ProfileApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ProfileApi create(Ref ref) {
    return profileApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileApi>(value),
    );
  }
}

String _$profileApiHash() => r'47cb55a2247bdda351f080a16d50899146c0e3c3';

/// 个人信息仓储实例。

@ProviderFor(profileRepository)
final profileRepositoryProvider = ProfileRepositoryProvider._();

/// 个人信息仓储实例。

final class ProfileRepositoryProvider
    extends
        $FunctionalProvider<
          ProfileRepository,
          ProfileRepository,
          ProfileRepository
        >
    with $Provider<ProfileRepository> {
  /// 个人信息仓储实例。
  ProfileRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProfileRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProfileRepository create(Ref ref) {
    return profileRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileRepository>(value),
    );
  }
}

String _$profileRepositoryHash() => r'f0f6efc1e7b06b9f7dbe841ef7ab6e7179372179';

/// 加载个人信息用例。

@ProviderFor(loadProfile)
final loadProfileProvider = LoadProfileProvider._();

/// 加载个人信息用例。

final class LoadProfileProvider
    extends $FunctionalProvider<LoadProfile, LoadProfile, LoadProfile>
    with $Provider<LoadProfile> {
  /// 加载个人信息用例。
  LoadProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loadProfileProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loadProfileHash();

  @$internal
  @override
  $ProviderElement<LoadProfile> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LoadProfile create(Ref ref) {
    return loadProfile(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoadProfile value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoadProfile>(value),
    );
  }
}

String _$loadProfileHash() => r'59667611f07220ae02fcf21a409c200e9dc406a6';

/// 加载头像用例。

@ProviderFor(loadAvatar)
final loadAvatarProvider = LoadAvatarProvider._();

/// 加载头像用例。

final class LoadAvatarProvider
    extends $FunctionalProvider<LoadAvatar, LoadAvatar, LoadAvatar>
    with $Provider<LoadAvatar> {
  /// 加载头像用例。
  LoadAvatarProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loadAvatarProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loadAvatarHash();

  @$internal
  @override
  $ProviderElement<LoadAvatar> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LoadAvatar create(Ref ref) {
    return loadAvatar(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoadAvatar value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoadAvatar>(value),
    );
  }
}

String _$loadAvatarHash() => r'71f465f74d82f33071e7a13927e37dde0e09d70b';

/// 当前登录用户的个人信息；未登录时为 null。

@ProviderFor(personProfile)
final personProfileProvider = PersonProfileProvider._();

/// 当前登录用户的个人信息；未登录时为 null。

final class PersonProfileProvider
    extends
        $FunctionalProvider<
          AsyncValue<PersonProfile?>,
          PersonProfile?,
          FutureOr<PersonProfile?>
        >
    with $FutureModifier<PersonProfile?>, $FutureProvider<PersonProfile?> {
  /// 当前登录用户的个人信息；未登录时为 null。
  PersonProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: noProviderRetry,
        name: r'personProfileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$personProfileHash();

  @$internal
  @override
  $FutureProviderElement<PersonProfile?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PersonProfile?> create(Ref ref) {
    return personProfile(ref);
  }
}

String _$personProfileHash() => r'da24fa1e309e790943d59b95d589ba8e394e32cd';

/// 头像字节；与个人资料解耦，慢或失败都不阻塞资料展示。

@ProviderFor(profileAvatar)
final profileAvatarProvider = ProfileAvatarProvider._();

/// 头像字节；与个人资料解耦，慢或失败都不阻塞资料展示。

final class ProfileAvatarProvider
    extends
        $FunctionalProvider<
          AsyncValue<Uint8List?>,
          Uint8List?,
          FutureOr<Uint8List?>
        >
    with $FutureModifier<Uint8List?>, $FutureProvider<Uint8List?> {
  /// 头像字节；与个人资料解耦，慢或失败都不阻塞资料展示。
  ProfileAvatarProvider._()
    : super(
        from: null,
        argument: null,
        retry: noProviderRetry,
        name: r'profileAvatarProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileAvatarHash();

  @$internal
  @override
  $FutureProviderElement<Uint8List?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Uint8List?> create(Ref ref) {
    return profileAvatar(ref);
  }
}

String _$profileAvatarHash() => r'45363522b5e2d6a52b4dbbe3d77ff49816b42edf';
