/// 当前题库上下文。
class BankContext {
  /// 创建题库上下文。
  const BankContext({this.bankName, this.examTypeId});

  /// 题库名称。
  final String? bankName;

  /// 题库 ID（`examTypeId`）。
  final String? examTypeId;
}
