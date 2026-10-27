/// 日期时间展示格式。
///
/// 仅做展示格式化；不引入 intl，避免为两行代码增加依赖。
abstract final class DateFormatter {
  /// `yyyy-MM-dd HH:mm`；空值返回空串。
  static String dateTime(DateTime? value) {
    if (value == null) return '';
    return '${date(value)} ${_two(value.hour)}:${_two(value.minute)}';
  }

  /// `yyyy-MM-dd`；空值返回空串。
  static String date(DateTime? value) {
    if (value == null) return '';
    return '${value.year}-${_two(value.month)}-${_two(value.day)}';
  }

  /// 当月区间：本月 1 日 → 今天，供排名接口的 `begin`/`end` 使用。
  static ({String begin, String end}) monthRange(DateTime now) {
    final begin = DateTime(now.year, now.month, 1);
    return (begin: date(begin), end: date(now));
  }

  /// 本周区间：周一 → 周日（学习时长榜的默认口径）。
  static ({String begin, String end}) weekRange(DateTime now) {
    final monday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    return (begin: date(monday), end: date(sunday));
  }

  static String _two(int value) => value.toString().padLeft(2, '0');
}
