/// 榜单类型。
enum RankingKind {
  /// 成绩榜（`GetMarkRankingList`）。
  mark('成绩榜'),

  /// 学习时长榜（`GetStudyTimeRankingListOne`）。
  studyTime('学习时长榜'),

  /// 个人积分榜（`GetAccumulateRankingListOne`）。
  integral('积分榜');

  const RankingKind(this.label);

  /// 界面标签。
  final String label;
}

/// 榜单范围。
enum RankingScope {
  /// 单位榜 → `type=1`。
  unit(1, '单位'),

  /// 集团榜 → `type=0`。
  group(0, '集团');

  const RankingScope(this.wireType, this.label);

  /// 接口 `type` 参数。
  final int wireType;

  /// 界面标签。
  final String label;
}

/// 榜单中的一条记录。
class RankingEntry {
  /// 创建榜单记录。
  const RankingEntry({
    required this.rank,
    required this.personName,
    required this.department,
    required this.mark,
    this.allCount = 0,
  });

  /// 排名（`Ranking`）。
  final int rank;

  /// 姓名。
  final String personName;

  /// 单位全路径。
  final String department;

  /// 得分（成绩榜）。
  final double mark;

  /// 总题数/总分；学习时长榜里是时长（秒，实测推断，见 evidence）。
  final double allCount;
}

/// 榜单数据：当前用户排名 + 榜单条目。
class RankingBoard {
  /// 创建榜单。
  const RankingBoard({
    this.myName = '',
    this.myRank,
    this.myMark,
    this.entries = const [],
  });

  /// 当前用户姓名（来自 `message` 首段）。
  final String myName;

  /// 当前用户排名；`message` 缺失或格式异常时为 null。
  final int? myRank;

  /// 当前用户得分。
  final double? myMark;

  /// 榜单条目（按接口顺序）。
  final List<RankingEntry> entries;

  /// 是否没有榜单数据。
  bool get isEmpty => entries.isEmpty;
}
