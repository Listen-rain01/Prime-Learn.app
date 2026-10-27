import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/features/auth/presentation/pages/login_page.dart';

void main() {
  testWidgets('登录页渲染关键元素', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginPage())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Prime Learn'), findsOneWidget);
    expect(find.text('欢迎回来，请登录你的账号'), findsOneWidget);
    expect(find.text('身份证号'), findsOneWidget);
    expect(find.text('密码'), findsOneWidget);
    expect(find.text('记住账号'), findsOneWidget);
    expect(find.text('登 录'), findsOneWidget);
    expect(find.text('安全登录 · 仅限授权账号'), findsOneWidget);
  });

  testWidgets('空表单提交显示校验错误', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginPage())),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('登 录'));
    await tester.pumpAndSettle();

    expect(find.text('请输入身份证号和密码'), findsOneWidget);
  });

  testWidgets('密码可见性可切换', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginPage())),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pump();

    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
  });
}
