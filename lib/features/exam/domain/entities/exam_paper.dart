/// 可考试卷（`SelectCanRunListOne`）。
class ExamPaper {
  /// 创建试卷。
  const ExamPaper({
    required this.id,
    required this.name,
    required this.totalScore,
    required this.passingGrade,
  });

  /// 试卷 ID。
  final String id;

  /// 试卷名称。
  final String name;

  /// 总分。
  final double totalScore;

  /// 及格分。
  final double passingGrade;
}
