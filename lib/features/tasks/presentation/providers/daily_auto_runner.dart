import 'package:primelearn/core/errors/no_retry.dart';
import 'package:primelearn/core/errors/use_case_failure.dart';
import 'package:primelearn/core/session/session_store.dart';
import 'package:primelearn/features/auth/auth_providers.dart';
import 'package:primelearn/features/checkin/check_in_providers.dart';
import 'package:primelearn/features/exam/application/run_exam.dart';
import 'package:primelearn/features/exam/domain/entities/exam_paper.dart';
import 'package:primelearn/features/exam/exam_providers.dart';
import 'package:primelearn/features/reading/reading_providers.dart';
import 'package:primelearn/features/settings/bank_providers.dart';
import 'package:primelearn/features/settings/domain/entities/bank_catalog.dart';
import 'package:primelearn/features/tasks/domain/entities/daily_task.dart';
import 'package:primelearn/features/tasks/domain/entities/task_board.dart';
import 'package:primelearn/features/tasks/presentation/providers/daily_board_notifier.dart';
import 'package:primelearn/features/tasks/tasks_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'daily_auto_runner.g.dart';

/// 积分轮询间隔（默认 10s）。
///
/// 独立成 provider 便于测试 override 成 `Duration.zero`，
/// 避免 notifier 暴露可变字段（riverpod_lint 要求 notifier 只通过 state 暴露 API）。
@Riverpod(keepAlive: true)
Duration creditPollInterval(Ref ref) =>
    DailyAutoRunner.defaultCreditPollInterval;

/// 积分轮询次数（默认 9 次，配合 10s 间隔即 90s 窗口）。
@Riverpod(keepAlive: true)
int creditPollCount(Ref ref) => DailyAutoRunner.defaultCreditPollCount;

/// 一键完成步骤状态。
enum AutoTaskStatus { pending, running, done, failed }

/// 单个步骤的进度。
class AutoTaskProgress {
  /// 创建进度。
  const AutoTaskProgress({
    required this.title,
    this.status = AutoTaskStatus.pending,
    this.detail = '',
  });

  /// 步骤名。
  final String title;

  /// 状态。
  final AutoTaskStatus status;

  /// 详情（分数、失败原因等）。
  final String detail;

  /// 复制并覆盖状态。
  AutoTaskProgress copyWith({AutoTaskStatus? status, String? detail}) =>
      AutoTaskProgress(
        title: title,
        status: status ?? this.status,
        detail: detail ?? this.detail,
      );
}

/// 一键完成今日任务：模拟考试 → 手机考试 → 签到 → 知识学习。
///
/// 每步执行前/失败后都会回查今日任务，已完成则跳过；写失败后不盲目重试。
@Riverpod(keepAlive: true, retry: noProviderRetry)
class DailyAutoRunner extends _$DailyAutoRunner {
  bool _running = false;

  @override
  List<AutoTaskProgress> build() {
    // 会话变化（退出登录 / 换账号）时重置进度，
    // 避免把上一个账号的分数与「已完成」带到新会话。
    final session = ref.watch(sessionStoreProvider);
    _resetForSession(session?.userId);
    return const [
      AutoTaskProgress(title: '模拟考试'),
      AutoTaskProgress(title: '手机考试'),
      AutoTaskProgress(title: '签到'),
      AutoTaskProgress(title: '知识学习'),
    ];
  }

  /// 当前进度所属的用户；换人时清空。
  String? _ownerUserId;

  void _resetForSession(String? userId) {
    if (_ownerUserId == userId) return;
    _ownerUserId = userId;
    _running = false;
  }

  /// 默认积分轮询间隔（10s，符合 §8.5 的 10–15s 建议）。
  static const Duration defaultCreditPollInterval = Duration(seconds: 10);

  /// 默认积分轮询次数（9 次，配合 10s 间隔即 90s 窗口）。
  static const int defaultCreditPollCount = 9;

  /// 每次执行前从 provider 读取的轮询配置。
  ///
  /// 不再用 notifier 上的可变字段：notifier 的公开成员只允许是 `state`
  /// （riverpod_lint `avoid_public_notifier_properties`）。
  /// 测试通过 override 这两个 provider 把 90s 窗口缩短为 0。
  ({Duration interval, int count}) get _creditPollConfig => (
    interval: ref.read(creditPollIntervalProvider),
    count: ref.read(creditPollCountProvider),
  );

