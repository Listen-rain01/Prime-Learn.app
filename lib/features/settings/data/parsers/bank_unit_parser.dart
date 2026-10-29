import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/core/protocol/v_data_extractor.dart';
import 'package:primelearn/features/settings/domain/entities/bank_catalog.dart';

/// 单位解析：从 `SelectExamType` 页面 HTML 的 `vData.Units` 提取。
///
/// 实测格式（`^` 分段、`,` 分字段）：
/// `1,股份,股份,股份^<guid>,澄合矿业,澄合矿业,^<guid>,澄合矿业/西卓煤矿,西卓煤矿,chxzmk`
class BankUnitParser {
  /// 创建解析器。
  const BankUnitParser();

  /// 解析单位列表。
  List<BankUnit> parse(String html) {
    final units = _extractUnits(html);
    if (units == null) {
      throw const ApiException(
        kind: ApiErrorKind.protocol,
        message: '题库单位数据缺失',
      );
    }
    final result = <BankUnit>[];
    for (final raw in units.split('^')) {
      final parts = raw.split(',');
      if (parts.length < 3) continue;
      final id = parts[0].trim();
      final name = parts[2].trim().isEmpty ? parts[1].trim() : parts[2].trim();
      if (id.isEmpty || name.isEmpty) continue;
      result.add(BankUnit(id: id, name: name));
    }
    if (result.isEmpty) {
      throw const ApiException(
        kind: ApiErrorKind.protocol,
        message: '题库单位数据为空',
      );
    }
    return result;
  }

  String? _extractUnits(String html) {
    // vData 缺失或非法 JSON 统一转成 ApiException（数据层不得外抛 FormatException）。
    final result = VDataExtractor.extract(html);
    if (result.status == VDataStatus.malformed) {
      throw const ApiException(
        kind: ApiErrorKind.protocol,
        message: '题库单位数据格式异常',
      );
    }
    if (result.status == VDataStatus.missing) return null;
    final units = result.data?['Units'];
    return units is String ? units : null;
  }
}
