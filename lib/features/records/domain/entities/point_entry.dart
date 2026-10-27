/// 一条积分明细。
class PointEntry {
  /// 创建积分明细。
  const PointEntry({
    required this.name,
    required this.amount,
    this.date,
    this.reduceName,
  });

  /// 积分来源，如「签到」「手机考试」。
  final String name;

  /// 本次积分，可为负（扣减）。
  final int amount;

  /// 入账时间。
  final DateTime? date;

  /// 扣减名称（正常加分时为空）。
  final String? reduceName;
}
