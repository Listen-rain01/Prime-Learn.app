// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_auto_runner.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 一键完成今日任务：模拟考试 → 手机考试 → 签到 → 知识学习。
///
/// 每步执行前/失败后都会回查今日任务，已完成则跳过；写失败后不盲目重试。

@ProviderFor(DailyAutoRunner)
final dailyAutoRunnerProvider = DailyAutoRunnerProvider._();

/// 一键完成今日任务：模拟考试 → 手机考试 → 签到 → 知识学习。
///
/// 每步执行前/失败后都会回查今日任务，已完成则跳过；写失败后不盲目重试。
final class DailyAutoRunnerProvider
    extends $NotifierProvider<DailyAutoRunner, List<AutoTaskProgress>> {
  /// 一键完成今日任务：模拟考试 → 手机考试 → 签到 → 知识学习。
  ///
  /// 每步执行前/失败后都会回查今日任务，已完成则跳过；写失败后不盲目重试。
  DailyAutoRunnerProvider._()
    : super(
        from: null,
        argument: null,
        retry: noProviderRetry,
        name: r'dailyAutoRunnerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dailyAutoRunnerHash();

  @$internal
  @override
  DailyAutoRunner create() => DailyAutoRunner();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<AutoTaskProgress> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<AutoTaskProgress>>(value),
    );
  }
}

String _$dailyAutoRunnerHash() => r'81cee5aebfd8d279eaedd4be13923595fa29fc9b';

/// 一键完成今日任务：模拟考试 → 手机考试 → 签到 → 知识学习。
///
/// 每步执行前/失败后都会回查今日任务，已完成则跳过；写失败后不盲目重试。

abstract class _$DailyAutoRunner extends $Notifier<List<AutoTaskProgress>> {
  List<AutoTaskProgress> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<List<AutoTaskProgress>, List<AutoTaskProgress>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<AutoTaskProgress>, List<AutoTaskProgress>>,
              List<AutoTaskProgress>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
