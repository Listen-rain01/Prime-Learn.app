import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/core/errors/use_case_failure.dart';
import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/features/tasks/application/load_daily_board.dart';
import 'package:primelearn/features/tasks/domain/entities/daily_task.dart';
import 'package:primelearn/features/tasks/domain/repositories/tasks_repository.dart';

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

DailyTask _task({
  required Criterion criterion,
  required int sort,
  String name = '任务',
  int score = 1,
  int maxScore = 1,
  int currentScore = 0,
  String progress = '',
}) => DailyTask(
  criterion: criterion,
  name: name,
  rule: '规则',
  score: score,
  maxScore: maxScore,
  currentScore: currentScore,
  progressText: progress,
  sort: sort,
);

void main() {
  test('按 Sort 排序并分为可执行 / 暂不执行', () async {
    final board = await LoadDailyBoard(
      _FakeTasksRepository([
        _task(criterion: Criterion.course, sort: 3, name: '视频学习'),
        _task(criterion: Criterion.mobileExam, sort: 4, name: '手机考试'),
        _task(criterion: Criterion.checkIn, sort: 1, name: '签到'),
        _task(criterion: Criterion.studyKnowledge, sort: 2, name: '知识学习'),
      ]),
    ).execute('u1');

    expect(board.actionable.map((task) => task.name), ['知识学习', '手机考试']);
    expect(board.pending.map((task) => task.name), ['签到', '视频学习']);
  });

  test('Sort 相同时保持服务端原始顺序（实测 Sort 不唯一）', () async {
    // 2026-10-28 真实响应：签到与知识学习同为 Sort=1，手机考试与视频学习同为 Sort=3。
    final board = await LoadDailyBoard(
      _FakeTasksRepository([
        _task(criterion: Criterion.checkIn, sort: 1, name: '签到'),
        _task(criterion: Criterion.studyKnowledge, sort: 1, name: '知识学习'),
        _task(criterion: Criterion.mockExam, sort: 2, name: '模拟考试'),
        _task(criterion: Criterion.mobileExam, sort: 3, name: '手机考试'),
        _task(criterion: Criterion.course, sort: 3, name: '视频学习'),
      ]),
    ).execute('u1');

    expect(board.actionable.map((task) => task.name), ['知识学习', '模拟考试', '手机考试']);
    expect(board.pending.map((task) => task.name), ['签到', '视频学习']);
  });

  test('统计已完成数与今日积分', () async {
    final board = await LoadDailyBoard(
      _FakeTasksRepository([
        _task(
          criterion: Criterion.studyKnowledge,
          sort: 1,
          currentScore: 1,
          maxScore: 1,
        ),
        _task(
          criterion: Criterion.mobileExam,
          sort: 2,
          currentScore: 4,
          maxScore: 16,
        ),
        _task(
          criterion: Criterion.checkIn,
          sort: 3,
          currentScore: 2,
          maxScore: 3,
        ),
      ]),
    ).execute('u1');

    expect(board.all, hasLength(3));
    expect(board.completedCount, 1);
    expect(board.currentPoints, 7);
    expect(board.maxPoints, 20);
    expect(board.isEmpty, isFalse);
  });

  test('空列表返回空看板', () async {
    final board = await LoadDailyBoard(_FakeTasksRepository([])).execute('u1');
    expect(board.isEmpty, isTrue);
    expect(board.completedCount, 0);
    expect(board.currentPoints, 0);
  });

  test('会话失效映射为 sessionExpired', () async {
    final useCase = LoadDailyBoard(
      _FakeTasksRepository(
        const [],
        error: const ApiException(
          kind: ApiErrorKind.sessionExpired,
          message: '会话已失效',
        ),
      ),
    );

    await expectLater(
      useCase.execute('u1'),
      throwsA(
        isA<UseCaseFailure>()
            .having((e) => e.sessionExpired, 'sessionExpired', isTrue)
            .having((e) => e.message, 'message', '会话已失效'),
      ),
    );
  });

  test('其他异常映射为通用失败', () async {
    final useCase = LoadDailyBoard(
      _FakeTasksRepository(const [], error: 'boom'),
    );

    await expectLater(
      useCase.execute('u1'),
      throwsA(
        isA<UseCaseFailure>().having(
          (e) => e.message,
          'message',
          '加载今日任务失败，请稍后重试',
        ),
      ),
    );
  });
}
