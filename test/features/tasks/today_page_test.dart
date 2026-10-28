import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/core/session/session.dart';
import 'package:primelearn/core/session/session_store.dart';
import 'package:primelearn/features/tasks/domain/entities/daily_task.dart';
import 'package:primelearn/features/tasks/domain/repositories/tasks_repository.dart';
import 'package:primelearn/features/tasks/presentation/pages/today_page.dart';
import 'package:primelearn/features/tasks/tasks_providers.dart';

class _FakeTasksRepository implements TasksRepository {
  _FakeTasksRepository(this.tasks, {this.error});

  final List<DailyTask> tasks;
  final Object? error;

  @override
  Future<List<DailyTask>> fetchDailyTasks(String userId) async {
    final failure = error;
    if (failure != null) throw failure;
    return tasks;
  }
}

class _PendingTasksRepository implements TasksRepository {
  final Completer<List<DailyTask>> completer = Completer<List<DailyTask>>();

  @override
  Future<List<DailyTask>> fetchDailyTasks(String userId) => completer.future;
}

DailyTask _task({
  required Criterion criterion,
  required String name,
  required int sort,
  required int score,
  required int maxScore,
  required int currentScore,
  String progress = '',
}) => DailyTask(
  criterion: criterion,
  name: name,
  rule: '规则文案',
  score: score,
  maxScore: maxScore,
  currentScore: currentScore,
  progressText: progress,
  sort: sort,
);

const Session _session = Session(
  userId: 'u1',
  userName: '张小赞',
  bankName: '题库A',
);

Future<ProviderContainer> _pumpHome(
  WidgetTester tester,
  TasksRepository repository, {
  bool withSession = true,
}) async {
  final container = ProviderContainer(
    overrides: [tasksRepositoryProvider.overrideWithValue(repository)],
  );
  addTearDown(container.dispose);
  if (withSession) {
    container.read(sessionStoreProvider.notifier).save(_session);
  }
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: TodayPage()),
    ),
  );
  return container;
}

void main() {
  testWidgets('展示积分、题库与任务列表', (tester) async {
    await _pumpHome(
      tester,
      _FakeTasksRepository([
        _task(
          criterion: Criterion.studyKnowledge,
          name: '知识学习',
          sort: 1,
          score: 1,
          maxScore: 1,
          currentScore: 1,
        ),
        _task(
          criterion: Criterion.mobileExam,
          name: '手机考试',
          sort: 2,
          score: 6,
          maxScore: 16,
          currentScore: 4,
          progress: '已考1个/获得4分',
        ),
        _task(
          criterion: Criterion.checkIn,
          name: '签到',
          sort: 3,
          score: 1,
          maxScore: 3,
          currentScore: 2,
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('张小赞'), findsOneWidget);
    expect(find.text('当前题库：题库A'), findsOneWidget);
    expect(find.text('今日积分'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('每日任务'), findsOneWidget);
    expect(find.text('2/3 已完成'), findsOneWidget);
    expect(find.text('知识学习'), findsOneWidget);
    expect(find.text('手机考试'), findsOneWidget);
    expect(find.text('已考1个/获得4分'), findsOneWidget);
    expect(find.text('1/1'), findsOneWidget);
    expect(find.text('4/16'), findsOneWidget);
    expect(find.text('2/3'), findsOneWidget);
    expect(find.text('已完成'), findsOneWidget);
    expect(find.text('今日已签到'), findsOneWidget);
    expect(find.text('连续签到累计 2/3'), findsOneWidget);
    expect(find.text('未完成'), findsOneWidget);
    expect(find.text('暂不执行 · 不获取积分'), findsNothing);
    expect(find.text('暂不执行'), findsNothing);
  });

  testWidgets('加载中显示进度文案', (tester) async {
    final repository = _PendingTasksRepository();
    await _pumpHome(tester, repository);
    await tester.pump();

    expect(find.text('正在加载每日任务...'), findsOneWidget);

    repository.completer.complete(const []);
    await tester.pumpAndSettle();
    expect(find.text('暂无任务'), findsOneWidget);
  });

  testWidgets('加载失败显示错误与重试', (tester) async {
    await _pumpHome(
      tester,
      _FakeTasksRepository(
        const [],
        error: const ApiException(kind: ApiErrorKind.protocol, message: '接口异常'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('每日任务加载失败'), findsOneWidget);
    expect(find.text('接口异常'), findsOneWidget);
    expect(find.text('重试'), findsOneWidget);
  });

  testWidgets('会话失效时清空本地会话', (tester) async {
    final container = await _pumpHome(
      tester,
      _FakeTasksRepository(
        const [],
        error: const ApiException(
          kind: ApiErrorKind.sessionExpired,
          message: '会话已失效',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(container.read(sessionStoreProvider), isNull);
    expect(find.text('暂无任务'), findsOneWidget);
  });
}
