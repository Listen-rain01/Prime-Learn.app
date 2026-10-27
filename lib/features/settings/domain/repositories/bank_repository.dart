import 'package:primelearn/features/settings/domain/entities/bank_catalog.dart';

/// 题库选择数据接口。
abstract interface class BankRepository {
  /// 单位列表。
  Future<List<BankUnit>> fetchUnits(String userId);

  /// 大类。
  Future<List<BankStyle>> fetchStyles(String userId, String unitId);

  /// 子分类。
  Future<List<BankStyle>> fetchChildren({
    required String unitId,
    required String styleId,
    required String code,
    required String departmentId,
  });

  /// 题库列表。
  Future<List<BankOption>> fetchOptions({
    required String unitId,
    required String styleId,
    required String departmentId,
    required String year,
  });

  /// 保存题库（写操作，需写网关）。
  Future<void> saveBank(String userId, String bankId);
}
