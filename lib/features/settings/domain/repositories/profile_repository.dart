import 'dart:typed_data';

import 'package:primelearn/features/settings/domain/entities/person_profile.dart';

/// 个人信息数据接口。
abstract interface class ProfileRepository {
  /// 读取个人基础资料；失败抛 `ApiException`。
  Future<PersonProfile> fetchProfile(String userId);

  /// 读取头像图片字节；失败抛 `ApiException`。
  Future<Uint8List> fetchAvatar(String userId, String departmentId);
}
