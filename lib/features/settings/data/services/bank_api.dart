import 'package:primelearn/core/network/api_client.dart';
import 'package:primelearn/core/protocol/esdt_codec.dart';
import 'package:primelearn/features/settings/domain/bank_endpoints.dart';

/// 题库选择链路（docs/api/题库切换接口文档.md）。
class BankApi {
  /// 创建 API 封装。
  BankApi(this._client);

  final ApiClient _client;
  static const EsdtCodec _esdt = EsdtCodec();

  /// 单位列表：POST SelectExamType，返回 HTML。
  Future<String> fetchUnits(String userId) =>
      _client.postForm(bankUnitsEndpoint, {'pid': userId}, expectHtml: true);

  /// 大类：`pid`/`unitid` 均需 Esdt。
  Future<String> fetchStyles({
    required String userId,
    required String unitId,
  }) => _client.postForm(bankStylesEndpoint, {
    'pid': _esdt.encode(userId),
    'unitid': _esdt.encode(unitId),
  });

  /// 子分类：`Style`/`Code`/`DepartmentId`/`unitids` 均需 Esdt。
  Future<String> fetchChildren({
    required String unitId,
    required String styleId,
    required String code,
    required String departmentId,
  }) => _client.postForm(bankChildrenEndpoint, {
    'Style': _esdt.encode(styleId),
    'Code': _esdt.encode(code),
    'DepartmentId': _esdt.encode(_departmentOf(unitId, departmentId)),
    'unitids': _esdt.encode(unitId),
  });

  /// 题库列表：`Year`/`Style` 为明文，其余 Esdt（页面实测拼装）。
  Future<String> fetchOptions({
    required String unitId,
    required String styleId,
    required String departmentId,
    required String year,
  }) => _client.getRaw(
    '$bankOptionsEndpoint?Year=$year&Style=$styleId'
    '&DepartmentId=${_esdt.encode(_departmentOf(unitId, departmentId))}'
    '&unitids=${_esdt.encode(unitId)}'
    '&cname=${_esdt.encode('')}&page=1&rows=50',
  );

  /// 保存题库：`pid` 与 `ExamTypeIds` 均需 Esdt。
  Future<String> saveBank({required String userId, required String bankId}) =>
      _client.postForm(bankSaveEndpoint, {
        'pid': _esdt.encode(userId),
        'ExamTypeIds': _esdt.encode(bankId),
      });

  String _departmentOf(String unitId, String departmentId) =>
      departmentId.isEmpty ? unitId : departmentId;
}
