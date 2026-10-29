import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/features/settings/data/parsers/person_profile_parser.dart';

String _html(String vData) =>
    '''
<!DOCTYPE html>
<html><head><title>个人信息</title></head>
<body>
  <div class="person-info">基本信息</div>
  <script>
    var vData = $vData;
  </script>
</body></html>''';

void main() {
  const parser = PersonProfileParser();

  test('解析 vData 中的个人字段', () {
    final dto = parser.parse(
      _html('''
{
  "pid": "00000000-0000-0000-0000-000000000001",
  "sstype": "0",
  "DepartmentId": "00000000-0000-0000-0000-000000000002",
  "pnum": "E1001",
  "pname": "张小赞",
  "idcard": "610525199001011238",
  "punit": "澄合矿业/西卓煤矿/设备维修队",
  "tel": "13812345678",
  "address": "陕西省澄城县某村一组",
  "AllowChangeCurriculumVitae": false
}'''),
    );

    expect(dto.employeeNo, 'E1001');
    expect(dto.name, '张小赞');
    expect(dto.idCard, '610525199001011238');
    expect(dto.department, '澄合矿业/西卓煤矿/设备维修队');
    expect(dto.phone, '13812345678');
    expect(dto.address, '陕西省澄城县某村一组');
    expect(dto.departmentId, '00000000-0000-0000-0000-000000000002');
  });

  test('字符串内含花括号也能正确截取 vData', () {
    final dto = parser.parse(
      _html('{"pname":"张三","address":"某路{1号}","pnum":"E1"}'),
    );
    expect(dto.name, '张三');
    expect(dto.address, '某路{1号}');
  });

  test('缺少 vData 抛协议异常', () {
    expect(
      () => parser.parse('<html><body>登录</body></html>'),
      throwsA(
        isA<ApiException>().having((e) => e.message, 'message', '个人信息响应缺少数据'),
      ),
    );
  });

  test('空响应抛协议异常', () {
    expect(
      () => parser.parse(''),
      throwsA(
        isA<ApiException>().having((e) => e.message, 'message', '服务器返回空响应'),
      ),
    );
  });

  test('vData 不是合法 JSON 时抛协议异常', () {
    expect(
      () => parser.parse(_html('{bad json}')),
      throwsA(
        isA<ApiException>().having((e) => e.message, 'message', '个人信息数据格式异常'),
      ),
    );
  });

  test('姓名为空且身份证为空时抛协议异常', () {
    expect(
      () => parser.parse(_html('{"pnum":"E1"}')),
      throwsA(
        isA<ApiException>().having((e) => e.message, 'message', '个人信息为空'),
      ),
    );
  });

  test('字段缺失时返回空字符串', () {
    final dto = parser.parse(_html('{"pname":"张三"}'));
    expect(dto.name, '张三');
    expect(dto.employeeNo, '');
    expect(dto.idCard, '');
    expect(dto.department, '');
    expect(dto.phone, '');
    expect(dto.address, '');
    expect(dto.departmentId, isNull);
  });
}
