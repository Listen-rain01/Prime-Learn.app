import 'package:primelearn/core/protocol/json_envelope.dart';
import 'package:primelearn/features/records/domain/entities/exam_record.dart';

/// 考试记录 DTO（`GetMyExamListOne` 的单条 `data`）。
class ExamRecordDto {
  /// 创建 DTO。
  const ExamRecordDto({
    required this.examName,
    required this.examType,
    required this.mark,
    required this.qualified,
    required this.state,
    this.startTime,
    this.endTime,
  });

  /// 由 JSON 构造；字段缺失/类型不符时回退到安全默认值。
  factory ExamRecordDto.fromJson(Map<String, dynamic> json) => ExamRecordDto(
    examName: json['ExamName']?.toString() ?? '',
    examType: json['ExamType']?.toString() ?? '',
    mark: _asDouble(json['Mark']),
    qualified: _asBool(json['WhetherQualified']),
    state: (json['ShowState'] ?? json['State'])?.toString() ?? '',
    startTime: _asDate(json['StartTime']),
    endTime: _asDate(json['EndTime']),
  );

  /// 考试名称。
  final String examName;

  /// 考试类型标签。
  final String examType;

  /// 得分。
  final double mark;

  /// 是否合格。
  final bool qualified;

  /// 状态文案。
  final String state;

  /// 开始时间。
  final DateTime? startTime;

  /// 结束时间。
  final DateTime? endTime;
}

/// 考试记录响应解析。
class ExamRecordsParser {
  /// 创建解析器。
  const ExamRecordsParser();

  /// 解析考试记录列表。
  List<ExamRecordDto> parse(String body) => JsonEnvelope.list(
    body,
    label: '我的考试记录',
  ).map(ExamRecordDto.fromJson).toList(growable: false);
}

double _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim()) ?? 0;
  return 0;
}

bool _asBool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) return value.toLowerCase() == 'true';
  return false;
}

DateTime? _asDate(Object? value) {
  if (value == null) return null;
  final text = value.toString().trim();
  if (text.isEmpty) return null;
  return DateTime.tryParse(text.replaceFirst(' ', 'T'));
}

/// 供页面显示的分类标签。
String categoryLabelOf(ExamRecordCategory category) => category.label;
