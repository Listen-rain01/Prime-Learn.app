import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_memory.g.dart';

/// 记住的账号（身份证号 + 密码 + 姓名）。
///
/// 密码同样存 secure storage（用户已确认接受），用于登录页预填；
/// 不进入日志、不进入 `shared_preferences`。
class SavedAccount {
  /// 创建账号。
  const SavedAccount({
    required this.idCard,
    required this.password,
    required this.userName,
  });

  /// 从 JSON 构造；字段缺失按空串兜底。
  factory SavedAccount.fromJson(Map<String, dynamic> json) => SavedAccount(
    idCard: json['idCard']?.toString() ?? '',
    password: json['password']?.toString() ?? '',
    userName: json['userName']?.toString() ?? '',
  );

  /// 身份证号。
  final String idCard;

  /// 密码。
  final String password;

  /// 姓名（账号列表展示用）。
  final String userName;

  /// 序列化为 JSON。
  Map<String, dynamic> toJson() => {
    'idCard': idCard,
    'password': password,
    'userName': userName,
  };
}

/// 账号记忆：存一组账号（按「最近使用」排序，最新的在前）。
///
/// 存储为 secure storage 单个 JSON key，密码与身份证号均加密落盘。
class AccountMemory {
  /// 创建存储包装；测试可注入 fake。
  AccountMemory({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const String _accountsKey = 'primelearn.remembered_accounts';
  final FlutterSecureStorage _storage;

  /// 读取全部账号（最新在前）；失败视为空列表。
  Future<List<SavedAccount>> readAll() async {
    try {
      final raw = await _storage.read(key: _accountsKey);
      if (raw == null || raw.isEmpty) return const [];
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return [
        for (final item in decoded)
          if (item is Map<String, dynamic>) SavedAccount.fromJson(item),
      ];
    } on Object {
      return const [];
    }
  }

  /// 读取最近登录的账号；无账号返回 null。
  Future<SavedAccount?> readRecent() async {
    final accounts = await readAll();
    return accounts.isEmpty ? null : accounts.first;
  }

  /// 保存账号：已存在则更新并移到最前（最近使用），否则新增到最前。
  Future<void> save(SavedAccount account) async {
    final accounts = await readAll();
    final without = accounts
        .where((item) => item.idCard != account.idCard)
        .toList(growable: false);
    final next = [account, ...without];
    await _write(next);
  }

  /// 删除指定身份证号的账号（只删本地凭据，不碰平台）。
  Future<void> remove(String idCard) async {
    final accounts = await readAll();
    final next = accounts
        .where((item) => item.idCard != idCard)
        .toList(growable: false);
    await _write(next);
  }

  /// 清空全部账号。
  Future<void> clear() async {
    try {
      await _storage.delete(key: _accountsKey);
    } on Object {
      // 删除失败不阻塞。
    }
  }

  Future<void> _write(List<SavedAccount> accounts) async {
    try {
      final encoded = jsonEncode([
        for (final account in accounts) account.toJson(),
      ]);
      await _storage.write(key: _accountsKey, value: encoded);
    } on Object {
      // 存储失败不阻塞登录流程。
    }
  }
}

/// 账号记忆存储实例。
@Riverpod(keepAlive: true)
AccountMemory accountMemory(Ref ref) => AccountMemory();

/// 已记住的账号列表（登录页账号切换用）。
@riverpod
Future<List<SavedAccount>> savedAccounts(Ref ref) =>
    ref.watch(accountMemoryProvider).readAll();

/// 最近登录的账号（登录页预填）。
@riverpod
Future<SavedAccount?> rememberedAccount(Ref ref) =>
    ref.watch(accountMemoryProvider).readRecent();
