import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/core/errors/use_case_failure.dart';
import 'package:primelearn/core/evidence/write_evidence.dart';
import 'package:primelearn/core/evidence/write_gateway.dart';
import 'package:primelearn/core/session/session.dart';
import 'package:primelearn/core/session/session_store.dart';
import 'package:primelearn/features/exam/application/run_exam.dart';
import 'package:primelearn/features/exam/domain/entities/exam_page.dart';
import 'package:primelearn/features/exam/domain/entities/exam_paper.dart';
import 'package:primelearn/features/exam/domain/repositories/exam_repository.dart';
import 'package:primelearn/features/exam/exam_providers.dart';
import 'package:primelearn/features/settings/bank_providers.dart';
import 'package:primelearn/features/settings/domain/entities/bank_catalog.dart';
import 'package:primelearn/features/tasks/application/load_daily_board.dart';
import 'package:primelearn/features/tasks/domain/entities/daily_task.dart';
import 'package:primelearn/features/tasks/domain/entities/task_board.dart';
import 'package:primelearn/features/tasks/domain/repositories/tasks_repository.dart';
import 'package:primelearn/features/tasks/presentation/providers/daily_auto_runner.dart';
import 'package:primelearn/features/tasks/tasks_providers.dart';

const _preset = BankPreset(
  bankId: 'bank1',
  bankName: '题库',
  paperId: 'p1',
  paperName: '试卷',
);

ExamPageData _okPage() {
  final fields = List<String>.filled(22, '');
  fields[0] = 'r';
  fields[1] = 'q';
  fields[10] = '1';
  fields[13] = 'A';
  fields[14] = '1';
  final modulus = Uint8List(128)..fillRange(0, 128, 7);
  modulus[0] = 0x80;
  return ExamPageData(
    questions: [
      ExamQuestion(
        fields: fields,
        type: 1,
        score: 1,
        stem: 's',
        options: const [],
      ),
    ],
    examTypeName: '题库',
    totalCount: 1,
    publicKeyXml:
        '<RSAKeyValue><Modulus>${base64Encode(modulus)}</Modulus>'
        '<Exponent>AQAB</Exponent></RSAKeyValue>',
  );
}

class _ExamRepo implements ExamRepository {
  @override
  Future<String> createExam({
    required String userId,
    required String paperId,
    required int type,
  }) async => 'ksmxid';

  @override
  Future<void> enterExam({
    required String ksmxid,
    required String userId,
    required int style,
  }) async {}

  @override
  Future<ExamPageData> fetchExamPage() async => _okPage();

  @override
  Future<List<ExamPaper>> fetchPapers({
    required String userId,
    required String bankId,
  }) async => const [];

  @override
  Future<ExamResult> settleMock(String ksmxid) async =>
      const ExamResult(score: 100, passed: true, message: '合格');

  @override
  Future<ExamResult> settleMobile({
    required String ksmxid,
    required String mxid2,
    required String mxid3,
  }) async => const ExamResult(score: 100, passed: true, message: '合格');

  @override
  Future<void> submitAnswers({
    required String ksmxid,
    required String answer,
  }) async {}
}

class _TasksRepo implements TasksRepository {
  @override
  Future<List<DailyTask>> fetchDailyTasks(String userId) async => const [];
}

/// 可控看板：模拟「积分延迟 N 次查询后才入账」。
class _Board extends LoadDailyBoard {
  _Board({this.lagReads = 0, this.throwOnRead = false}) : super(_TasksRepo());

  final int lagReads;
  final bool throwOnRead;
  int _posted = 0;
  final List<int> _pending = [];
  int reads = 0;

  void creditExam() => _pending.add(lagReads);

  @override
  Future<TaskBoard> execute(String userId) async {
    reads += 1;
    if (throwOnRead && reads > 1) {
      throw const UseCaseFailure('加载今日任务失败，请稍后重试');
    }
    for (var i = 0; i < _pending.length; i++) {
      _pending[i] -= 1;
    }
    while (_pending.isNotEmpty && _pending.first <= 0) {
      _pending.removeAt(0);
      _posted = (_posted + 8).clamp(0, 16);
    }
    return TaskBoard(
      tasks: [
        DailyTask(
          criterion: Criterion.mobileExam,
          name: '手机考试',
          rule: '',
          score: 6,
          maxScore: 16,
          currentScore: _posted,
          progressText: '',
          sort: 3,
        ),
      ],
    );
  }
}

