import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/features/tasks/data/services/tasks_api.dart';

void main() {
  test('pid 使用 Esdt 编码且不二次转义', () {
    final path = TasksApi.dailyTasksPath('123');

    expect(
      path,
      '/AccumulateManger/S_Accumulate/GetPersonTodayAccumulateOne'
      '?pid=495051%5E2%2C2%2C2',
    );
    // 若交给 queryParameters 编码，会出现 %255E（% 被再次转义）。
    expect(path, isNot(contains('%255E')));
    expect(path, isNot(contains('%252C')));
  });
}
