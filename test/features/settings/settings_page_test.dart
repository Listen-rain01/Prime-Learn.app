import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/core/session/session.dart';
import 'package:primelearn/core/session/session_store.dart';
import 'package:primelearn/features/settings/bank_providers.dart';
import 'package:primelearn/features/settings/domain/entities/bank_catalog.dart';
import 'package:primelearn/features/settings/domain/entities/person_profile.dart';
import 'package:primelearn/features/settings/domain/repositories/profile_repository.dart';
import 'package:primelearn/features/settings/presentation/pages/settings_page.dart';
import 'package:primelearn/features/settings/profile_providers.dart';

/// 1×1 PNG，仅用于让 `MemoryImage` 能在测试里正常解码。
final Uint8List _pngBytes = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAA'
  'DUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
);

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository(this.profile);

  final PersonProfile profile;

  @override
  Future<PersonProfile> fetchProfile(String userId) async => profile;

  @override
  Future<Uint8List> fetchAvatar(String userId, String departmentId) async =>
      Uint8List(0);
}

const _profile = PersonProfile(
  employeeNo: 'E1001',
  name: '张小赞',
  idCard: '610525199001011234',
  department: '澄合矿业/西卓煤矿/设备维修队',
  phone: '13812345678',
  address: '陕西省澄城县某村一组',
);

Future<void> _pumpSettings(
  WidgetTester tester,
  PersonProfile profile, {
  Uint8List? avatar,
  BankPreset? preset,
}) async {
  final container = ProviderContainer(
    overrides: [
      profileRepositoryProvider.overrideWithValue(
        _FakeProfileRepository(profile),
      ),
      // 头像单独取；测试里不触网。
      profileAvatarProvider.overrideWith((ref) async => avatar),
      // 预设读本地存储；测试里不触插件。
      bankPresetProvider.overrideWith((ref) async => preset),
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
}

void main() {
  testWidgets('我的页展示账号、个人信息（脱敏）与退出', (tester) async {
    await _pumpSettings(tester, _profile);

    expect(find.text('张小赞'), findsOneWidget);
    expect(find.text('工号 E1001'), findsOneWidget);
    expect(find.text('当前题库：题库A'), findsNothing);
    expect(find.text('个人信息'), findsOneWidget);
    expect(find.text('工号'), findsNothing);
    expect(find.text('身份证号'), findsOneWidget);
    expect(find.text('610525******1234'), findsOneWidget);
    expect(find.text('610525199001011234'), findsNothing);
    expect(find.text('工作单位'), findsOneWidget);
    expect(find.text('澄合矿业/西卓煤矿/设备维修队'), findsOneWidget);
    expect(find.text('联系方式'), findsOneWidget);
    expect(find.text('138****5678'), findsOneWidget);
    expect(find.text('13812345678'), findsNothing);
    expect(find.text('家庭地址'), findsOneWidget);
    expect(find.text('题库预设'), findsOneWidget);
    expect(find.text('当前题库'), findsOneWidget);
    expect(find.text('目标题库'), findsOneWidget);
    expect(find.text('点击选择目标题库'), findsOneWidget);
    expect(find.text('未设置'), findsNWidgets(2));
    expect(find.text('设置'), findsNothing);
    expect(find.text('退出登录'), findsOneWidget);
  });

  testWidgets('预设卡片展示当前题库、目标试卷与题型', (tester) async {
    await _pumpSettings(
      tester,
      _profile,
      preset: const BankPreset(
        bankId: 'bank-b',
        bankName: '2025陕西煤业煤矿安全规程',
        questionCount: 3985,
        singleCount: 1554,
        multipleCount: 793,
        judgeCount: 1638,
        paperCount: 2,
        paperId: 'p2',
        paperName: '2025安全规程模拟卷',
        paperTotalScore: 100,
        paperPassingGrade: 80,
      ),
    );

    expect(find.text('题库A'), findsOneWidget);
    expect(find.text('2025陕西煤业煤矿安全规程'), findsOneWidget);
    expect(find.text('2025安全规程模拟卷（100 分 / 及格 80） · 共 2 份'), findsOneWidget);
    expect(find.text('总题数 3985 · 单选 1554 · 多选 793 · 判断 1638'), findsOneWidget);
    expect(find.text('待切换'), findsOneWidget);
  });

  testWidgets('旧预设没有试卷 ID 时提示补选', (tester) async {
    await _pumpSettings(
      tester,
      _profile,
      preset: const BankPreset(
        bankId: 'bank-b',
        bankName: '旧题库',
        questionCount: 20,
        paperName: '旧试卷',
      ),
    );

    expect(find.text('未选择，点击补选'), findsOneWidget);
  });

  testWidgets('工号等于身份证号时也按身份证脱敏', (tester) async {
    await _pumpSettings(
      tester,
      const PersonProfile(
        employeeNo: '610525199001011234',
        name: '张小赞',
        idCard: '610525199001011234',
        department: '某单位',
        phone: '13812345678',
        address: '某地址',
      ),
    );

    // 头部工号与个人信息里的身份证号都必须是脱敏值。
    expect(find.text('工号 610525******1234'), findsOneWidget);
    expect(find.text('610525******1234'), findsOneWidget);
    expect(find.text('610525199001011234'), findsNothing);
  });

  testWidgets('有头像字节时显示图片', (tester) async {
    await _pumpSettings(
      tester,
      const PersonProfile(
        employeeNo: 'E1001',
        name: '张小赞',
        idCard: '610525199001011234',
        department: '某单位',
        phone: '13812345678',
        address: '某地址',
      ),
      avatar: _pngBytes,
    );

    final withImage = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
    expect(withImage.backgroundImage, isA<MemoryImage>());
    expect(withImage.child, isNull);
    await tester.pumpAndSettle();
  });

  testWidgets('没有头像字节时回退姓名首字', (tester) async {
    await _pumpSettings(tester, _profile);

    final fallback = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
    expect(fallback.backgroundImage, isNull);
    expect(fallback.child, isA<Text>());
    expect(find.text('张'), findsOneWidget);
  });
}
