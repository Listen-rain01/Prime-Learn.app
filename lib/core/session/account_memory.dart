import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_memory.g.dart';

/// 记住的账号（仅身份证号，存 secure storage，不存密码）。
class AccountMemory {
  /// 创建存储包装；测试可注入 fake。
  AccountMemory({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const String _idCardKey = 'primelearn.remembered_id_card';
  final FlutterSecureStorage _storage;

  /// 读取记住的身份证号；失败时视为未记住。
  Future<String?> read() async {
    try {
      return await _storage.read(key: _idCardKey);
    } on Object {
      return null;
    }
  }

  /// 记住身份证号。
  Future<void> save(String idCard) async {
    try {
      await _storage.write(key: _idCardKey, value: idCard);
    } on Object {
      // 存储失败不阻塞登录流程。
    }
  }

  /// 清除记住的身份证号。
  Future<void> clear() async {
    try {
      await _storage.delete(key: _idCardKey);
    } on Object {
      // 同上。
    }
  }
}

/// 账号记忆存储实例。
@Riverpod(keepAlive: true)
AccountMemory accountMemory(Ref ref) => AccountMemory();

/// 已记住的身份证号（登录页用于预填）。
@riverpod
Future<String?> rememberedAccount(Ref ref) =>
    ref.watch(accountMemoryProvider).read();
