/// 平台积分任务的标识（`Criterion` 字段）。
enum Criterion {
  /// 签到。
  checkIn('CheckIn'),

  /// 知识学习。
  studyKnowledge('StudyKnowledge'),

  /// 模拟考试。
  mockExam('MockExam'),

  /// 手机考试。
  mobileExam('MobileExam'),

  /// 视频学习。
  course('Course'),

  /// 练习时长。
  studyTime('StudyTime'),

  /// 手机练习。
  mobileExercises('MobileExercises'),

  /// 未知任务，服务端新增时兜底。
  unknown('');

  const Criterion(this.wire);

  /// 接口返回的原始标识。
  final String wire;

  /// 由接口字符串解析；未知值返回 [Criterion.unknown]。
  static Criterion fromWire(String value) => values.firstWhere(
    (criterion) => criterion.wire == value,
    orElse: () => Criterion.unknown,
  );
}

/// 今日任务。
class DailyTask {
  /// 创建任务。
  const DailyTask({
    required this.criterion,
    required this.name,
    required this.rule,
    required this.score,
    required this.maxScore,
    required this.currentScore,
    required this.progressText,
    required this.sort,
  });

  /// 任务标识。
  final Criterion criterion;

  /// 任务名称。
  final String name;

  /// 平台下发的规则文案。
  final String rule;

  /// 单次/单档积分。
  final int score;

  /// 每日上限。
  final int maxScore;

  /// 今日已得积分。
  final int currentScore;

  /// 进度描述，如 `已答285题/获得5分`。
  final String progressText;

  /// 服务端排序值。
  final int sort;

  /// 是否已拿满今日上限。
  bool get isCompleted => maxScore > 0 && currentScore >= maxScore;
}
