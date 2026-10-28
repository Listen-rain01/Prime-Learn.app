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
  List<AutoTaskProgress> build() => const [
    AutoTaskProgress(title: '模拟考试'),
    AutoTaskProgress(title: '手机考试'),
    AutoTaskProgress(title: '签到'),
    AutoTaskProgress(title: '知识学习'),
  ];

  /// 是否正在执行。
  bool get running => _running;

  /// 执行全部任务。
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
    for (var attempt = 0; attempt < 5; attempt++) {
      if (task == null || task.isCompleted) {
        _update(index, AutoTaskStatus.done, '今日已完成');
        return;
      }
      try {
        final result = await ref
            .read(runExamProvider)
            .execute(kind: kind, userId: userId, paper: _toPaper(preset));
        _update(index, AutoTaskStatus.running, '${result.score} 分，检查进度');
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
      board = await _fetchBoard(userId);
      task = _find(board, criterion);
    }
    _update(index, AutoTaskStatus.failed, '多次执行仍未完成');
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
