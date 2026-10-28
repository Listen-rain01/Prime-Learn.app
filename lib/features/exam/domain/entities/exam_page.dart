/// 考试中的一道题。
class ExamQuestion {
  /// 创建题目。
  const ExamQuestion({
    required this.fields,
    required this.type,
    required this.score,
    required this.stem,
    required this.options,
  });

  /// 原始 22 个字段（提交答案时需要回填字段 4）。
  final List<String> fields;

  /// 题型：1 单选 / 2 多选 / 3 判断。
  final int type;

  /// 分值。
  final int score;

  /// 题干（已 URL 解码）。
  final String stem;

  /// 选项文本（已解码，`#` 分隔）。
  final List<String> options;

  /// 题目 GUID。
  String get id => fields[1];

  /// 正确答案（字段 13）。
  String get correctAnswer => fields[13];
}

/// 一次考试的试题页数据。
class ExamPageData {
  /// 创建试题页数据。
  const ExamPageData({
    required this.questions,
    required this.examTypeName,
    this.totalCount = 0,
    this.publicKeyXml = '',
  });

  /// 题目列表。
  final List<ExamQuestion> questions;

  /// 题库名称（页面展示用）。
  final String examTypeName;

  /// 题目总数（vData.AllCount）。
  final int totalCount;

  /// 手机考试结算使用的 RSA 公钥（vData.my）。
  final String publicKeyXml;
}

/// 考试结算结果。
class ExamResult {
  /// 创建结果。
  const ExamResult({
    required this.score,
    required this.passed,
    required this.message,
  });

  /// 分数。
  final int score;

  /// 是否合格。
  final bool passed;

  /// 平台返回的原始文案。
  final String message;
}
