import 'package:primelearn/core/errors/no_retry.dart';
import 'package:primelearn/core/network/api_client.dart';
import 'package:primelearn/core/session/session_store.dart';
import 'package:primelearn/features/exam/data/repositories/exam_repository_impl.dart';
import 'package:primelearn/features/exam/data/services/exam_api.dart';
import 'package:primelearn/features/exam/domain/entities/exam_paper.dart';
import 'package:primelearn/features/exam/domain/repositories/exam_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'exam_providers.g.dart';

/// 考试 API 实例。
@Riverpod(keepAlive: true)
ExamApi examApi(Ref ref) => ExamApi(ref.watch(apiClientProvider));

/// 考试仓储实例。
@Riverpod(keepAlive: true)
ExamRepository examRepository(Ref ref) =>
    ExamRepositoryImpl(ref.watch(examApiProvider));

/// 某题库下的可考试卷。
@Riverpod(retry: noProviderRetry)
Future<List<ExamPaper>> examPapers(Ref ref, String bankId) async {
  final session = ref.watch(sessionStoreProvider);
  if (session == null) return const [];
  return ref
      .watch(examRepositoryProvider)
      .fetchPapers(userId: session.userId, bankId: bankId);
}

/// 某题库的可考试卷数量（用于选择题库时的可用性判断）。
@Riverpod(retry: noProviderRetry)
Future<int> bankPaperCount(Ref ref, String bankId) async =>
    (await ref.watch(examPapersProvider(bankId).future)).length;
