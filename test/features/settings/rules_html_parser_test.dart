import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/features/settings/data/parsers/rules_html_parser.dart';

void main() {
  const parser = RulesHtmlParser();

  test('从 HTML 提取规则文本', () {
    const html = '''
<html><head><style>.a{color:red}</style></head>
<body>
  <div class="title">积分规则</div>
  <ul>
    <li>签到：每日签到1分，连续登录每日多1分，每日最多3分。</li>
    <li>手机考试：每日每次及格计6分，每日最多8分。</li>
  </ul>
  <script>var x = 1;</script>
</body></html>''';

    final text = parser.parse(html);
    expect(text, contains('积分规则'));
    expect(text, contains('每日签到1分'));
    expect(text, contains('每日最多8分'));
    expect(text, isNot(contains('color:red')));
    expect(text, isNot(contains('var x')));
    expect(text, isNot(contains('<li>')));
  });

  test('解码 HTML 实体', () {
    expect(parser.parse('<p>A&nbsp;&amp;&nbsp;B</p>'), 'A & B');
  });

  test('空段落与缩进被压缩为最多一个空行', () {
    const html = '''
<div>积分规则</div>
<p>&nbsp;</p>
<p>&nbsp;</p>
<div>签到：每日签到1分</div>
<p>&nbsp;</p>
<p>&nbsp;</p>
<div>模拟考试：每日最多8分</div>''';

    final text = parser.parse(html);
    expect(RegExp(r'\n{3,}').hasMatch(text), isFalse);
    expect(text, contains('积分规则\n\n签到'));
    expect(text, contains('签到：每日签到1分\n\n模拟考试'));
  });

  test('空 HTML 抛协议异常', () {
    expect(
      () => parser.parse('  '),
      throwsA(
        isA<ApiException>().having((e) => e.message, 'message', '服务器返回空响应'),
      ),
    );
  });

  test('只有标签没有文本时抛协议异常', () {
    expect(
      () => parser.parse('<div><br/></div>'),
      throwsA(
        isA<ApiException>().having((e) => e.message, 'message', '积分规则为空'),
      ),
    );
  });
}
