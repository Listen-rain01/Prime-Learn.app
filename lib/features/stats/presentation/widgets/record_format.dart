/// 分数与时长展示格式。
abstract final class RecordFormat {
  /// 分数：整数不带小数位，其余保留一位。
  static String score(double value) => value == value.roundToDouble()
      ? value.round().toString()
      : value.toStringAsFixed(1);

  /// 时长（秒）：三段式「X小时Y分Z秒」，与平台网页一致。
  ///
  /// 平台页面把 `AllCount`（秒）渲染为 `时/分/秒`（如 18270 → 5小时4分30秒），
  /// 客户端按同样口径展示，保证与网页数字一致；高位为 0 时省略。
  static String duration(double seconds) {
    final total = seconds.round();
    final hours = total ~/ 3600;
    final minutes = (total % 3600) ~/ 60;
    final secs = total % 60;

    final parts = <String>[
      if (hours > 0) '$hours 小时',
      if (minutes > 0) '$minutes 分',
      if (secs > 0) '$secs 秒',
    ];
    if (parts.isEmpty) return '0 秒';
    return parts.join('');
  }
}
