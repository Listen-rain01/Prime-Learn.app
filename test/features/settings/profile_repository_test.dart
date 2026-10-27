import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:primelearn/features/settings/data/repositories/profile_repository_impl.dart';
import 'package:primelearn/features/settings/data/services/profile_api.dart';

class _MockProfileApi extends Mock implements ProfileApi {}

const _validHtml = '''
<html><body>
<script>
var vData = {
  "DepartmentId": "00000000-0000-0000-0000-000000000002",
  "pnum": "E1001",
  "pname": "张小赞",
  "idcard": "610525199001011234",
  "punit": "某单位",
  "tel": "13812345678",
  "address": "某地址"
};
</script>
</body></html>''';

void main() {
  late _MockProfileApi api;

  setUp(() {
    api = _MockProfileApi();
  });

  test('头像路径对 did/pid 做 Esdt 编码且不二次转义', () {
    final path = ProfileApi.avatarPath('123', '456');
    expect(
      path,
      '/ArchiveManger/D_PersonManager/GetPersonPhoto'
      '?did=525354%5E2%2C2%2C2&pid=495051%5E2%2C2%2C2',
    );
    expect(path, isNot(contains('%25')));
  });

  test('解析个人信息（不含头像，头像单独拉取）', () async {
    when(() => api.fetchBaseInfo(any())).thenAnswer((_) async => _validHtml);

    final profile = await ProfileRepositoryImpl(api).fetchProfile('u1');

    expect(profile.name, '张小赞');
    expect(profile.employeeNo, 'E1001');
    expect(profile.departmentId, '00000000-0000-0000-0000-000000000002');
    verifyNever(() => api.fetchAvatar(any(), any()));
  });

  test('fetchAvatar 透传图片字节', () async {
    final bytes = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0x00]);
    when(() => api.fetchAvatar(any(), any())).thenAnswer((_) async => bytes);

    final result = await ProfileRepositoryImpl(api).fetchAvatar('u1', 'd1');

    expect(result, bytes);
  });
}
