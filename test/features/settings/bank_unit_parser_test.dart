import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/features/settings/data/parsers/bank_unit_parser.dart';

/// 压缩成一行，贴近真实页面里的 `vData`。
const _html = '''
<html><body>
<script type="text/javascript">
var vData={"Code4":"0008","Code":"0008","Units":"1,股份,股份,股份^a1b2c3d4-0000-0000-0000-000000000001,澄合矿业,澄合矿业,^a1b2c3d4-0000-0000-0000-000000000002,澄合矿业/西卓煤矿,西卓煤矿,chxzmk","Title":"选择学习题库"};
var l_Units = vData["Units"];
</script>
</body></html>''';

void main() {
  const parser = BankUnitParser();

  test('解析 vData.Units 的单位', () {
    final units = parser.parse(_html);
    expect(units, hasLength(3));
    expect(units[0].id, '1');
    expect(units[0].name, '股份');
    expect(units[1].name, '澄合矿业');
    expect(units[2].name, '西卓煤矿');
  });

  test('缺少 vData 时抛协议异常', () {
    expect(
      () => parser.parse('<html></html>'),
      throwsA(
        isA<ApiException>().having((e) => e.message, 'message', '题库单位数据缺失'),
      ),
    );
  });

  test('单位字段为空时抛协议异常', () {
    expect(
      () => parser.parse('<script>var vData={"Units":""};</script>'),
      throwsA(
        isA<ApiException>().having((e) => e.message, 'message', '题库单位数据为空'),
      ),
    );
  });
}
