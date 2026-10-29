import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/core/utils/redactor.dart';

void main() {
  test('身份证保留前 6 后 4', () {
    expect(Redactor.idCard('610525199001011238'), '610525******1238');
  });

  test('短文本整体脱敏', () {
    expect(Redactor.idCard('123'), '***');
    expect(Redactor.idCard(''), '***');
  });

  test('首尾空格不影响脱敏结果', () {
    expect(Redactor.idCard(' 610525199001011238 '), '610525******1238');
  });

  test('密码等敏感值替换为占位符', () {
    expect(Redactor.secret('p@ssw0rd'), '***');
    expect(Redactor.secret(''), '');
  });

  test('手机号保留前 3 后 4', () {
    expect(Redactor.phone('13812345678'), '138****5678');
    expect(Redactor.phone(' 13812345678 '), '138****5678');
  });

  test('过短的手机号整体脱敏', () {
    expect(Redactor.phone('123'), '***');
    expect(Redactor.phone(''), '***');
  });
}