  /// 执行全部任务。
  ///
  /// 任何一步抛出的异常都必须收敛成明确终态，不能冒泡给调用方：
  /// 调用点（auto_run_sheet）不 await，异常会让 UI 永久停在「正在执行」。
  Future<void> run() async {
    if (_running) return;
    final session = ref.read(sessionStoreProvider);
    if (session == null) return;
    _running = true;
    _reset();
    try {
      // 只在确实需要跑考试时才对齐题库，避免全部已完成还去切库。
      await _runExamKind(
        index: 0,
        kind: ExamKind.mock,
        criterion: Criterion.mockExam,
        userId: session.userId,
      );
      await _runExamKind(
        index: 1,
        kind: ExamKind.mobile,
        criterion: Criterion.mobileExam,
        userId: session.userId,
      );
      await _runCheckIn(session.userId);
      await _runReading(session.userId);
    } on Object catch (error) {
      // 未能归入具体步骤的异常（多为看板查询失败）落到第一个未完成步骤上。
      final index = state.indexWhere(
        (step) => step.status == AutoTaskStatus.running,
      );
      final target = index >= 0
          ? index
          : state.indexWhere((step) => step.status == AutoTaskStatus.pending);
      final reason = error is UseCaseFailure ? error.message : '执行中断，请稍后重试';
      if (target >= 0) {
        _update(target, AutoTaskStatus.failed, reason);
      }
      // 其余未开始步骤标记为未完成，避免界面永远显示「等待执行」。
      for (var i = 0; i < state.length; i++) {
        if (state[i].status == AutoTaskStatus.pending) {
          _update(i, AutoTaskStatus.failed, '未执行（上一步中断）');
        }
      }
    } finally {
      ref.invalidate(dailyBoardProvider);
      _running = false;
    }
  }

  void _reset() {
    state = [
      for (final step in state) step.copyWith(status: AutoTaskStatus.pending),
    ];
  }

  void _update(int index, AutoTaskStatus status, [String detail = '']) {
    final next = [...state];
    next[index] = next[index].copyWith(status: status, detail: detail);
    state = next;
  }

  Future<TaskBoard> _fetchBoard(String userId) =>
      ref.read(loadDailyBoardProvider).execute(userId);

  DailyTask? _find(TaskBoard board, Criterion criterion) {
    for (final task in board.tasks) {
      if (task.criterion == criterion) return task;
    }
    return null;
  }

  Future<bool> _ensureBankAligned(String userId) async {
    final preset = await ref.read(bankPresetProvider.future);
    final session = ref.read(sessionStoreProvider);
    if (preset == null || session == null) return false;
    if (session.examTypeId == preset.bankId) return true;
    try {
      await ref
          .read(ensureBankPresetProvider)
          .execute(
            userId: userId,
            currentBankId: session.examTypeId ?? '',
            preset: preset,
          );
      final context = await ref
          .read(authRepositoryProvider)
          .fetchBankContext(userId);
      final latest = ref.read(sessionStoreProvider);
      if (latest != null) {
        ref
            .read(sessionStoreProvider.notifier)
            .save(
              latest.copyWith(
                bankName: context.bankName,
                examTypeId: context.examTypeId,
              ),
            );
      }
      return context.examTypeId == preset.bankId;
    } on Object {
      return false;
    }
  }

  Future<void> _runExamKind({
    required int index,
    required ExamKind kind,
    required Criterion criterion,
    required String userId,
  }) async {
    var board = await _fetchBoard(userId);
    var task = _find(board, criterion);
    if (task == null || task.isCompleted) {
      _update(index, AutoTaskStatus.done, '今日已完成');
      return;
    }

    final preset = await ref.read(bankPresetProvider.future);
    if (preset == null || preset.paperId == null) {
      _update(index, AutoTaskStatus.failed, '未设置题库/试卷预设');
      return;
    }
    if (!await _ensureBankAligned(userId)) {
      _update(index, AutoTaskStatus.failed, '题库对齐失败');
      return;
    }

    _update(index, AutoTaskStatus.running, '开始执行');
    // 平台积分延迟入账（§8.5），一场考完立刻回查可能仍是旧分数。
    // 因此额外给「积分未入账」留轮询预算，避免把已到账的场次当成没跑而重复创建。
    for (var attempt = 0; attempt < _maxExamAttempts; attempt++) {
      if (task == null || task.isCompleted) {
        _update(index, AutoTaskStatus.done, '今日已完成');
        return;
      }
      try {
        final result = await ref
            .read(runExamProvider)
            .execute(kind: kind, userId: userId, paper: _toPaper(preset));
        _update(index, AutoTaskStatus.running, '${result.score} 分，等待积分入账');
      } on UseCaseFailure catch (error) {
        // 失败后回查：平台可能已记录本次结果。
        board = await _fetchBoard(userId);
        task = _find(board, criterion);
        if (task == null || task.isCompleted) {
          _update(index, AutoTaskStatus.done, '已完成');
        } else {
          _update(index, AutoTaskStatus.failed, error.message);
        }
        return;
      }

      // 结算成功后先轮询积分，确认真实未到账再决定是否再考一场。
      final confirmed = await _awaitExamCredit(userId, criterion, task);
      board = confirmed.board;
      task = _find(board, criterion);
      if (confirmed.gained && (task == null || task.isCompleted)) {
        _update(index, AutoTaskStatus.done, '今日已完成');
        return;
      }
      if (!confirmed.gained) {
        // 本场完全没有产生积分：再考也不会增加，停止而不是空耗考试次数。
        _update(index, AutoTaskStatus.failed, '本场未产生积分，已停止（请查看记录）');
        return;
      }
      if (task == null) {
        // 积分涨了但任务查不到：状态不明，停止而不是继续开考。
        _update(index, AutoTaskStatus.failed, '积分已变化但任务状态未知，已停止');
        return;
      }
    }
    _update(index, AutoTaskStatus.failed, '多次执行仍未完成');
  }

