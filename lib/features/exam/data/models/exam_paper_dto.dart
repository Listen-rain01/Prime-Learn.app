import 'package:primelearn/features/exam/domain/entities/exam_paper.dart';

/// 试卷 DTO。
class ExamPaperDto {
  /// 创建 DTO。
  const ExamPaperDto({
    required this.id,
    required this.name,
    required this.totalScore,
    required this.passingGrade,
  });

  /// 由 JSON 构造。
  factory ExamPaperDto.fromJson(Map<String, dynamic> json) => ExamPaperDto(
    id: json['PaperId']?.toString() ?? '',
    name: json['PaperName']?.toString() ?? '',
    totalScore: _asDouble(json['TotalScore']),
    passingGrade: _asDouble(json['PassingGrade']),
  );

  /// 试卷 ID。
  final String id;

  /// 试卷名称。
  final String name;

  /// 总分。
  final double totalScore;

  /// 及格分。
  final double passingGrade;
}

double _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim()) ?? 0;
  return 0;
}

/// 将 DTO 转为实体。
ExamPaper toExamPaper(ExamPaperDto dto) => ExamPaper(
  id: dto.id,
  name: dto.name,
  totalScore: dto.totalScore,
  passingGrade: dto.passingGrade,
);
