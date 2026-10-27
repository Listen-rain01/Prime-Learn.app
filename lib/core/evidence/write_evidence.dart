import 'package:primelearn/core/evidence/write_level.dart';

/// 写操作证据登记表（代码侧镜像 `docs/api/evidence-register.md`）。
///
/// 只登记需要真实写入的接口；未登记的接口按 [WriteLevel.assumed] 处理。
class WriteEvidence {
  /// 创建证据表。
  const WriteEvidence(this._levels);

  /// 默认登记：
  /// - 签到：2026-10-28 经账号持有人授权，已完成真实环境签到实测
  ///   （首次「操作成功」、任务进度与积分同步变化），按 §8.8 升级为 `verified`。
  factory WriteEvidence.defaults() => const WriteEvidence({
    '/ArchiveManger/D_PersonAccumulate/CheckInOne': WriteLevel.verified,
  });

  final Map<String, WriteLevel> _levels;

  /// 查询接口的证据级别。
  WriteLevel levelOf(String endpoint) =>
      _levels[endpoint] ?? WriteLevel.assumed;
}
