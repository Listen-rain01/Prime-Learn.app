import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/features/auth/presentation/pages/login_page.dart';

void main() {
  Future<void> pumpLoginPage(WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginPage())),
    );
    await tester.pumpAndSettle();
  }

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

  testWidgets('未填身份证号提交显示 SnackBar', (tester) async {
    await pumpLoginPage(tester);

    await tester.tap(find.text('登 录'));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(SnackBar),
        matching: find.text('请输入有效的 18 位身份证号'),
      ),
      findsOneWidget,
    );

    // 让 SnackBar 计时器走完，避免测试结束时仍有挂起计时器。
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('身份证号合法但密码为空时提示请输入登录密码', (tester) async {
    await pumpLoginPage(tester);

    await tester.enterText(find.byType(TextField).first, '610525199001011234');
    await tester.pump();
    await tester.tap(find.text('登 录'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(SnackBar),
        matching: find.text('请输入登录密码'),
      ),
      findsOneWidget,
    );

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
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

    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller?.text,
      isEmpty,
    );
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

    final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
    expect(checkbox.value, isFalse);

    await tester.tap(find.text('记住账号'));
    await tester.pump();

    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
  });
}
