/// 今日任务 DTO（`GetPersonTodayAccumulateOne` 的单条 `data`）。
class DailyTaskDto {
  /// 创建 DTO。
  const DailyTaskDto({
    required this.criterion,
    required this.name,
    required this.rule,
    required this.score,
    required this.maxScore,
    required this.currentScore,
    required this.progressText,
    required this.sort,
  });

  /// 由 JSON 构造；字段缺失/类型不符时回退到安全默认值。
  factory DailyTaskDto.fromJson(Map<String, dynamic> json) => DailyTaskDto(
    criterion: json['Criterion']?.toString() ?? '',
    name: json['AccumulateName']?.toString() ?? '',
    rule: json['AccumulateRule']?.toString() ?? '',
    score: _asInt(json['Accumulate']),
    maxScore: _asInt(json['MaxAccumulate']),
    currentScore: _asInt(json['CurAccumulate']),
    progressText: json['CurAccumulateState']?.toString() ?? '',
    sort: _asInt(json['Sort']),
  );

  /// 任务标识。
  final String criterion;

  /// 任务名称。
  final String name;

  /// 规则文案。
  final String rule;

  /// 单次/单档积分。
  final int score;

  /// 每日上限。
  final int maxScore;

  /// 今日已得积分。
  final int currentScore;

  /// 进度描述。
  final String progressText;

  /// 排序值。
  final int sort;
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim()) ?? 0;
  return 0;
}
