/// 个人成绩趋势中的一条记录。
class ScoreTrendPoint {
  /// 创建趋势点。
  const ScoreTrendPoint({
    required this.examName,
    required this.examType,
    required this.mark,
    this.time,
  });

  /// 考试名称。
  final String examName;

  /// 考试类型。
  final String examType;

  /// 得分。
  final double mark;

  /// 结束时间（优先）或开始时间。
  final DateTime? time;
}
