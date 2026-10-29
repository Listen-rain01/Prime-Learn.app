import 'package:primelearn/core/network/api_client.dart';
import 'package:primelearn/core/protocol/esdt_codec.dart';
import 'package:primelearn/features/stats/domain/entities/exam_record.dart';
import 'package:primelearn/features/stats/domain/entities/ranking_board.dart';

/// 记录端点（考试记录 / 积分明细 / 排名 / 成绩趋势）。
class StatsApi {
  /// 创建 API 封装。
  StatsApi(this._client);

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

  /// 榜单类别：平台页面用 `id` 区分（0 本单位 / 1 集团）。
  static int _scopeId(RankingScope scope) => scope == RankingScope.unit ? 0 : 1;

  /// 成绩排名路径；`pid` 为明文，`type` 为范围（1 单位 / 0 集团），`id` 为类别（0/1）。
  static String markRankingPath(
    String userId, {
    required RankingScope scope,
    required String begin,
    required String end,
    int page = 1,
    int rows = 20,
  }) =>
      '/ExamManger/P_ExamDetail/GetMarkRankingList'
      '?rows=$rows&page=$page&begin=$begin&end=$end'
      '&type=${scope.wireType}&id=${_scopeId(scope)}&pid=$userId';

  /// 学习时长排名的表单；`pid` 需 Esdt 编码。
  static Map<String, String> studyTimeRankingForm(
    String userId, {
    required RankingScope scope,
    required String begin,
    required String end,
    int page = 1,
    int rows = 20,
  }) => {
    'pid': _esdt.encode(userId),
    'type': '${scope.wireType}',
    'id': '${_scopeId(scope)}',
    'page': '$page',
    'rows': '$rows',
    'begin': begin,
    'end': end,
  };

  /// 个人积分排名的表单；`pid`/`begin`/`end` 均需 Esdt 编码，`type` 明文。
  ///
  /// 实测（2026-10-29，账号持有人授权）：`type=1` 单位榜 / `0` 集团榜；
  /// 积分在 `AllCount`，`Mark` 恒为 null；周榜周一~周日，月榜月初~月末。
  static Map<String, String> integralRankingForm(
    String userId, {
    required RankingScope scope,
    required String begin,
    required String end,
    int page = 1,
    int rows = 20,
  }) => {
    'pid': _esdt.encode(userId),
    'type': '${scope.wireType}',
    'page': '$page',
    'rows': '$rows',
    'begin': _esdt.encode(begin),
    'end': _esdt.encode(end),
  };

  /// 个人成绩趋势路径；`pid` 为明文，`type` 为考试类型（中文需编码）。
  static String scoreTrendPath(
    String userId, {
    String type = '理论考试',
    int page = 1,
    int rows = 20,
  }) =>
      '/ExamManger/P_ExamDetail/GetPersonExamAchievementListOne'
      '?pid=$userId&rows=$rows&page=$page'
      '&type=${Uri.encodeQueryComponent(type)}';

  /// 查询考试记录。
  Future<String> fetchExamRecords(String userId, ExamRecordCategory category) =>
      _client.getRaw(examRecordsPath(userId, category));

  /// 查询积分明细。
  Future<String> fetchPointsLedger(String userId) =>
      _client.getRaw(pointsLedgerPath(userId));

  /// 查询成绩排名。
  Future<String> fetchMarkRanking(
    String userId, {
    required RankingScope scope,
    required String begin,
    required String end,
  }) => _client.getRaw(
    markRankingPath(userId, scope: scope, begin: begin, end: end),
  );

  /// 查询学习时长排名。
  Future<String> fetchStudyTimeRanking(
    String userId, {
    required RankingScope scope,
    required String begin,
    required String end,
  }) => _client.postForm(
    '/ArchiveManger/D_PersonStudyLog/GetStudyTimeRankingListOne',
    studyTimeRankingForm(userId, scope: scope, begin: begin, end: end),
  );

  /// 查询个人积分排名。
  Future<String> fetchIntegralRanking(
    String userId, {
    required RankingScope scope,
    required String begin,
    required String end,
  }) => _client.postForm(
    '/ArchiveManger/D_PersonAccumulate/GetAccumulateRankingListOne',
    integralRankingForm(userId, scope: scope, begin: begin, end: end),
  );

  /// 查询个人成绩趋势。
  Future<String> fetchScoreTrend(String userId) =>
      _client.getRaw(scoreTrendPath(userId));
}
