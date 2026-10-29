// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 登录页状态机：负责状态迁移，不碰网络细节。

@ProviderFor(LoginNotifier)
final loginProvider = LoginNotifierProvider._();

/// 登录页状态机：负责状态迁移，不碰网络细节。
final class LoginNotifierProvider
    extends $NotifierProvider<LoginNotifier, LoginState> {
  /// 登录页状态机：负责状态迁移，不碰网络细节。
  LoginNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loginProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loginNotifierHash();

  @$internal
  @override
  LoginNotifier create() => LoginNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoginState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoginState>(value),
    );
  }
}

String _$loginNotifierHash() => r'd8a266068a8e916065a2d0d7cee3f536d530eac4';

/// 登录页状态机：负责状态迁移，不碰网络细节。

abstract class _$LoginNotifier extends $Notifier<LoginState> {
  LoginState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<LoginState, LoginState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LoginState, LoginState>,
              LoginState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
