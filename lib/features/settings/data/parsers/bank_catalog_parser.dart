import 'package:primelearn/core/protocol/json_envelope.dart';
import 'package:primelearn/features/settings/domain/entities/bank_catalog.dart';

/// 分类响应解析（`GetAllTypeEx` / `GetAllChildTypeEx`）。
class BankStyleParser {
  /// 创建解析器。
  const BankStyleParser();

  /// 解析分类列表。
  List<BankStyle> parse(String body) => JsonEnvelope.list(
    body,
    label: '题库分类',
  ).map(_toStyle).toList(growable: false);

  BankStyle _toStyle(Map<String, dynamic> json) => BankStyle(
    level: _asInt(json['Level']),
    styleId: _asText(json['ExamTypeStyleId']),
    name: _asText(json['StyleName']),
    year: _asText(json['Year']),
    departmentId: _asText(json['DepartmentId']),
    code: _asText(json['Code']),
  );
}

/// 题库列表响应解析（`GetExamTypeListExOne`）。
class BankOptionParser {
  /// 创建解析器。
  const BankOptionParser();

  /// 解析题库列表。
  List<BankOption> parse(String body) => JsonEnvelope.list(
    body,
    label: '题库列表',
  ).map(_toOption).toList(growable: false);

  BankOption _toOption(Map<String, dynamic> json) => BankOption(
    id: _asText(json['ExamTypeId']),
    name: _asText(json['ExamTypeName']),
    questionCount: _asInt(json['QuestionCount']),
    stateName: _asText(json['StateName']),
  );
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim()) ?? 0;
  return 0;
}

String _asText(Object? value) => value?.toString().trim() ?? '';
