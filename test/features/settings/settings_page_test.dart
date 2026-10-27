import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/core/session/session.dart';
import 'package:primelearn/core/session/session_store.dart';
import 'package:primelearn/features/settings/domain/repositories/settings_repository.dart';
import 'package:primelearn/features/settings/presentation/pages/settings_page.dart';
import 'package:primelearn/features/settings/settings_providers.dart';

class _FakeSettingsRepository implements SettingsRepository {
  @override
  Future<String> fetchRulesText(String userId) async => '积分规则\n签到：每日签到1分';
}

void main() {
  testWidgets('我的页展示账号、入口与退出', (tester) async {
    final container = ProviderContainer(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(_FakeSettingsRepository()),
      ],
    );
    addTearDown(container.dispose);
    container
        .read(sessionStoreProvider.notifier)
        .save(const Session(userId: 'u1', userName: '张小赞', bankName: '题库A'));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: SettingsPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('张小赞'), findsOneWidget);
    expect(find.text('当前题库：题库A'), findsOneWidget);
    expect(find.text('积分规则'), findsOneWidget);
    expect(find.text('题库切换'), findsOneWidget);
    expect(find.text('待接入'), findsOneWidget);
    expect(find.text('退出登录'), findsOneWidget);
  });
}
