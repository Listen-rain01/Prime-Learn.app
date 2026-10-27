import 'package:primelearn/core/network/api_client.dart';
import 'package:primelearn/core/protocol/esdt_codec.dart';
import 'package:primelearn/features/records/domain/entities/exam_record.dart';

/// 记录端点（考试记录 + 积分明细）。
class RecordsApi {
  /// 创建 API 封装。
  RecordsApi(this._client);

  final ApiClient _client;
  static const EsdtCodec _esdt = EsdtCodec();

  /// 考试记录路径；`pid` 为明文，`type` 决定分类（0 理论 / 2 手机 / 3 模拟）。
  static String examRecordsPath(
    String userId,
    ExamRecordCategory category, {
    int page = 1,
    int rows = 20,
  }) =>
      '/ExamManger/P_ExamDetail/GetMyExamListOne'
      '?rows=$rows&page=$page&pid=$userId&type=${category.wireType}';

  /// 积分明细路径；`pid` 需 Esdt 编码（已转义，不能再编码）。
  static String pointsLedgerPath(
    String userId, {
    int page = 1,
    int rows = 20,
  }) =>
      '/ArchiveManger/D_PersonAccumulate/GetMyAccumulateListOne'
      '?pid=${_esdt.encode(userId)}&page=$page&rows=$rows';

  /// 查询考试记录。
  Future<String> fetchExamRecords(String userId, ExamRecordCategory category) =>
      _client.getRaw(examRecordsPath(userId, category));

  /// 查询积分明细。
  Future<String> fetchPointsLedger(String userId) =>
      _client.getRaw(pointsLedgerPath(userId));
}
