import 'package:primelearn/core/session/session.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_store.g.dart';

/// 会话存储：登录态只放内存，重启后需重新登录。
@Riverpod(keepAlive: true)
class SessionStore extends _$SessionStore {
  @override
  Session? build() => null;

  /// 保存登录成功后的会话。
  void save(Session session) => state = session;

  /// 清除会话（退出登录或会话失效）。
  void clear() => state = null;
}
