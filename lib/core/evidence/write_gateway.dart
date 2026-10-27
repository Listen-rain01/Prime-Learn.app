import 'package:primelearn/core/evidence/write_blocked.dart';
import 'package:primelearn/core/evidence/write_evidence.dart';
import 'package:primelearn/core/evidence/write_level.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'write_gateway.g.dart';

/// 写网关实例。
@Riverpod(keepAlive: true)
WriteGateway writeGateway(Ref ref) => WriteGateway(WriteEvidence.defaults());

/// 统一写网关：真实写操作前检查证据级别，未达 `verified` 一律阻止。
class WriteGateway {
  /// 创建网关。
  const WriteGateway(this._evidence);

  final WriteEvidence _evidence;

  /// 检查 [endpoint] 是否允许执行 [behavior]；不允许时抛 [WriteBlocked]。
  void ensureAllowed(String endpoint, {required String behavior}) {
    final level = _evidence.levelOf(endpoint);
    if (level != WriteLevel.verified) {
      throw WriteBlocked('$behavior尚未通过协议验证（当前：${level.label}），已阻止写入');
    }
  }
}
