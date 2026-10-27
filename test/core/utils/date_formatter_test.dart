import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/core/utils/date_formatter.dart';

void main() {
  test('dateTime 补零', () {
    expect(
      DateFormatter.dateTime(DateTime(2026, 1, 2, 3, 4)),
      '2026-01-02 03:04',
    );
  });

  test('date 只保留日期', () {
    expect(DateFormatter.date(DateTime(2026, 10, 27, 23, 59)), '2026-10-27');
  });

  test('空值返回空串', () {
    expect(DateFormatter.dateTime(null), '');
    expect(DateFormatter.date(null), '');
  });

  test('monthRange 返回本月 1 日到今天', () {
    final range = DateFormatter.monthRange(DateTime(2026, 10, 27, 9, 30));
    expect(range.begin, '2026-10-01');
    expect(range.end, '2026-10-27');
  });

  test('weekRange 返回本周一到周日', () {
    // 2026-10-28 是周三
    final range = DateFormatter.weekRange(DateTime(2026, 10, 28, 9, 30));
    expect(range.begin, '2026-10-26');
    expect(range.end, '2026-11-01');
  });
}
