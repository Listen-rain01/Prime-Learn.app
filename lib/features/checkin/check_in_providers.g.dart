// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_in_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 签到 API 实例。

@ProviderFor(checkInApi)
final checkInApiProvider = CheckInApiProvider._();

/// 签到 API 实例。

final class CheckInApiProvider
    extends $FunctionalProvider<CheckInApi, CheckInApi, CheckInApi>
    with $Provider<CheckInApi> {
  /// 签到 API 实例。
  CheckInApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'checkInApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$checkInApiHash();

  @$internal
  @override
  $ProviderElement<CheckInApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CheckInApi create(Ref ref) {
    return checkInApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CheckInApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CheckInApi>(value),
    );
  }
}

String _$checkInApiHash() => r'a96da747292cef9be8bab30dc633f90d3dd000b2';

/// 签到仓储实例。

@ProviderFor(checkInRepository)
final checkInRepositoryProvider = CheckInRepositoryProvider._();

/// 签到仓储实例。

final class CheckInRepositoryProvider
    extends
        $FunctionalProvider<
          CheckInRepository,
          CheckInRepository,
          CheckInRepository
        >
    with $Provider<CheckInRepository> {
  /// 签到仓储实例。
  CheckInRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'checkInRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$checkInRepositoryHash();

  @$internal
  @override
  $ProviderElement<CheckInRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CheckInRepository create(Ref ref) {
    return checkInRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CheckInRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CheckInRepository>(value),
    );
  }
}

String _$checkInRepositoryHash() => r'34befb0439fc7ce18d75d4b4193aedfed11fd01a';

/// 执行签到用例。

@ProviderFor(performCheckIn)
final performCheckInProvider = PerformCheckInProvider._();

/// 执行签到用例。

final class PerformCheckInProvider
    extends $FunctionalProvider<PerformCheckIn, PerformCheckIn, PerformCheckIn>
    with $Provider<PerformCheckIn> {
  /// 执行签到用例。
  PerformCheckInProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'performCheckInProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$performCheckInHash();

  @$internal
  @override
  $ProviderElement<PerformCheckIn> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PerformCheckIn create(Ref ref) {
    return performCheckIn(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PerformCheckIn value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PerformCheckIn>(value),
    );
  }
}

String _$performCheckInHash() => r'fe9a50fa16aaf51d0c89f342f05036537d354bcb';

/// 签到状态：null 表示本次未操作。

@ProviderFor(CheckInController)
final checkInControllerProvider = CheckInControllerProvider._();

/// 签到状态：null 表示本次未操作。
final class CheckInControllerProvider
    extends $AsyncNotifierProvider<CheckInController, CheckInResult?> {
  /// 签到状态：null 表示本次未操作。
  CheckInControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: noProviderRetry,
        name: r'checkInControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$checkInControllerHash();

  @$internal
  @override
  CheckInController create() => CheckInController();
}

String _$checkInControllerHash() => r'b4dae8b8224765927b5d4bf2bc13fa7bb151c34b';

/// 签到状态：null 表示本次未操作。

abstract class _$CheckInController extends $AsyncNotifier<CheckInResult?> {
  FutureOr<CheckInResult?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<CheckInResult?>, CheckInResult?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CheckInResult?>, CheckInResult?>,
              AsyncValue<CheckInResult?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
