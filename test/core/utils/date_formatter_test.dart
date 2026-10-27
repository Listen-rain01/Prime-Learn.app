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
}
