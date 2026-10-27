import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/features/settings/data/parsers/bank_catalog_parser.dart';

void main() {
  const styleParser = BankStyleParser();
  const optionParser = BankOptionParser();

  test('解析分类字段', () {
    final styles = styleParser.parse('''
{"success": true, "data": [
  {"Level": 1, "Year": null, "DepartmentId": "1", "ExamTypeStyleId": 0, "StyleName": "股份安管人员", "Code": "0001"}
]}''');

    expect(styles.single.level, 1);
    expect(styles.single.styleId, '0');
    expect(styles.single.name, '股份安管人员');
    expect(styles.single.code, '0001');
    expect(styles.single.departmentId, '1');
  });

  test('解析年份层级', () {
    final styles = styleParser.parse(
      '''
{"success": true, "data": [{"Level": 3, "Year": "2022", "ExamTypeStyleId": 0, "StyleName": "2022年"}]}''',
    );
    expect(styles.single.year, '2022');
    expect(styles.single.level, 3);
  });

  test('解析题库列表', () {
    final options = optionParser.parse('''
{"success": true, "data": [
  {"ExamTypeId": "3c3e249a-0000-0000-0000-000000000001", "ExamTypeName": "刑法修正案十一", "QuestionCount": 20, "StateName": "正常"}
]}''');

    expect(options.single.id, '3c3e249a-0000-0000-0000-000000000001');
    expect(options.single.name, '刑法修正案十一');
    expect(options.single.questionCount, 20);
    expect(options.single.stateName, '正常');
  });

  test('success=false 透传服务端文案', () {
    expect(
      () => styleParser.parse('{"success": false, "message": "无权限"}'),
      throwsA(isA<ApiException>().having((e) => e.message, 'message', '无权限')),
    );
  });

  test('空响应抛协议异常', () {
    expect(
      () => optionParser.parse(''),
      throwsA(
        isA<ApiException>().having((e) => e.message, 'message', '服务器返回空响应'),
      ),
    );
  });
}