/// 记录每次真实执行（= 一次真实创建考试）。
class _CountingRunExam extends RunExam {
  _CountingRunExam(this._board)
    : super(_ExamRepo(), WriteGateway(WriteEvidence.defaults()));

  final _Board _board;
  int creates = 0;

  @override
  Future<ExamResult> execute({
    required ExamKind kind,
    required String userId,
    required ExamPaper paper,
    void Function(ExamStep step)? onStep,
  }) async {
    creates += 1;
    final result = await super.execute(
      kind: kind,
      userId: userId,
      paper: paper,
      onStep: onStep,
    );
    _board.creditExam();
    return result;
  }
}

Future<ProviderContainer> _run(
  WidgetTester tester,
  _Board board, {
  required _CountingRunExam runner,
  Duration pollInterval = Duration.zero,
  int pollCount = 0,
}) async {
  final container = ProviderContainer(
    overrides: [
      runExamProvider.overrideWithValue(runner),
      loadDailyBoardProvider.overrideWithValue(board),
      bankPresetProvider.overrideWith((ref) async => _preset),
      // 轮询配置通过 override 注入，不碰 notifier 的公开成员。
      creditPollIntervalProvider.overrideWithValue(pollInterval),
      creditPollCountProvider.overrideWithValue(pollCount),
    ],
  );
  addTearDown(container.dispose);
  container
      .read(sessionStoreProvider.notifier)
      .save(const Session(userId: 'u1', userName: 'n', examTypeId: 'bank1'));
  await tester.runAsync(
    () => container.read(dailyAutoRunnerProvider.notifier).run(),
  );
  return container;
}

void main() {
  testWidgets('积分立即可见时只跑该跑的两场（上限 16 / 每场 8）', (tester) async {
    final board = _Board();
    final runner = _CountingRunExam(board);
    final container = await _run(tester, board, runner: runner);
    expect(runner.creates, 2);
    final steps = container.read(dailyAutoRunnerProvider);
    final mobile = steps.firstWhere((step) => step.title == '手机考试');
    expect(mobile.status, AutoTaskStatus.done);
  });

  testWidgets('回查看板抛异常时必须有明确终态，不得冒泡', (tester) async {
    final board = _Board(throwOnRead: true);
    final runner = _CountingRunExam(board);
    final container = await _run(tester, board, runner: runner);

    final steps = container.read(dailyAutoRunnerProvider);
    // 不允许停留在 pending/running，否则 UI 永远显示「正在执行」。
    for (final step in steps) {
      expect(
        step.status,
        anyOf(AutoTaskStatus.done, AutoTaskStatus.failed),
        reason: '${step.title} 没有终态',
      );
    }
    expect(
      steps.any((s) => s.status == AutoTaskStatus.failed),
      isTrue,
      reason: '中断应至少体现在一个步骤的失败原因上',
    );
  });

  testWidgets('本场没产生任何积分时停止，不继续消耗考试次数', (tester) async {
    // lagReads 极大 → 轮询窗口内永远看不到积分上涨。
    final board = _Board(lagReads: 100);
    final runner = _CountingRunExam(board);
    final container = await _run(tester, board, runner: runner);

    expect(runner.creates, 1, reason: '看不到积分上涨就不应继续开考');
    final steps = container.read(dailyAutoRunnerProvider);
    final mobile = steps.firstWhere((step) => step.title == '手机考试');
    expect(mobile.status, AutoTaskStatus.failed);
    expect(mobile.detail, contains('未产生积分'));
  });

  test('默认积分轮询窗口应覆盖 §8.5 的 90 秒', () {
    // 断言 provider 的真实默认值（生产运行时走的就是它），
    // 而不是只断言常量——常量改了没人用也不会被发现。
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final interval = container.read(creditPollIntervalProvider);
    final count = container.read(creditPollCountProvider);

    expect(
      interval * count,
      greaterThanOrEqualTo(const Duration(seconds: 90)),
      reason: '轮询窗口不得短于 §8.5 规定的 90s 上限',
    );
    expect(
      interval,
      greaterThanOrEqualTo(const Duration(seconds: 10)),
      reason: '轮询间隔不得比 §8.5 建议的 10s 更频繁',
    );
    expect(
      (interval * count),
      Duration(seconds: 90),
      reason: '默认窗口应恰好为 90s（10s × 9 次）',
    );
  });
}
