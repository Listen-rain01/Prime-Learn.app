/// 题库选择链路中的单位。
class BankUnit {
  /// 创建单位。
  const BankUnit({required this.id, required this.name});

  /// 单位 ID。
  final String id;

  /// 单位名称。
  final String name;
}

/// 题库分类（大类 / 中间层 / 年份）。
class BankStyle {
  /// 创建分类。
  const BankStyle({
    required this.level,
    required this.styleId,
    required this.name,
    this.year = '',
    this.departmentId = '',
    this.code = '',
  });

  /// 层级：1 大类、2 中间层、3 年份。
  final int level;

  /// 分类 ID。
  final String styleId;

  /// 分类名称。
  final String name;

  /// 年份（层级 3 才有）。
  final String year;

  /// 单位 ID。
  final String departmentId;

  /// 分类编码。
  final String code;

  /// 唯一标识：同一层级下 `styleId` 可能重复（如各年份都是 0），必须组合判断。
  String get key => '$level|$styleId|$code|$year|$departmentId';
}

/// 一个可选题库。
class BankOption {
  /// 创建题库。
  const BankOption({
    required this.id,
    required this.name,
    required this.questionCount,
    required this.stateName,
    this.singleCount = 0,
    this.multipleCount = 0,
    this.judgeCount = 0,
  });

  /// 题库 ID（`ExamTypeId`）。
  final String id;

  /// 题库名称。
  final String name;

  /// 题目总数。
  final int questionCount;

  /// 状态，如「正常」。
  final String stateName;

  /// 单选题数（`OneQuestionCount`）。
  final int singleCount;

  /// 多选题数（`MoreQuestionCount`）。
  final int multipleCount;

  /// 判断题数（`CheckQuestionCount`）。
  final int judgeCount;
}

/// 预设置的题库。
class BankPreset {
  /// 创建预设。
  const BankPreset({
    required this.bankId,
    required this.bankName,
    this.questionCount,
    this.paperCount,
    this.singleCount,
    this.multipleCount,
    this.judgeCount,
    this.paperName,
    this.paperTotalScore,
    this.paperPassingGrade,
    this.paperId,
    this.paperQuestionCount,
  });

  /// 题库 ID。
  final String bankId;

  /// 题库名称。
  final String bankName;

  /// 保存时的题数快照（旧预设可能为 null）。
  final int? questionCount;

  /// 保存时的可考试卷数快照（旧预设可能为 null）。
  final int? paperCount;

  /// 单选题数快照。
  final int? singleCount;

  /// 多选题数快照。
  final int? multipleCount;

  /// 判断题数快照。
  final int? judgeCount;

  /// 仅有一份试卷时保存试卷名/总分/及格分，便于卡片展示。
  final String? paperName;
  final double? paperTotalScore;
  final double? paperPassingGrade;

  /// 预设置的试卷 ID（考试创建时必须传给平台）。
  final String? paperId;

  /// 实际开考后学到的试卷题数（平台未提供按试卷查询题数的接口）。
  final int? paperQuestionCount;

  /// 复制并覆盖部分字段。
  BankPreset copyWith({
    String? bankId,
    String? bankName,
    int? questionCount,
    int? paperCount,
    int? singleCount,
    int? multipleCount,
    int? judgeCount,
    String? paperId,
    String? paperName,
    double? paperTotalScore,
    double? paperPassingGrade,
    int? paperQuestionCount,
  }) => BankPreset(
    bankId: bankId ?? this.bankId,
    bankName: bankName ?? this.bankName,
    questionCount: questionCount ?? this.questionCount,
    paperCount: paperCount ?? this.paperCount,
    singleCount: singleCount ?? this.singleCount,
    multipleCount: multipleCount ?? this.multipleCount,
    judgeCount: judgeCount ?? this.judgeCount,
    paperId: paperId ?? this.paperId,
    paperName: paperName ?? this.paperName,
    paperTotalScore: paperTotalScore ?? this.paperTotalScore,
    paperPassingGrade: paperPassingGrade ?? this.paperPassingGrade,
    paperQuestionCount: paperQuestionCount ?? this.paperQuestionCount,
  );
}
