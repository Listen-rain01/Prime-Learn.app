/// 分数与时长展示格式。
abstract final class RecordFormat {
  /// 分数：整数不带小数位，其余保留一位。
  static String score(double value) => value == value.roundToDouble()
      ? value.round().toString()
      : value.toStringAsFixed(1);

  /// 时长（秒）：小于 1 分钟按秒，小于 1 小时按分钟，其余按小时（保留一位）。
  static String duration(double seconds) {
    final total = seconds.round();
    if (total < 60) return '$total 秒';
    if (total < 3600) return '${(total / 60).round()} 分钟';
    final hours = total / 3600;
    final text = hours.toStringAsFixed(1);
    return '${text.endsWith('.0') ? text.substring(0, text.length - 2) : text} 小时';
  }
}
