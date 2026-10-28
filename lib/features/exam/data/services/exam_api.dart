import 'package:primelearn/core/network/api_client.dart';
import 'package:primelearn/core/protocol/esdt_codec.dart';
import 'package:primelearn/features/exam/domain/exam_endpoints.dart';

/// 考试相关端点（试卷列表、模拟考试流程）。
class ExamApi {
  /// 创建 API 封装。
  ExamApi(this._client);

  final ApiClient _client;
  static const EsdtCodec _esdt = EsdtCodec();

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

  /// 创建临时考试；模拟考试 `type=1`，手机考试 `type=2`。
  Future<String> createExam({
    required String userId,
    required String paperId,
    required int type,
  }) => _client.postForm(createTempExamEndpoint, {
    'PaperId': paperId,
    'PersonId': userId,
    'IDNumber': '',
    'type': '$type',
  });

  /// 进入考试；模拟考试 `style=1`，手机考试 `style=0`。
  Future<String> enterExam({
    required String ksmxid,
    required String userId,
    required int style,
  }) => _client.postForm(enterExamEndpoint, {
    'ksmxid': _esdt.encode(ksmxid),
    'showBZDA': _esdt.encode('0'),
    'style': '$style',
    'vErr': '-1',
    'nc': '',
    'r': '',
    'e': '',
    'b': '',
    'pid': _esdt.encode(userId),
  });

  /// 获取考试页 HTML。
  Future<String> fetchExamPage() =>
      _client.getRaw(onlineTestEndpoint, expectHtml: true);

  /// 提交全部答案。
  Future<String> submitAnswers({
    required String ksmxid,
    required String answer,
  }) => _client.postForm(submitAnswersEndpoint, {
    'answer': answer,
    'ksmxid': ksmxid,
  });

  /// 模拟考试结算（`mxid2/mxid3` 空值即可）。
  Future<String> settleMock(String ksmxid) => _client.postForm(
    settleMockEndpoint,
    {'ksmxid': ksmxid, 'mxid2': '', 'mxid3': ''},
  );

  /// 手机考试结算（需加密参数）。
  Future<String> settleMobile({
    required String ksmxid,
    required String mxid2,
    required String mxid3,
  }) => _client.postForm(settleMobileEndpoint, {
    'ksmxid': ksmxid,
    'mxid2': mxid2,
    'mxid3': mxid3,
  });
}
