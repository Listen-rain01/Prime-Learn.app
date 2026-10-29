/// 考试记录分类（对应 `GetMyExamListOne` 的 `type`）。
enum ExamRecordCategory {
  /// 手机考试 → `type=2`，记录标签「手机自测」。
  mobile(2, '手机'),

  /// 模拟考试 → `type=3`，记录标签「手机模拟」。
  mock(3, '模拟'),

  /// 理论考试 → `type=0`。
  theory(0, '理论');

  const ExamRecordCategory(this.wireType, this.label);

  /// 接口 `type` 参数。
  final int wireType;

  /// 界面上的短标签。
  final String label;
}

/// 考试记录。
class ExamRecord {
  /// 创建考试记录。
  const ExamRecord({
    required this.examName,
    required this.examType,
    required this.mark,
    required this.qualified,
    required this.state,
    this.startTime,
    this.endTime,
  });

  /// 试卷/考试名称。
  final String examName;

  /// 平台返回的考试类型标签。
  final String examType;

  /// 得分。
  final double mark;

  /// 是否合格。
  final bool qualified;

  /// 状态文案，如「已交卷」。
  final String state;

  /// 开始时间。
  final DateTime? startTime;

  /// 结束时间。
  final DateTime? endTime;

  /// 得分是否整数（展示用）。
  bool get isWholeMark => mark == mark.roundToDouble();
}
