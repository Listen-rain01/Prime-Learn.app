// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'records_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 记录 API 实例。

@ProviderFor(recordsApi)
final recordsApiProvider = RecordsApiProvider._();

/// 记录 API 实例。

final class RecordsApiProvider
    extends $FunctionalProvider<RecordsApi, RecordsApi, RecordsApi>
    with $Provider<RecordsApi> {
  /// 记录 API 实例。
  RecordsApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recordsApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recordsApiHash();

  @$internal
  @override
  $ProviderElement<RecordsApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RecordsApi create(Ref ref) {
    return recordsApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecordsApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecordsApi>(value),
    );
  }
}

String _$recordsApiHash() => r'6637c9c85c699fcd4b4a2d7c32c078b4039b1ffc';

/// 记录仓储实例。

@ProviderFor(recordsRepository)
final recordsRepositoryProvider = RecordsRepositoryProvider._();

/// 记录仓储实例。

final class RecordsRepositoryProvider
    extends
        $FunctionalProvider<
          RecordsRepository,
          RecordsRepository,
          RecordsRepository
        >
    with $Provider<RecordsRepository> {
  /// 记录仓储实例。
  RecordsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recordsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recordsRepositoryHash();

  @$internal
  @override
  $ProviderElement<RecordsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RecordsRepository create(Ref ref) {
    return recordsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecordsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecordsRepository>(value),
    );
  }
}

String _$recordsRepositoryHash() => r'8e876f1975f540c4196109a847d26ba27a6b7cd5';

/// 加载考试记录用例。

@ProviderFor(loadExamRecords)
final loadExamRecordsProvider = LoadExamRecordsProvider._();

/// 加载考试记录用例。

final class LoadExamRecordsProvider
    extends
        $FunctionalProvider<LoadExamRecords, LoadExamRecords, LoadExamRecords>
    with $Provider<LoadExamRecords> {
  /// 加载考试记录用例。
  LoadExamRecordsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loadExamRecordsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loadExamRecordsHash();

  @$internal
  @override
  $ProviderElement<LoadExamRecords> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LoadExamRecords create(Ref ref) {
    return loadExamRecords(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoadExamRecords value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoadExamRecords>(value),
    );
  }
}

String _$loadExamRecordsHash() => r'acdf9b2a6dd71ea47df515761a79f800cdb21840';

/// 加载积分明细用例。

@ProviderFor(loadPointsLedger)
final loadPointsLedgerProvider = LoadPointsLedgerProvider._();

/// 加载积分明细用例。

final class LoadPointsLedgerProvider
    extends
        $FunctionalProvider<
          LoadPointsLedger,
          LoadPointsLedger,
          LoadPointsLedger
        >
    with $Provider<LoadPointsLedger> {
  /// 加载积分明细用例。
  LoadPointsLedgerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loadPointsLedgerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loadPointsLedgerHash();

  @$internal
  @override
  $ProviderElement<LoadPointsLedger> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LoadPointsLedger create(Ref ref) {
    return loadPointsLedger(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoadPointsLedger value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoadPointsLedger>(value),
    );
  }
}

String _$loadPointsLedgerHash() => r'a9582f630e17810296df2803c828ba133eb114c4';

/// 指定分类的考试记录。

@ProviderFor(examRecords)
final examRecordsProvider = ExamRecordsFamily._();

/// 指定分类的考试记录。

final class ExamRecordsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ExamRecord>>,
          List<ExamRecord>,
          FutureOr<List<ExamRecord>>
        >
    with $FutureModifier<List<ExamRecord>>, $FutureProvider<List<ExamRecord>> {
  /// 指定分类的考试记录。
  ExamRecordsProvider._({
    required ExamRecordsFamily super.from,
    required ExamRecordCategory super.argument,
  }) : super(
         retry: noProviderRetry,
         name: r'examRecordsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$examRecordsHash();

  @override
  String toString() {
    return r'examRecordsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ExamRecord>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ExamRecord>> create(Ref ref) {
    final argument = this.argument as ExamRecordCategory;
    return examRecords(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ExamRecordsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$examRecordsHash() => r'9ac5f12a147bd92f82b4f181d2aab4d4f81b0cf0';

/// 指定分类的考试记录。

final class ExamRecordsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<ExamRecord>>,
          ExamRecordCategory
        > {
  ExamRecordsFamily._()
    : super(
        retry: noProviderRetry,
        name: r'examRecordsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 指定分类的考试记录。

  ExamRecordsProvider call(ExamRecordCategory category) =>
      ExamRecordsProvider._(argument: category, from: this);

  @override
  String toString() => r'examRecordsProvider';
}

/// 积分明细。

@ProviderFor(pointsLedger)
final pointsLedgerProvider = PointsLedgerProvider._();

/// 积分明细。

final class PointsLedgerProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PointEntry>>,
          List<PointEntry>,
          FutureOr<List<PointEntry>>
        >
    with $FutureModifier<List<PointEntry>>, $FutureProvider<List<PointEntry>> {
  /// 积分明细。
  PointsLedgerProvider._()
    : super(
        from: null,
        argument: null,
        retry: noProviderRetry,
        name: r'pointsLedgerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pointsLedgerHash();

  @$internal
  @override
  $FutureProviderElement<List<PointEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PointEntry>> create(Ref ref) {
    return pointsLedger(ref);
  }
}

String _$pointsLedgerHash() => r'209906c8d8976e04840c80b0f9bf722c23102752';
