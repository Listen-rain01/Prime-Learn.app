import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/features/records/presentation/widgets/record_format.dart';

void main() {
  test('分数：整数不带小数位', () {
    expect(RecordFormat.score(100), '100');
    expect(RecordFormat.score(96.5), '96.5');
  });

  test('时长：小于 1 分钟按秒', () {
    expect(RecordFormat.duration(0), '0 秒');
    expect(RecordFormat.duration(59), '59 秒');
  });

  test('时长：小于 1 小时按分钟', () {
    expect(RecordFormat.duration(60), '1 分钟');
    expect(RecordFormat.duration(1793), '30 分钟');
    expect(RecordFormat.duration(3599), '60 分钟');
  });

  test('时长：整小时不带小数，其余保留一位', () {
    expect(RecordFormat.duration(3600), '1 小时');
    expect(RecordFormat.duration(7200), '2 小时');
    expect(RecordFormat.duration(154710), '43 小时');
    expect(RecordFormat.duration(5400), '1.5 小时');
  });
}
