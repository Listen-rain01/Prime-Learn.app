import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/core/session/session_detector.dart';

void main() {
  test('HTML 登录页判为会话失效信号', () {
    expect(
      SessionDetector.looksLikeLoginPage(
        'text/html; charset=utf-8',
        '<html><body><form action="/login">登录</form></body></html>',
      ),
      isTrue,
    );
  });

  test('JSON 响应不是登录页', () {
    expect(
      SessionDetector.looksLikeLoginPage('application/json', '{"ok":true}'),
      isFalse,
    );
  });

  test('HTML 但非登录页不算会话失效', () {
    expect(
      SessionDetector.looksLikeLoginPage(
        'text/html',
        '<html><body>404</body></html>',
      ),
      isFalse,
    );
  });

  test('缺少 content-type 或 body 时不判定', () {
    expect(
      SessionDetector.looksLikeLoginPage(null, '<html>login</html>'),
      isFalse,
    );
    expect(SessionDetector.looksLikeLoginPage('text/html', null), isFalse);
  });
}
