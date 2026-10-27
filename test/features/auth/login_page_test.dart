import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/core/ui/inline_notice.dart';
import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/core/session/session.dart';
import 'package:primelearn/features/auth/auth_providers.dart';
import 'package:primelearn/features/auth/domain/entities/bank_context.dart';
import 'package:primelearn/features/auth/domain/repositories/auth_repository.dart';
import 'package:primelearn/features/auth/presentation/pages/login_page.dart';

class _FailingAuthRepository implements AuthRepository {
  @override
  Future<void> ensureSessionCookie() async {}

  @override
  Future<Session> login({
    required String idCard,
    required String password,
  }) async =>
      throw const ApiException(kind: ApiErrorKind.protocol, message: '密码错误');

  @override
  Future<BankContext> fetchBankContext(String userId) async =>
      const BankContext();
}

void main() {
  Future<void> pumpLoginPage(WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginPage())),
    );
    await tester.pumpAndSettle();
  }

  TextField fieldAt(WidgetTester tester, int index) =>
      tester.widget<TextField>(find.byType(TextField).at(index));

  testWidgets('登录页渲染关键元素', (tester) async {
    await pumpLoginPage(tester);

    expect(find.byType(FlutterLogo), findsOneWidget);
    expect(find.text('Prime Learn'), findsOneWidget);
    expect(find.text('欢迎回来，请登录你的账号'), findsOneWidget);
    expect(find.text('身份证号'), findsOneWidget);
    expect(find.text('密码'), findsOneWidget);
    expect(find.text('记住账号'), findsOneWidget);
    expect(find.text('登 录'), findsOneWidget);
    expect(find.text('安全登录 · 仅限授权账号'), findsOneWidget);
    expect(find.text('© 2026 Prime Learn · 保留所有权利'), findsOneWidget);
  });

  testWidgets('未填身份证号：错误显示在字段下方，不弹 SnackBar', (tester) async {
    await pumpLoginPage(tester);

    await tester.tap(find.text('登 录'));
    await tester.pumpAndSettle();

    expect(fieldAt(tester, 0).decoration?.errorText, '请输入有效的 18 位身份证号');
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('身份证号合法但密码为空：密码字段报错', (tester) async {
    await pumpLoginPage(tester);

    await tester.enterText(find.byType(TextField).first, '610525199001011234');
    await tester.pump();
    await tester.tap(find.text('登 录'));
    await tester.pumpAndSettle();

    expect(fieldAt(tester, 0).decoration?.errorText, isNull);
    expect(fieldAt(tester, 1).decoration?.errorText, '请输入登录密码');
  });

  testWidgets('重新输入后字段错误消失', (tester) async {
    await pumpLoginPage(tester);

    await tester.tap(find.text('登 录'));
    await tester.pumpAndSettle();
    expect(fieldAt(tester, 0).decoration?.errorText, isNotNull);

    await tester.enterText(find.byType(TextField).first, '610525199001011234');
    await tester.pump();

    expect(fieldAt(tester, 0).decoration?.errorText, isNull);
  });

  testWidgets('登录失败：按钮上方显示内联提示，不弹 SnackBar', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_FailingAuthRepository()),
        ],
        child: const MaterialApp(home: LoginPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '610525199001011234');
    await tester.enterText(find.byType(TextField).at(1), 'wrong-password');
    await tester.pump();
    await tester.tap(find.text('登 录'));
    await tester.pumpAndSettle();

    expect(find.byType(InlineNotice), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(InlineNotice),
        matching: find.text('密码错误'),
      ),
      findsOneWidget,
    );
    expect(find.byType(SnackBar), findsNothing);

    // 重新编辑后提示消失。
    await tester.enterText(find.byType(TextField).at(1), 'another-password');
    await tester.pump();
    expect(find.byType(InlineNotice), findsNothing);
  });

  testWidgets('输入身份证号后出现清空按钮并可清空', (tester) async {
    await pumpLoginPage(tester);

    expect(find.byIcon(Icons.clear), findsNothing);
    await tester.enterText(find.byType(TextField).first, '610525199001011234');
    await tester.pump();

    expect(find.byIcon(Icons.clear), findsOneWidget);
    expect(find.byTooltip('清空身份证号'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump();

    expect(fieldAt(tester, 0).controller?.text, isEmpty);
  });

  testWidgets('密码可见性可切换', (tester) async {
    await pumpLoginPage(tester);

    expect(find.byIcon(Icons.visibility), findsOneWidget);
    expect(find.byTooltip('显示密码'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pump();

    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    expect(find.byTooltip('隐藏密码'), findsOneWidget);
  });

  testWidgets('记住账号可点击文字切换', (tester) async {
    await pumpLoginPage(tester);

    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);

    await tester.tap(find.text('记住账号'));
    await tester.pump();

    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
  });
}
