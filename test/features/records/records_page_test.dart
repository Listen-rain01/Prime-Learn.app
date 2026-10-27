import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/core/session/session.dart';
import 'package:primelearn/core/session/session_store.dart';
import 'package:primelearn/features/records/domain/entities/exam_record.dart';
import 'package:primelearn/features/records/domain/entities/point_entry.dart';
import 'package:primelearn/features/records/domain/entities/ranking_board.dart';
import 'package:primelearn/features/records/domain/entities/score_trend_point.dart';
import 'package:primelearn/features/records/domain/repositories/records_repository.dart';
import 'package:primelearn/features/records/presentation/pages/records_page.dart';
import 'package:primelearn/features/records/records_providers.dart';

class _FakeRecordsRepository implements RecordsRepository {
  @override
  Future<List<ExamRecord>> fetchExamRecords(
    String userId,
    ExamRecordCategory category,
  ) async => switch (category) {
    ExamRecordCategory.mobile => [
      ExamRecord(
        examName: '手机考试 A',
        examType: '手机自测',
        mark: 100,
        qualified: true,
        state: '已交卷',
        startTime: DateTime(2026, 10, 27, 15, 8),
      ),
    ],
    ExamRecordCategory.mock => [
      const ExamRecord(
        examName: '模拟考试 B',
        examType: '手机模拟',
        mark: 96.5,
        qualified: true,
        state: '已交卷',
      ),
    ],
    ExamRecordCategory.theory => [
      const ExamRecord(
        examName: '理论考试 C',
        examType: '理论考试',
        mark: 58,
        qualified: false,
        state: '已交卷',
      ),
    ],
  };

  @override
  Future<List<PointEntry>> fetchPointsLedger(String userId) async => [
    PointEntry(name: '签到', amount: 2, date: DateTime(2026, 10, 27, 1, 45)),
    const PointEntry(name: '扣减', amount: -1),
  ];

  @override
  Future<RankingBoard> fetchMarkRanking({
    required String userId,
    required RankingScope scope,
    required String begin,
    required String end,
  }) async => RankingBoard(
    myName: '张小赞',
    myRank: 12,
    myMark: 96.5,
    entries: const [
      RankingEntry(
        rank: 1,
        personName: '田小平',
        department: '澄合矿业/西卓煤矿/运输区',
        mark: 99.5,
      ),
      RankingEntry(
        rank: 2,
        personName: '张小赞',
        department: '澄合矿业/西卓煤矿/设备维修队',
        mark: 96.5,
      ),
    ],
  );

  @override
  Future<RankingBoard> fetchStudyTimeRanking({
    required String userId,
    required RankingScope scope,
    required String begin,
    required String end,
  }) async => const RankingBoard(
    myName: '张小赞',
    myRank: 3,
    myMark: 7200,
    entries: [
      RankingEntry(
        rank: 1,
        personName: '李四',
        department: '维修队',
        mark: 0,
        allCount: 7200,
      ),
    ],
  );

  @override
  Future<List<ScoreTrendPoint>> fetchScoreTrend(String userId) async => [
    ScoreTrendPoint(
      examName: '2025陕西煤业手机考试',
      examType: '手机考试',
      mark: 100,
      time: DateTime(2026, 10, 27, 1, 26),
    ),
    ScoreTrendPoint(
      examName: '2025陕西煤业模拟考试',
      examType: '模拟考试',
      mark: 88,
      time: DateTime(2026, 10, 20, 9, 0),
    ),
  ];
}

void main() {
  Future<void> pumpRecords(WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        recordsRepositoryProvider.overrideWithValue(_FakeRecordsRepository()),
      ],
    );
    addTearDown(container.dispose);
    container
        .read(sessionStoreProvider.notifier)
        .save(const Session(userId: 'u1', userName: '张小赞', bankName: '题库A'));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: RecordsPage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('默认展示手机考试记录', (tester) async {
    await pumpRecords(tester);

    expect(find.text('记录'), findsOneWidget);
    expect(find.text('考试'), findsOneWidget);
    expect(find.text('积分'), findsOneWidget);
    expect(find.text('手机考试 A'), findsOneWidget);
    expect(find.text('手机自测 · 2026-10-27 15:08'), findsOneWidget);
    expect(find.text('100'), findsOneWidget);
    expect(find.text('合格'), findsOneWidget);
  });

  testWidgets('切换分类后展示对应记录', (tester) async {
    await pumpRecords(tester);

    await tester.tap(find.text('理论'));
    await tester.pumpAndSettle();

    expect(find.text('理论考试 C'), findsOneWidget);
    expect(find.text('58'), findsOneWidget);
    expect(find.text('不合格'), findsOneWidget);
  });

  testWidgets('切换积分 Tab 展示明细', (tester) async {
    await pumpRecords(tester);

    await tester.tap(find.text('积分'));
    await tester.pumpAndSettle();

    expect(find.text('签到'), findsOneWidget);
    expect(find.text('+2'), findsOneWidget);
    expect(find.text('-1'), findsOneWidget);
    expect(find.text('2026-10-27 01:45'), findsOneWidget);
  });

  testWidgets('排行 Tab 展示成绩榜、我的排名与成绩趋势', (tester) async {
    await pumpRecords(tester);

    await tester.tap(find.text('排行'));
    await tester.pumpAndSettle();

    expect(find.text('成绩榜'), findsOneWidget);
    expect(find.text('学习时长榜'), findsOneWidget);
    expect(find.text('单位'), findsOneWidget);
    expect(find.text('集团'), findsOneWidget);
    expect(find.text('我的排名：第 12 名 · 96.5'), findsOneWidget);
    expect(find.text('田小平'), findsOneWidget);
    expect(find.text('99.5'), findsOneWidget);
    expect(find.text('我的成绩趋势'), findsOneWidget);
    expect(find.text('2025陕西煤业手机考试'), findsOneWidget);
    expect(find.text('10-27'), findsOneWidget);
  });

  testWidgets('切换学习时长榜后刷新榜单', (tester) async {
    await pumpRecords(tester);

    await tester.tap(find.text('排行'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('学习时长榜'));
    await tester.pumpAndSettle();

    expect(find.text('李四'), findsOneWidget);
    expect(find.text('我的排名：第 3 名 · 2 小时'), findsOneWidget);
    expect(find.text('2 小时'), findsOneWidget);
    expect(find.text('田小平'), findsNothing);
  });
}
