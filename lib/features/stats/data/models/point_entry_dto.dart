import 'package:primelearn/core/protocol/json_envelope.dart';

/// 积分明细 DTO（`GetMyAccumulateListOne` 的单条 `data`）。
class PointEntryDto {
  /// 创建 DTO。
  const PointEntryDto({
    required this.name,
    required this.amount,
    this.date,
    this.reduceName,
  });

  /// 由 JSON 构造。
  factory PointEntryDto.fromJson(Map<String, dynamic> json) => PointEntryDto(
    name: json['AccumulateName']?.toString() ?? '',
    amount: _asInt(json['Accumulate']),
    date: _asDate(json['AccumulateDate']),
    reduceName: _asText(json['ReduceName']),
  );

  /// 积分来源。
  final String name;

  /// 本次积分（可为负）。
  final int amount;

  /// 入账时间。
  final DateTime? date;

  /// 扣减名称。
  final String? reduceName;
}

/// 积分明细响应解析。
class PointsLedgerParser {
  /// 创建解析器。
  const PointsLedgerParser();

  /// 解析积分明细列表。
  List<PointEntryDto> parse(String body) => JsonEnvelope.list(
    body,
    label: '积分明细',
  ).map(PointEntryDto.fromJson).toList(growable: false);
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim()) ?? 0;
  return 0;
}

DateTime? _asDate(Object? value) {
  if (value == null) return null;
  final text = value.toString().trim();
  if (text.isEmpty) return null;
  return DateTime.tryParse(text.replaceFirst(' ', 'T'));
}

String? _asText(Object? value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}
