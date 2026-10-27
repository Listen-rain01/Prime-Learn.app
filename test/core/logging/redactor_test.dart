import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/core/logging/redactor.dart';

void main() {
  test('身份证保留前 6 后 4', () {
    expect(Redactor.idCard('610525199001011234'), '610525******1234');
  });

  test('短文本整体脱敏', () {
    expect(Redactor.idCard('123'), '***');
    expect(Redactor.idCard(''), '***');
  });

  test('首尾空格不影响脱敏结果', () {
    expect(Redactor.idCard(' 610525199001011234 '), '610525******1234');
  });

  test('密码等敏感值替换为占位符', () {
    expect(Redactor.secret('p@ssw0rd'), '***');
    expect(Redactor.secret(''), '');
  });
}
