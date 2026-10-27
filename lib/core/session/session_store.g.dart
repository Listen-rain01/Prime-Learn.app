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
