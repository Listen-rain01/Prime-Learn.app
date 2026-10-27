import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/core/session/session.dart';
import 'package:primelearn/core/session/session_store.dart';
import 'package:primelearn/features/settings/domain/entities/person_profile.dart';
import 'package:primelearn/features/settings/domain/repositories/profile_repository.dart';
import 'package:primelearn/features/settings/presentation/pages/settings_page.dart';
import 'package:primelearn/features/settings/profile_providers.dart';

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository(this.profile);

  final PersonProfile profile;

  @override
  Future<PersonProfile> fetchProfile(String userId) async => profile;
}

const _profile = PersonProfile(
  employeeNo: 'E1001',
  name: '张小赞',
  idCard: '610525199001011234',
  department: '澄合矿业/西卓煤矿/设备维修队',
  phone: '13812345678',
  address: '陕西省澄城县某村一组',
);

Future<void> _pumpSettings(WidgetTester tester, PersonProfile profile) async {
  final container = ProviderContainer(
    overrides: [
      profileRepositoryProvider.overrideWithValue(
        _FakeProfileRepository(profile),
      ),
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
    expect(find.text('当前题库：题库A'), findsOneWidget);
    expect(find.text('个人信息'), findsOneWidget);
    expect(find.text('工号'), findsOneWidget);
    expect(find.text('E1001'), findsOneWidget);
    expect(find.text('身份证号'), findsOneWidget);
    expect(find.text('610525******1234'), findsOneWidget);
    expect(find.text('610525199001011234'), findsNothing);
    expect(find.text('工作单位'), findsOneWidget);
    expect(find.text('澄合矿业/西卓煤矿/设备维修队'), findsOneWidget);
    expect(find.text('联系方式'), findsOneWidget);
    expect(find.text('138****5678'), findsOneWidget);
    expect(find.text('13812345678'), findsNothing);
    expect(find.text('家庭地址'), findsOneWidget);
    expect(find.text('题库切换'), findsOneWidget);
    expect(find.text('退出登录'), findsOneWidget);
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

    expect(find.text('610525******1234'), findsNWidgets(2));
    expect(find.text('610525199001011234'), findsNothing);
  });
}
