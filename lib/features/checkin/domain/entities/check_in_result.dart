/// 签到结果（`CheckInOne`）。
class CheckInResult {
  /// 创建签到结果。
  const CheckInResult({required this.alreadyCheckedIn, required this.message});

  /// 是否为「今日已签到」。
  final bool alreadyCheckedIn;

  /// 服务端原始 `message`。
  final String message;

  /// 展示文案。
  String get displayMessage => alreadyCheckedIn ? '今日已签到，积分不变' : '签到成功';
}
