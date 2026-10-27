// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_board_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 今日任务看板状态：登录态变化时自动重新加载。

@ProviderFor(DailyBoardNotifier)
final dailyBoardProvider = DailyBoardNotifierProvider._();

/// 今日任务看板状态：登录态变化时自动重新加载。
final class DailyBoardNotifierProvider
    extends $AsyncNotifierProvider<DailyBoardNotifier, TaskBoard> {
  /// 今日任务看板状态：登录态变化时自动重新加载。
  DailyBoardNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dailyBoardProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dailyBoardNotifierHash();

  @$internal
  @override
  DailyBoardNotifier create() => DailyBoardNotifier();
}

String _$dailyBoardNotifierHash() =>
    r'b3e5da8dbe57633482756a95c897191ce5842612';

/// 今日任务看板状态：登录态变化时自动重新加载。

abstract class _$DailyBoardNotifier extends $AsyncNotifier<TaskBoard> {
  FutureOr<TaskBoard> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<TaskBoard>, TaskBoard>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TaskBoard>, TaskBoard>,
              AsyncValue<TaskBoard>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
