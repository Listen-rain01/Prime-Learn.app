import 'dart:typed_data';

import 'package:primelearn/features/settings/data/parsers/person_profile_parser.dart';
import 'package:primelearn/features/settings/data/services/profile_api.dart';
import 'package:primelearn/features/settings/domain/entities/person_profile.dart';
import 'package:primelearn/features/settings/domain/repositories/profile_repository.dart';

/// 个人信息仓储实现：HTML → DTO → Entity。
class ProfileRepositoryImpl implements ProfileRepository {
  /// 创建仓储实现。
  ProfileRepositoryImpl(this._api);

  final ProfileApi _api;
  static const PersonProfileParser _parser = PersonProfileParser();

  @override
  Future<PersonProfile> fetchProfile(String userId) async {
    final html = await _api.fetchBaseInfo(userId);
    final dto = _parser.parse(html);
    return PersonProfile(
      employeeNo: dto.employeeNo,
      name: dto.name,
      idCard: dto.idCard,
      department: dto.department,
      phone: dto.phone,
      address: dto.address,
      departmentId: dto.departmentId,
    );
  }

  @override
  Future<Uint8List> fetchAvatar(String userId, String departmentId) =>
      _api.fetchAvatar(userId, departmentId);
}
