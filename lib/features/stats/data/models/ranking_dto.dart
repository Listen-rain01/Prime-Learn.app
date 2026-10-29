/// 成绩排名 DTO（`GetMarkRankingList` / 学习时长排名）。
class RankingEntryDto {
  /// 创建 DTO。
  const RankingEntryDto({
    required this.rank,
    required this.personName,
    required this.department,
    required this.mark,
    required this.allCount,
  });

  /// 由 JSON 构造。
  factory RankingEntryDto.fromJson(Map<String, dynamic> json) =>
      RankingEntryDto(
        rank: _asInt(json['Ranking']),
        personName: json['PersonName']?.toString() ?? '',
        department: json['DepartmentFullName']?.toString() ?? '',
        mark: _asDouble(json['Mark']),
        allCount: _asDouble(json['AllCount']),
      );

  /// 排名。
  final int rank;

  /// 姓名。
  final String personName;

  /// 单位全路径。
  final String department;

  /// 得分（成绩榜）。
  final double mark;

  /// 总题数/总分；学习时长榜里是时长（秒）。
  final double allCount;
}

/// 排名响应 DTO：`message` 为「姓名|排名|成绩」形式的当前用户信息。
class RankingBoardDto {
  /// 创建 DTO。
  const RankingBoardDto({
    required this.entries,
    this.myName = '',
    this.myRank,
    this.myMark,
  });

  /// 榜单条目。
  final List<RankingEntryDto> entries;

  /// 当前用户姓名。
  final String myName;

  /// 当前用户排名。
  final int? myRank;

  /// 当前用户成绩。
  final double? myMark;
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim()) ?? 0;
  return 0;
}

double _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim()) ?? 0;
  return 0;
}
