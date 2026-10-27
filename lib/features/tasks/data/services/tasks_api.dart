import 'package:primelearn/core/network/api_client.dart';
import 'package:primelearn/core/protocol/esdt_codec.dart';

/// 今日任务端点（docs/api/积分查询接口文档.md §3）。
class TasksApi {
  /// 创建 API 封装。
  TasksApi(this._client);

  final ApiClient _client;
  static const EsdtCodec _esdt = EsdtCodec();

  /// 今日任务路径；`pid` 用 Esdt 编码，**已是转义串，不能再编码一次**。
  static String dailyTasksPath(String userId) {
    final pid = _esdt.encode(userId);
    return '/AccumulateManger/S_Accumulate/GetPersonTodayAccumulateOne?pid=$pid';
  }

  /// 查询今日任务积分。
  Future<String> fetchDailyTasks(String userId) =>
      _client.getRaw(dailyTasksPath(userId));
}
