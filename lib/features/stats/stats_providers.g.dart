// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 记录 API 实例。

@ProviderFor(statsApi)
final statsApiProvider = StatsApiProvider._();

/// 记录 API 实例。

final class StatsApiProvider
    extends $FunctionalProvider<StatsApi, StatsApi, StatsApi>
    with $Provider<StatsApi> {
  /// 记录 API 实例。
  StatsApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'statsApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$statsApiHash();

  @$internal
  @override
  $ProviderElement<StatsApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StatsApi create(Ref ref) {
    return statsApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StatsApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StatsApi>(value),
    );
  }
}

String _$statsApiHash() => r'db1ca67e645d88e0df385ea6c42a39615201d7fa';

/// 记录仓储实例。

@ProviderFor(statsRepository)
final statsRepositoryProvider = StatsRepositoryProvider._();

/// 记录仓储实例。

final class StatsRepositoryProvider
    extends
        $FunctionalProvider<StatsRepository, StatsRepository, StatsRepository>
    with $Provider<StatsRepository> {
  /// 记录仓储实例。
  StatsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'statsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$statsRepositoryHash();

  @$internal
  @override
  $ProviderElement<StatsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StatsRepository create(Ref ref) {
    return statsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StatsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StatsRepository>(value),
    );
  }
}

String _$statsRepositoryHash() => r'5d119f983efac4370d724039df545091ea7291af';

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

String _$loadExamRecordsHash() => r'a245add7ae57c762420270846fac0c386dc74bf3';

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

String _$loadPointsLedgerHash() => r'114b050256fe08b7a44944c78ba413957240979e';

/// 加载榜单用例。

@ProviderFor(loadRanking)
final loadRankingProvider = LoadRankingProvider._();

/// 加载榜单用例。

final class LoadRankingProvider
    extends $FunctionalProvider<LoadRanking, LoadRanking, LoadRanking>
    with $Provider<LoadRanking> {
  /// 加载榜单用例。
  LoadRankingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loadRankingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loadRankingHash();

  @$internal
  @override
  $ProviderElement<LoadRanking> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LoadRanking create(Ref ref) {
    return loadRanking(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoadRanking value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoadRanking>(value),
    );
  }
}

String _$loadRankingHash() => r'8abbcbeb5ea55a84a3acd14faf2bc3a3351c4db3';

/// 加载成绩趋势用例。

@ProviderFor(loadScoreTrend)
final loadScoreTrendProvider = LoadScoreTrendProvider._();

/// 加载成绩趋势用例。

final class LoadScoreTrendProvider
    extends $FunctionalProvider<LoadScoreTrend, LoadScoreTrend, LoadScoreTrend>
    with $Provider<LoadScoreTrend> {
  /// 加载成绩趋势用例。
  LoadScoreTrendProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loadScoreTrendProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loadScoreTrendHash();

  @$internal
  @override
  $ProviderElement<LoadScoreTrend> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LoadScoreTrend create(Ref ref) {
    return loadScoreTrend(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoadScoreTrend value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoadScoreTrend>(value),
    );
  }
}

String _$loadScoreTrendHash() => r'0f348a1a6fd774f931f986b472622a1f912c0220';

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

/// 榜单。

@ProviderFor(ranking)
final rankingProvider = RankingFamily._();

/// 榜单。

final class RankingProvider
    extends
        $FunctionalProvider<
          AsyncValue<RankingBoard>,
          RankingBoard,
          FutureOr<RankingBoard>
        >
    with $FutureModifier<RankingBoard>, $FutureProvider<RankingBoard> {
  /// 榜单。
  RankingProvider._({
    required RankingFamily super.from,
    required RankingQuery super.argument,
  }) : super(
         retry: noProviderRetry,
         name: r'rankingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$rankingHash();

  @override
  String toString() {
    return r'rankingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<RankingBoard> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<RankingBoard> create(Ref ref) {
    final argument = this.argument as RankingQuery;
    return ranking(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RankingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$rankingHash() => r'c3c7baf3f9c5cd012237cd6c9fe15972e755bcbc';

/// 榜单。

final class RankingFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<RankingBoard>, RankingQuery> {
  RankingFamily._()
    : super(
        retry: noProviderRetry,
        name: r'rankingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 榜单。

  RankingProvider call(RankingQuery query) =>
      RankingProvider._(argument: query, from: this);

  @override
  String toString() => r'rankingProvider';
}

/// 个人成绩趋势。

@ProviderFor(scoreTrend)
final scoreTrendProvider = ScoreTrendProvider._();

/// 个人成绩趋势。

final class ScoreTrendProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ScoreTrendPoint>>,
          List<ScoreTrendPoint>,
          FutureOr<List<ScoreTrendPoint>>
        >
    with
        $FutureModifier<List<ScoreTrendPoint>>,
        $FutureProvider<List<ScoreTrendPoint>> {
  /// 个人成绩趋势。
  ScoreTrendProvider._()
    : super(
        from: null,
        argument: null,
        retry: noProviderRetry,
        name: r'scoreTrendProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scoreTrendHash();

  @$internal
  @override
  $FutureProviderElement<List<ScoreTrendPoint>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ScoreTrendPoint>> create(Ref ref) {
    return scoreTrend(ref);
  }
}

String _$scoreTrendHash() => r'92ef755a17ddcc3f5e07f95988f8a3b1ce9e00df';
