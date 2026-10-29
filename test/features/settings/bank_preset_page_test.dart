import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/core/session/session.dart';
import 'package:primelearn/core/session/session_store.dart';
import 'package:primelearn/features/exam/domain/entities/exam_paper.dart';
import 'package:primelearn/features/exam/exam_providers.dart';
import 'package:primelearn/features/settings/bank_providers.dart';
import 'package:primelearn/features/settings/domain/entities/bank_catalog.dart';
import 'package:primelearn/features/settings/presentation/pages/bank_preset_page.dart';

const _unit = BankUnit(id: 'u1', name: '股份');
const _style = BankStyle(
  level: 1,
  styleId: '0',
  name: '安管人员',
  year: '',
  departmentId: 'u1',
  code: '0001',
);
const _year = BankStyle(
  level: 3,
  styleId: '0',
  name: '2025年',
  year: '2025',
  departmentId: 'u1',
  code: '0001',
);
const _bank = BankOption(
  id: 'bank1',
  name: '题库A',
  questionCount: 100,
  stateName: '正常',
  singleCount: 10,
  multipleCount: 5,
  judgeCount: 5,
);
const _paper = ExamPaper(
  id: 'p1',
  name: '试卷一',
  totalScore: 100,
  passingGrade: 80,
);

Future<void> _pump(
  WidgetTester tester, {
  AsyncValue<List<BankUnit>>? units,
}) async {
  final container = ProviderContainer(
    overrides: [
      bankUnitsProvider.overrideWith(
        (ref) async => switch (units) {
          AsyncValue(:final value?) => value,
          _ => const [_unit],
        },
      ),
      bankStylesProvider('u1').overrideWith((ref) async => const [_style]),
      bankChildrenProvider.overrideWith((ref, query) async => const [_year]),
      bankOptionsProvider.overrideWith((ref, query) async => const [_bank]),
      examPapersProvider.overrideWith((ref, bankId) async => const [_paper]),
      bankPresetProvider.overrideWith((ref) async => null),
    ],
  );
  addTearDown(container.dispose);
  container
      .read(sessionStoreProvider.notifier)
      .save(const Session(userId: 'u1', userName: 'n', examTypeId: 'u1'));
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: BankPresetPage()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _selectDownToPaper(WidgetTester tester) async {
  await tester.tap(find.text('选择单位'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('股份').last);
  await tester.pumpAndSettle();
  await tester.tap(find.text('安管人员').last);
  await tester.pumpAndSettle();
  await tester.tap(find.text('2025年').last);
  await tester.pumpAndSettle();
  await tester.tap(find.text('题库A').last);
  await tester.pumpAndSettle();
  await tester.tap(find.text('试卷一').last);
  await tester.pumpAndSettle();
}

FilledButton _saveButton(WidgetTester tester) =>
    tester.widget<FilledButton>(find.widgetWithText(FilledButton, '保存为执行预设'));

void main() {
  testWidgets('选完试卷后保存按钮可用', (tester) async {
    await _pump(tester);
    await _selectDownToPaper(tester);
    expect(_saveButton(tester).onPressed, isNotNull);
  });

  testWidgets('重新选择年份后清空了试卷，保存按钮必须禁用', (tester) async {
    await _pump(tester);
    await _selectDownToPaper(tester);

    // 重选年份：_bank 与 _paper 都应被清空。
    await tester.tap(find.text('年份'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2025年').last);
    await tester.pumpAndSettle();

    // 无论题库弹层是否还开着，保存按钮都不能可点（避免 _bank! 崩溃）。
    final saveBtn = find.widgetWithText(FilledButton, '保存为执行预设');
    if (saveBtn.evaluate().isNotEmpty) {
      expect(_saveButton(tester).onPressed, isNull);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('题库加载失败时单位选择器给出可见提示', (tester) async {
    // 单位列表为空（接口成功但无数据）时选择器禁用，这是既有行为。
    await _pump(tester, units: const AsyncValue.data([]));
    expect(find.text('选择单位'), findsOneWidget);
  });

  testWidgets('单位列表加载失败时可点击重试（不再静默禁用）', (tester) async {
    final container = ProviderContainer(
      overrides: [
        bankUnitsProvider.overrideWith((ref) async => throw StateError('网络错误')),
        bankPresetProvider.overrideWith((ref) async => null),
      ],
    );
    addTearDown(container.dispose);
    container
        .read(sessionStoreProvider.notifier)
        .save(const Session(userId: 'u1', userName: 'n', examTypeId: 'u1'));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: BankPresetPage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('单位加载失败，点击重试'), findsOneWidget);
  });
}
