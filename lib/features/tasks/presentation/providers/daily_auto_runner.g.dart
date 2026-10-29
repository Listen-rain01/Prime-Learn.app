// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_auto_runner.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 积分轮询间隔（默认 10s）。
///
/// 独立成 provider 便于测试 override 成 `Duration.zero`，
/// 避免 notifier 暴露可变字段（riverpod_lint 要求 notifier 只通过 state 暴露 API）。

@ProviderFor(creditPollInterval)
final creditPollIntervalProvider = CreditPollIntervalProvider._();

/// 积分轮询间隔（默认 10s）。
///
/// 独立成 provider 便于测试 override 成 `Duration.zero`，
/// 避免 notifier 暴露可变字段（riverpod_lint 要求 notifier 只通过 state 暴露 API）。

final class CreditPollIntervalProvider
    extends $FunctionalProvider<Duration, Duration, Duration>
    with $Provider<Duration> {
  /// 积分轮询间隔（默认 10s）。
  ///
  /// 独立成 provider 便于测试 override 成 `Duration.zero`，
  /// 避免 notifier 暴露可变字段（riverpod_lint 要求 notifier 只通过 state 暴露 API）。
  CreditPollIntervalProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'creditPollIntervalProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$creditPollIntervalHash();

  @$internal
  @override
  $ProviderElement<Duration> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Duration create(Ref ref) {
    return creditPollInterval(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Duration value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Duration>(value),
    );
  }
}

String _$creditPollIntervalHash() =>
    r'6836a36289486a34e8dfd5e87a838b71917959cc';

/// 积分轮询次数（默认 9 次，配合 10s 间隔即 90s 窗口）。

@ProviderFor(creditPollCount)
final creditPollCountProvider = CreditPollCountProvider._();

/// 积分轮询次数（默认 9 次，配合 10s 间隔即 90s 窗口）。

final class CreditPollCountProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// 积分轮询次数（默认 9 次，配合 10s 间隔即 90s 窗口）。
  CreditPollCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'creditPollCountProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$creditPollCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return creditPollCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$creditPollCountHash() => r'db0e18517ca890191d54d75603ea2f2a655837cf';

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

String _$dailyAutoRunnerHash() => r'7db88b47a6b3dfa4cda0dfb868db2839cefe05c4';

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
