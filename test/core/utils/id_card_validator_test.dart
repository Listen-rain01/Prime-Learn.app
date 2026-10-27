import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/core/utils/id_card_validator.dart';

void main() {
  test('18 位数字身份证号有效', () {
    expect(IdCardValidator.isValid('610525199001011234'), isTrue);
  });

  test('末位 X/x 有效', () {
    expect(IdCardValidator.isValid('61052519900101123X'), isTrue);
    expect(IdCardValidator.isValid('61052519900101123x'), isTrue);
  });

  test('忽略首尾空格', () {
    expect(IdCardValidator.isValid(' 610525199001011234 '), isTrue);
  });

  test('15 位 / 17 位 / 19 位均无效', () {
    expect(IdCardValidator.isValid('610525199001011'), isFalse);
    expect(IdCardValidator.isValid('61052519900101123'), isFalse);
    expect(IdCardValidator.isValid('6105251990010112345'), isFalse);
  });

  test('非数字字符无效', () {
    expect(IdCardValidator.isValid('61052519900101123A'), isFalse);
    expect(IdCardValidator.isValid('61052519900101123-'), isFalse);
  });

  test('空串无效', () {
    expect(IdCardValidator.isValid(''), isFalse);
  });
}
