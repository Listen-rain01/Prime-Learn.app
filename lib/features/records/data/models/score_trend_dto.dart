/// 个人成绩趋势 DTO（`GetPersonExamAchievementListOne` 的单条 `rows`）。
class ScoreTrendDto {
  /// 创建 DTO。
  const ScoreTrendDto({
    required this.examName,
    required this.examType,
    required this.mark,
    this.time,
  });

  /// 由 JSON 构造。
  factory ScoreTrendDto.fromJson(Map<String, dynamic> json) => ScoreTrendDto(
    examName: json['ExamName']?.toString() ?? '',
    examType: json['ExamType']?.toString() ?? '',
    mark: _asDouble(json['Mark']),
    time: _asDate(json['EndTime']) ?? _asDate(json['StartTime']),
  );

  /// 考试名称。
  final String examName;

  /// 考试类型。
  final String examType;

  /// 得分。
  final double mark;

  /// 结束时间（优先）或开始时间。
  final DateTime? time;
}

double _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim()) ?? 0;
  return 0;
}

DateTime? _asDate(Object? value) {
  if (value == null) return null;
  final text = value.toString().trim();
  if (text.isEmpty) return null;
  return DateTime.tryParse(text.replaceFirst(' ', 'T'));
}