  /// 单类考试最多尝试的场次。
  ///
  /// 手机考试日上限 16 分、单场 8 分（真实样本 `today-accumulate`），
  /// 模拟考试 8 分、单场 4 分 → 各需 2 场；留 1 场余量应对失败重考。
  static const int _maxExamAttempts = 3;

  /// 结算后轮询今日任务，等待积分入账。
  ///
  /// 平台入账有延迟（§8.5：每 10–15s 一次，最多 90s）。这里只等「本场是否到账」；
  /// 轮询窗口结束仍未到账时交由调用方停止，而不是继续开下一场。
  /// 窗口本身不判失败：延迟更久的场次仍可能之后入账，结果会体现在下一次看板上。
  Future<({TaskBoard board, bool gained})> _awaitExamCredit(
    String userId,
    Criterion criterion,
    DailyTask before,
  ) async {
    final baseline = before.currentScore;
    var board = await _fetchBoard(userId);
    var task = _find(board, criterion);
    // 只看「积分真的涨了」或「任务已满额」：任务查不到属于状态未知，
    // 不能当成已到账（否则会把失败的写入报成完成）。
    if (task != null && (task.currentScore > baseline || task.isCompleted)) {
      return (board: board, gained: true);
    }
    final poll = _creditPollConfig;
    for (var i = 0; i < poll.count; i++) {
      await Future<void>.delayed(poll.interval);
      board = await _fetchBoard(userId);
      task = _find(board, criterion);
      if (task != null && (task.currentScore > baseline || task.isCompleted)) {
        return (board: board, gained: true);
      }
    }
    // 轮询结束仍未到账：可能是延迟更久，也可能是本场没被计入。
    // 返回 gained=false 交由调用方停止，避免继续烧考试次数。
    return (board: board, gained: false);
  }

  ExamPaper _toPaper(BankPreset preset) => ExamPaper(
    id: preset.paperId!,
    name: preset.paperName ?? '',
    totalScore: preset.paperTotalScore ?? 0,
    passingGrade: preset.paperPassingGrade ?? 0,
  );

  Future<void> _runCheckIn(String userId) async {
    var board = await _fetchBoard(userId);
    var task = _find(board, Criterion.checkIn);
    if (task == null || task.currentScore > 0) {
      _update(2, AutoTaskStatus.done, '今日已完成');
      return;
    }
    _update(2, AutoTaskStatus.running, '提交签到');
    try {
      final result = await ref.read(performCheckInProvider).execute(userId);
      _update(
        2,
        AutoTaskStatus.done,
        result.displayMessage.isEmpty ? '已签到' : result.displayMessage,
      );
    } on UseCaseFailure catch (error) {
      // 「今日已签到」是幂等结果，算完成；其他失败回查进度。
      if (error.message.contains('已签到')) {
        _update(2, AutoTaskStatus.done, '今日已签到');
        return;
      }
      board = await _fetchBoard(userId);
      task = _find(board, Criterion.checkIn);
      if (task != null && task.currentScore > 0) {
        _update(2, AutoTaskStatus.done, '已签到');
      } else {
        _update(2, AutoTaskStatus.failed, error.message);
      }
    }
  }

  Future<void> _runReading(String userId) async {
    var board = await _fetchBoard(userId);
    var task = _find(board, Criterion.studyKnowledge);
    if (task == null || task.isCompleted) {
      _update(3, AutoTaskStatus.done, '今日已完成');
      return;
    }
    final preset = await ref.read(readingPresetProvider.future);
    if (preset == null) {
      _update(3, AutoTaskStatus.failed, '未设置阅读预设');
      return;
    }
    _update(3, AutoTaskStatus.running, '按预设完成阅读');
    try {
      final completed = await ref
          .read(completeReadingProvider)
          .execute(userId: userId, preset: preset);
      board = await _fetchBoard(userId);
      task = _find(board, Criterion.studyKnowledge);
      if (task != null && task.isCompleted) {
        _update(3, AutoTaskStatus.done, completed ? '已完成' : '今日已完成');
      } else {
        _update(3, AutoTaskStatus.failed, '仍未达到今日上限');
      }
    } on UseCaseFailure catch (error) {
      board = await _fetchBoard(userId);
      task = _find(board, Criterion.studyKnowledge);
      if (task != null && task.isCompleted) {
        _update(3, AutoTaskStatus.done, '今日已完成');
      } else {
        _update(3, AutoTaskStatus.failed, error.message);
      }
    }
  }
}
