import 'package:primelearn/core/evidence/write_level.dart';

/// 写操作证据登记表（代码侧镜像 `docs/api/evidence-register.md`）。
///
/// 支持两级粒度：
/// - **端点级**：整个接口只有一种写入行为时使用；
/// - **行为级**：同一端点承载多种写入行为时（如 `CreateTempExamOne` 的
///   `type=1` 模拟 / `type=2` 手机），必须按行为分别登记，
///   否则一种行为验证过会让另一种未验证的行为一起放行。
///
/// 未登记的接口按 [WriteLevel.assumed] 处理。
class WriteEvidence {
  /// 创建证据表。
  const WriteEvidence(this._levels, {Map<String, WriteLevel>? behaviors})
    : _behaviors = behaviors ?? const {};

  /// 默认登记：
  /// - 签到：2026-10-28 经账号持有人授权，已完成真实环境签到实测。
  /// - 完成阅读：2026-10-27 真实环境完成阅读 0→1，2026-10-28 复核。
  /// - 模拟考试（type=1 / style=1）：2026-10-27 两场 100 分 + 2026-10-28 客户端跑通。
  /// - 手机考试（type=2 / style=0）：2026-10-28 真机跑通全链路（含加密结算），
  ///   因此创建/进入/提交同样是实测过的行为，按行为分别登记。
  /// - 题库切换：2026-10-29 真机验证。
  factory WriteEvidence.defaults() => const WriteEvidence(
    {
      '/ArchiveManger/D_PersonAccumulate/CheckInOne': WriteLevel.verified,
      '/ArchiveManger/D_PersonAccumulate/StudyKnowledgeOne':
          WriteLevel.verified,
      '/Home/CEndTimeMobil': WriteLevel.verified,
      '/Home/CEndTimeOne': WriteLevel.verified,
      '/ArchiveManger/D_PersonManager/SaveExamTypeIdsOne': WriteLevel.verified,
    },
    behaviors: {
      // 同一端点按行为区分：type=1 模拟、type=2 手机。
      '/Home/CreateTempExamOne#mock': WriteLevel.verified,
      '/Home/CreateTempExamOne#mobile': WriteLevel.verified,
      // style=1 模拟、style=0 手机。
      '/P_ExamDetail/SetOnlineTestOne#mock': WriteLevel.verified,
      '/P_ExamDetail/SetOnlineTestOne#mobile': WriteLevel.verified,
      '/Home/DoWriteAnswerAll#mock': WriteLevel.verified,
      '/Home/DoWriteAnswerAll#mobile': WriteLevel.verified,
    },
  );

  final Map<String, WriteLevel> _levels;
  final Map<String, WriteLevel> _behaviors;

  /// 查询证据级别。
  ///
  /// 优先匹配「端点 + 行为」；该端点登记了行为级条目但行为不匹配时，
  /// 视为未登记（`assumed`），不接受端点级兜底，避免行为越权。
  WriteLevel levelOf(String endpoint, {String? behavior}) {
    final scoped = behavior == null ? null : _behaviors['$endpoint#$behavior'];
    if (scoped != null) return scoped;
    if (behavior != null && _hasAnyBehaviorFor(endpoint)) {
      return WriteLevel.assumed;
    }
    return _levels[endpoint] ?? WriteLevel.assumed;
  }

  bool _hasAnyBehaviorFor(String endpoint) =>
      _behaviors.keys.any((key) => key.startsWith('$endpoint#'));
}
