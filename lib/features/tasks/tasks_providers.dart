import 'package:primelearn/core/network/api_client.dart';
import 'package:primelearn/features/tasks/application/load_daily_board.dart';
import 'package:primelearn/features/tasks/data/repositories/tasks_repository_impl.dart';
import 'package:primelearn/features/tasks/data/services/tasks_api.dart';
import 'package:primelearn/features/tasks/domain/repositories/tasks_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tasks_providers.g.dart';

/// 今日任务 API 实例。
@Riverpod(keepAlive: true)
TasksApi tasksApi(Ref ref) => TasksApi(ref.watch(apiClientProvider));

/// 今日任务仓储实例。
@Riverpod(keepAlive: true)
TasksRepository tasksRepository(Ref ref) =>
    TasksRepositoryImpl(ref.watch(tasksApiProvider));

/// 加载今日任务看板用例。
@Riverpod(keepAlive: true)
LoadDailyBoard loadDailyBoard(Ref ref) =>
    LoadDailyBoard(ref.watch(tasksRepositoryProvider));
