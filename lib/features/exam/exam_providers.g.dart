// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 考试 API 实例。

@ProviderFor(examApi)
final examApiProvider = ExamApiProvider._();

/// 考试 API 实例。

final class ExamApiProvider
    extends $FunctionalProvider<ExamApi, ExamApi, ExamApi>
    with $Provider<ExamApi> {
  /// 考试 API 实例。
  ExamApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'examApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$examApiHash();

  @$internal
  @override
  $ProviderElement<ExamApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ExamApi create(Ref ref) {
    return examApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExamApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExamApi>(value),
    );
  }
}

String _$examApiHash() => r'9560c395dba9f3ac1f806dec313b5495be3736ef';

/// 考试仓储实例。

@ProviderFor(examRepository)
final examRepositoryProvider = ExamRepositoryProvider._();

/// 考试仓储实例。

final class ExamRepositoryProvider
    extends $FunctionalProvider<ExamRepository, ExamRepository, ExamRepository>
    with $Provider<ExamRepository> {
  /// 考试仓储实例。
  ExamRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'examRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$examRepositoryHash();

  @$internal
  @override
  $ProviderElement<ExamRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ExamRepository create(Ref ref) {
    return examRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExamRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExamRepository>(value),
    );
  }
}

String _$examRepositoryHash() => r'09f72f70953c8e34b82191db6e56c3145d576a89';

/// 某题库下的可考试卷。

@ProviderFor(examPapers)
final examPapersProvider = ExamPapersFamily._();

/// 某题库下的可考试卷。

final class ExamPapersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ExamPaper>>,
          List<ExamPaper>,
          FutureOr<List<ExamPaper>>
        >
    with $FutureModifier<List<ExamPaper>>, $FutureProvider<List<ExamPaper>> {
  /// 某题库下的可考试卷。
  ExamPapersProvider._({
    required ExamPapersFamily super.from,
    required String super.argument,
  }) : super(
         retry: noProviderRetry,
         name: r'examPapersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$examPapersHash();

  @override
  String toString() {
    return r'examPapersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ExamPaper>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ExamPaper>> create(Ref ref) {
    final argument = this.argument as String;
    return examPapers(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ExamPapersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$examPapersHash() => r'4635802896d7e5e777e4c9b2771686d3d4d9805c';

/// 某题库下的可考试卷。

final class ExamPapersFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<ExamPaper>>, String> {
  ExamPapersFamily._()
    : super(
        retry: noProviderRetry,
        name: r'examPapersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 某题库下的可考试卷。

  ExamPapersProvider call(String bankId) =>
      ExamPapersProvider._(argument: bankId, from: this);

  @override
  String toString() => r'examPapersProvider';
}
