/// 会话校验接口返回结构（FirstIndexOne）。
class ExamContextDto {
  /// 创建 DTO。
  const ExamContextDto({this.bankName, this.examTypeId});

  /// 当前题库名称（下标 4）。
  final String? bankName;

  /// 题库 ID（下标 6）。
  final String? examTypeId;
}
