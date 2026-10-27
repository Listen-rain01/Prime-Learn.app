/// 登录态。
class Session {
  /// 创建会话。
  const Session({
    required this.userId,
    required this.userName,
    this.bankName,
    this.examTypeId,
  });

  /// 用户标识，即后续接口的 `pid`。
  final String userId;

  /// 用户姓名。
  final String userName;

  /// 当前题库名称。
  final String? bankName;

  /// 当前题库 ID（`examTypeId`）。
  final String? examTypeId;

  /// 补充题库信息后的新会话。
  Session copyWith({String? bankName, String? examTypeId}) => Session(
    userId: userId,
    userName: userName,
    bankName: bankName ?? this.bankName,
    examTypeId: examTypeId ?? this.examTypeId,
  );
}
