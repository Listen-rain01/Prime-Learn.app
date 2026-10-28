import 'package:primelearn/core/evidence/write_level.dart';

/// 写操作证据登记表（代码侧镜像 `docs/api/evidence-register.md`）。
///
/// 只登记需要真实写入的接口；未登记的接口按 [WriteLevel.assumed] 处理。
class WriteEvidence {
  /// 创建证据表。
  const WriteEvidence(this._levels);

  /// 默认登记：
  /// - 签到：2026-10-28 经账号持有人授权，已完成真实环境签到实测，
  ///   按 §8.8 升级为 `verified`。
  /// - 完成阅读：2026-10-27 真实环境完成阅读 0→1，2026-10-28 账号持有人
  ///   授权真实调用复核，按 §8.8 升级为 `verified`。
  /// - 模拟考试（type=1 / style=1）：账号持有人授权 + 文档实测（2026-10-27
  ///   两场 100 分），创建/进入/提交/模拟结算升级为 `verified`。
  /// - 手机考试结算 `CEndTimeOne` 未登记（按 assumed 阻断），因此手机考试
  ///   仍不可运行。
  /// - 题库切换：文档有真实环境记录，但本客户端尚未实测，保持 `observed`
  ///   → 运行时会被写网关拦截，待真实切换验证后再升级。
  factory WriteEvidence.defaults() => const WriteEvidence({
    '/ArchiveManger/D_PersonAccumulate/CheckInOne': WriteLevel.verified,
    '/ArchiveManger/D_PersonAccumulate/StudyKnowledgeOne': WriteLevel.verified,
    '/Home/CreateTempExamOne': WriteLevel.verified,
    '/P_ExamDetail/SetOnlineTestOne': WriteLevel.verified,
    '/Home/DoWriteAnswerAll': WriteLevel.verified,
    '/Home/CEndTimeMobil': WriteLevel.verified,
    '/ArchiveManger/D_PersonManager/SaveExamTypeIdsOne': WriteLevel.observed,
  });

  final Map<String, WriteLevel> _levels;

  /// 查询接口的证据级别。
  WriteLevel levelOf(String endpoint) =>
      _levels[endpoint] ?? WriteLevel.assumed;
}
