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
  required String name,
  required int sort,
  int score = 1,
  int maxScore = 1,
  int currentScore = 0,
}) => DailyTask(
  criterion: criterion,
  name: name,
  rule: '规则',
  score: score,
  maxScore: maxScore,
  currentScore: currentScore,
  progressText: '',
  sort: sort,
);

void main() {
  test('保持接口返回的自然顺序，不做重排', () async {
    final board = await LoadDailyBoard(
      _FakeTasksRepository([
        _task(criterion: Criterion.course, name: '视频学习', sort: 3),
        _task(criterion: Criterion.mobileExam, name: '手机考试', sort: 4),
        _task(criterion: Criterion.checkIn, name: '签到', sort: 1),
        _task(criterion: Criterion.studyKnowledge, name: '知识学习', sort: 2),
      ]),
    ).execute('u1');

    expect(board.tasks.map((task) => task.name), [
      '视频学习',
      '手机考试',
      '签到',
      '知识学习',
    ]);
  });

  test('统计已完成数与今日积分', () async {
    final board = await LoadDailyBoard(
      _FakeTasksRepository([
        _task(
          criterion: Criterion.studyKnowledge,
          name: '知识学习',
          sort: 1,
          currentScore: 1,
          maxScore: 1,
        ),
        _task(
          criterion: Criterion.mobileExam,
          name: '手机考试',
          sort: 3,
          currentScore: 4,
          maxScore: 16,
        ),
        _task(
          criterion: Criterion.checkIn,
          name: '签到',
          sort: 1,
          currentScore: 2,
          maxScore: 3,
        ),
      ]),
    ).execute('u1');

    expect(board.tasks, hasLength(3));
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
