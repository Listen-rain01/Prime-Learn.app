import 'package:primelearn/core/network/api_client.dart';

/// 考试相关端点（试卷列表）。
class ExamApi {
  /// 创建 API 封装。
  ExamApi(this._client);

  final ApiClient _client;

  /// 可考试卷路径；`examtypeid` 为题库 ID。
  static String papersPath(
    String userId,
    String bankId, {
    int page = 1,
    int rows = 20,
  }) =>
      '/ExamManger/P_Paper/SelectCanRunListOne'
      '?rows=$rows&page=$page&pid=$userId&examtypeid=$bankId';

  /// 查询可考试卷。
  Future<String> fetchPapers(String userId, String bankId) =>
      _client.getRaw(papersPath(userId, bankId));
}
