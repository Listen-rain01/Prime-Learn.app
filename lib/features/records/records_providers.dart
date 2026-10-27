import 'package:primelearn/core/errors/no_retry.dart';
import 'package:primelearn/core/network/api_client.dart';
import 'package:primelearn/core/session/session_store.dart';
import 'package:primelearn/features/records/application/load_exam_records.dart';
import 'package:primelearn/features/records/application/load_points_ledger.dart';
import 'package:primelearn/features/records/data/repositories/records_repository_impl.dart';
import 'package:primelearn/features/records/data/services/records_api.dart';
import 'package:primelearn/features/records/domain/entities/exam_record.dart';
import 'package:primelearn/features/records/domain/entities/point_entry.dart';
import 'package:primelearn/features/records/domain/repositories/records_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'records_providers.g.dart';

/// 记录 API 实例。
@Riverpod(keepAlive: true)
RecordsApi recordsApi(Ref ref) => RecordsApi(ref.watch(apiClientProvider));

/// 记录仓储实例。
@Riverpod(keepAlive: true)
RecordsRepository recordsRepository(Ref ref) =>
    RecordsRepositoryImpl(ref.watch(recordsApiProvider));

/// 加载考试记录用例。
@Riverpod(keepAlive: true)
LoadExamRecords loadExamRecords(Ref ref) =>
    LoadExamRecords(ref.watch(recordsRepositoryProvider));

/// 加载积分明细用例。
@Riverpod(keepAlive: true)
LoadPointsLedger loadPointsLedger(Ref ref) =>
    LoadPointsLedger(ref.watch(recordsRepositoryProvider));

/// 指定分类的考试记录。
@Riverpod(retry: noProviderRetry)
Future<List<ExamRecord>> examRecords(
  Ref ref,
  ExamRecordCategory category,
) async {
  final session = ref.watch(sessionStoreProvider);
  if (session == null) return const [];
  return ref.watch(loadExamRecordsProvider).execute(session.userId, category);
}

/// 积分明细。
@Riverpod(retry: noProviderRetry)
Future<List<PointEntry>> pointsLedger(Ref ref) async {
  final session = ref.watch(sessionStoreProvider);
  if (session == null) return const [];
  return ref.watch(loadPointsLedgerProvider).execute(session.userId);
}
