import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/features/stats/presentation/widgets/record_format.dart';

void main() {
  test('分数：整数不带小数位', () {
    expect(RecordFormat.score(100), '100');
    expect(RecordFormat.score(96.5), '96.5');
  });

  test('时长：小于 1 分钟按秒', () {
    expect(RecordFormat.duration(0), '0 秒');
    expect(RecordFormat.duration(59), '59 秒');
  });

  test('时长：三段式「X小时Y分Z秒」，高位为 0 时省略', () {
    // 平台样本：18270 秒 → 5小时4分30秒（18000=5时 + 270=4分30秒）
    expect(RecordFormat.duration(18270), '5 小时4 分30 秒');
    expect(RecordFormat.duration(7200), '2 小时');
    expect(RecordFormat.duration(5400), '1 小时30 分');
    expect(RecordFormat.duration(90), '1 分30 秒');
    expect(RecordFormat.duration(60), '1 分');
    expect(RecordFormat.duration(61), '1 分1 秒');
    expect(RecordFormat.duration(3600), '1 小时');
    expect(RecordFormat.duration(3661), '1 小时1 分1 秒');
  });
}
