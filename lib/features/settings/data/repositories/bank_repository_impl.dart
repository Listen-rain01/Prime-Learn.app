import 'package:primelearn/features/settings/data/parsers/bank_catalog_parser.dart';
import 'package:primelearn/features/settings/data/parsers/bank_unit_parser.dart';
import 'package:primelearn/features/settings/data/services/bank_api.dart';
import 'package:primelearn/features/settings/domain/entities/bank_catalog.dart';
import 'package:primelearn/features/settings/domain/repositories/bank_repository.dart';

/// 题库仓储实现。
class BankRepositoryImpl implements BankRepository {
  /// 创建仓储实现。
  BankRepositoryImpl(this._api);

  final BankApi _api;
  static const BankUnitParser _unitParser = BankUnitParser();
  static const BankStyleParser _styleParser = BankStyleParser();
  static const BankOptionParser _optionParser = BankOptionParser();

  @override
  Future<List<BankUnit>> fetchUnits(String userId) async {
    final html = await _api.fetchUnits(userId);
    return _unitParser.parse(html);
  }

  @override
  Future<List<BankStyle>> fetchStyles(String userId, String unitId) async {
    final body = await _api.fetchStyles(userId: userId, unitId: unitId);
    return _styleParser.parse(body);
  }

  @override
  Future<List<BankStyle>> fetchChildren({
    required String unitId,
    required String styleId,
    required String code,
    required String departmentId,
  }) async {
    final body = await _api.fetchChildren(
      unitId: unitId,
      styleId: styleId,
      code: code,
      departmentId: departmentId,
    );
    return _styleParser.parse(body);
  }

  @override
  Future<List<BankOption>> fetchOptions({
    required String unitId,
    required String styleId,
    required String departmentId,
    required String year,
  }) async {
    final body = await _api.fetchOptions(
      unitId: unitId,
      styleId: styleId,
      departmentId: departmentId,
      year: year,
    );
    return _optionParser.parse(body);
  }

  @override
  Future<void> saveBank(String userId, String bankId) async {
    await _api.saveBank(userId: userId, bankId: bankId);
  }
}
