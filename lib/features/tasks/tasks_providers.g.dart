// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tasks_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 今日任务 API 实例。

@ProviderFor(tasksApi)
final tasksApiProvider = TasksApiProvider._();

/// 今日任务 API 实例。

final class TasksApiProvider
    extends $FunctionalProvider<TasksApi, TasksApi, TasksApi>
    with $Provider<TasksApi> {
  /// 今日任务 API 实例。
  TasksApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tasksApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tasksApiHash();

  @$internal
  @override
  $ProviderElement<TasksApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TasksApi create(Ref ref) {
    return tasksApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TasksApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TasksApi>(value),
    );
  }
}

String _$tasksApiHash() => r'2c58bd3d56ef713289bf824a58fb869b604a6894';

/// 今日任务仓储实例。

@ProviderFor(tasksRepository)
final tasksRepositoryProvider = TasksRepositoryProvider._();

/// 今日任务仓储实例。

final class TasksRepositoryProvider
    extends
        $FunctionalProvider<TasksRepository, TasksRepository, TasksRepository>
    with $Provider<TasksRepository> {
  /// 今日任务仓储实例。
  TasksRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tasksRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tasksRepositoryHash();

  @$internal
  @override
  $ProviderElement<TasksRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TasksRepository create(Ref ref) {
    return tasksRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TasksRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TasksRepository>(value),
    );
  }
}

String _$tasksRepositoryHash() => r'589240d16051c0ed70637656bdf5bde3be3472e7';

/// 加载今日任务看板用例。

@ProviderFor(loadDailyBoard)
final loadDailyBoardProvider = LoadDailyBoardProvider._();

/// 加载今日任务看板用例。

final class LoadDailyBoardProvider
    extends $FunctionalProvider<LoadDailyBoard, LoadDailyBoard, LoadDailyBoard>
    with $Provider<LoadDailyBoard> {
  /// 加载今日任务看板用例。
  LoadDailyBoardProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loadDailyBoardProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loadDailyBoardHash();

  @$internal
  @override
  $ProviderElement<LoadDailyBoard> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LoadDailyBoard create(Ref ref) {
    return loadDailyBoard(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoadDailyBoard value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoadDailyBoard>(value),
    );
  }
}

String _$loadDailyBoardHash() => r'222cbbb9ce633f92dd743dc53af05c242b6f1036';
