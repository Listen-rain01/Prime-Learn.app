import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/core/utils/id_card_validator.dart';

/// 按 GB 11643 给 17 位前缀补上校验位，避免手写号码算错而误判测试结论。
String _withCheckDigit(String first17) {
  const weights = [7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2];
  const codes = ['1', '0', 'X', '9', '8', '7', '6', '5', '4', '3', '2'];
  var sum = 0;
  for (var i = 0; i < 17; i++) {
    sum += int.parse(first17[i]) * weights[i];
  }
  return '$first17${codes[sum % 11]}';
}

void main() {
  group('合法号码', () {
    test('18 位数字且校验位正确', () {
      // 校验位：前 17 位加权和 213 % 11 = 4 → '8'
      expect(IdCardValidator.isValid('610525199001011238'), isTrue);
    });

    test('末位 X 且校验位正确', () {
      // 前 17 位加权和 % 11 = 2 → 'X'
      expect(IdCardValidator.isValid('61052519900101114X'), isTrue);
    });

    test('末位小写 x 同样有效', () {
      expect(IdCardValidator.isValid('61052519900101114x'), isTrue);
    });

    test('忽略首尾空格', () {
      expect(IdCardValidator.isValid(' 610525199001011238 '), isTrue);
    });
  });

  group('校验位', () {
    test('末位数字错误时无效（旧样例 1234，正确应为 1238）', () {
      expect(IdCardValidator.isValid('610525199001011234'), isFalse);
    });

    test('末位应为 X 却写成数字时无效', () {
      expect(IdCardValidator.isValid('610525199001011149'), isFalse);
    });

    test('末位应为数字却写成 X 时无效', () {
      expect(IdCardValidator.isValid('61052519900101123X'), isFalse);
    });

    test('中间任意一位改动都会破坏校验位', () {
      expect(IdCardValidator.isValid('610525199101011238'), isFalse);
    });
  });

  group('出生日期', () {
    test('月份 13 无效', () {
      expect(IdCardValidator.isValid('610525199013011238'), isFalse);
    });

    test('2 月 30 日无效', () {
      expect(IdCardValidator.isValid('610525199002301238'), isFalse);
    });

    test('早于 1900 年无效', () {
      expect(IdCardValidator.isValid('610525189901011238'), isFalse);
    });

    test('未来日期无效', () {
      final future = DateTime.now().year + 1;
      final month = DateTime.now().month.toString().padLeft(2, '0');
      final day = DateTime.now().day.toString().padLeft(2, '0');
      expect(IdCardValidator.isValid('610525$future$month${day}1238'), isFalse);
    });
  });

  group('地址码（规范要求的 1–6 位行政区划）', () {
    test('省级前缀不存在时无效（省 99 / 省 00）', () {
      // 校验位已按 GB 算对，确保拒绝原因是地址码而非校验位。
      expect(
        IdCardValidator.isValid(_withCheckDigit('99010119900307123')),
        isFalse,
      );
      expect(
        IdCardValidator.isValid(_withCheckDigit('00000019900307123')),
        isFalse,
      );
    });

    test('港澳台与境外省级前缀一律无效（平台只接受大陆号码）', () {
      for (final prefix in ['71', '81', '82', '83', '91']) {
        final id = _withCheckDigit('${prefix}000119900307123');
        expect(
          IdCardValidator.isValid(id),
          isFalse,
          reason: '省级前缀 $prefix 不属于大陆 31 个省级区划（$id）',
        );
      }
    });

    test('大陆 31 个省级前缀全部被接受', () {
      const mainland = [
        '11',
        '12',
        '13',
        '14',
        '15',
        '21',
        '22',
        '23',
        '31',
        '32',
        '33',
        '34',
        '35',
        '36',
        '37',
        '41',
        '42',
        '43',
        '44',
        '45',
        '46',
        '50',
        '51',
        '52',
        '53',
        '54',
        '61',
        '62',
        '63',
        '64',
        '65',
      ];
      expect(mainland, hasLength(31), reason: '大陆省级区划应为 31 个');
      for (final prefix in mainland) {
        final id = _withCheckDigit('${prefix}010119900307123');
        expect(
          IdCardValidator.isValid(id),
          isTrue,
          reason: '省级前缀 $prefix 应被接受（$id）',
        );
      }
    });
  });

  group('顺序码（规范要求的 15–17 位）', () {
    test('规范未禁止 000，且历史数据存在，因此不拒绝', () {
      expect(
        IdCardValidator.isValid(_withCheckDigit('11010119900307000')),
        isTrue,
      );
    });
  });

  group('闰年与日期边界', () {
    test('闰年 2 月 29 日有效', () {
      expect(
        IdCardValidator.isValid(_withCheckDigit('11010119920229123')),
        isTrue,
      );
    });

    test('非闰年 2 月 29 日无效', () {
      expect(
        IdCardValidator.isValid(_withCheckDigit('11010119900229123')),
        isFalse,
      );
    });

    test('1900-01-01 是允许的下边界', () {
      expect(
        IdCardValidator.isValid(_withCheckDigit('11010119000101123')),
        isTrue,
      );
    });
  });

  group('长度与字符集', () {
    test('15 位 / 17 位 / 19 位均无效', () {
      expect(IdCardValidator.isValid('610525199001011'), isFalse);
      expect(IdCardValidator.isValid('61052519900101123'), isFalse);
      expect(IdCardValidator.isValid('6105251990010112385'), isFalse);
    });

    test('非数字字符无效', () {
      expect(IdCardValidator.isValid('61052519900101123A'), isFalse);
      expect(IdCardValidator.isValid('61052519900101123-'), isFalse);
    });

    test('空串无效', () {
      expect(IdCardValidator.isValid(''), isFalse);
    });
  });
}
