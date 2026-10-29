import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/core/evidence/write_blocked.dart';
import 'package:primelearn/core/evidence/write_evidence.dart';
import 'package:primelearn/core/evidence/write_gateway.dart';
import 'package:primelearn/core/evidence/write_level.dart';

const _checkIn = '/ArchiveManger/D_PersonAccumulate/CheckInOne';

void main() {
  test('observed 级别阻止写入', () {
    final gateway = WriteGateway(
      const WriteEvidence({_checkIn: WriteLevel.observed}),
    );

    expect(
      () => gateway.ensureAllowed(_checkIn, behavior: '签到'),
      throwsA(
        isA<WriteBlocked>().having(
          (e) => e.message,
          'message',
          contains('已阻止写入'),
        ),
      ),
    );
  });

  test('未登记的接口按 assumed 阻止', () {
    final gateway = WriteGateway(
      const WriteEvidence({_checkIn: WriteLevel.verified}),
    );

    expect(
      () => gateway.ensureAllowed('/Other/Write', behavior: '提交'),
      throwsA(isA<WriteBlocked>()),
    );
  });

  test('verified 允许写入', () {
    final gateway = WriteGateway(
      const WriteEvidence({_checkIn: WriteLevel.verified}),
    );

    expect(
      () => gateway.ensureAllowed(_checkIn, behavior: '签到'),
      returnsNormally,
    );
  });

  test('行为级登记：只有登记过的行为放行', () {
    final gateway = WriteGateway(
      const WriteEvidence({}, behaviors: {'/e#mobile': WriteLevel.verified}),
    );
    expect(
      () => gateway.ensureAllowed('/e', behavior: '手机', behaviorId: 'mobile'),
      returnsNormally,
    );
    expect(
      () => gateway.ensureAllowed('/e', behavior: '模拟', behaviorId: 'mock'),
      throwsA(isA<WriteBlocked>()),
    );
  });

  test('端点整体 verified 时，未登记的行为不得回落到端点级', () {
    // 这正是「一种行为验证过会连带放行另一种」的漏洞场景。
    final gateway = WriteGateway(
      const WriteEvidence(
        {'/e': WriteLevel.verified},
        behaviors: {'/e#mobile': WriteLevel.verified},
      ),
    );
    expect(
      () => gateway.ensureAllowed('/e', behavior: '手机', behaviorId: 'mobile'),
      returnsNormally,
    );
    expect(
      () => gateway.ensureAllowed('/e', behavior: '模拟', behaviorId: 'mock'),
      throwsA(isA<WriteBlocked>()),
    );
  });

  test('默认登记表：模拟与手机两种考试行为都放行', () {
    final gateway = WriteGateway(WriteEvidence.defaults());
    for (final id in ['mock', 'mobile']) {
      for (final endpoint in [
        '/Home/CreateTempExamOne',
        '/P_ExamDetail/SetOnlineTestOne',
        '/Home/DoWriteAnswerAll',
      ]) {
        expect(
          () =>
              gateway.ensureAllowed(endpoint, behavior: '考试写入', behaviorId: id),
          returnsNormally,
          reason: '$endpoint 的 $id 行为应放行',
        );
      }
    }
  });

  test('默认登记表：未登记的行为被拦截', () {
    final gateway = WriteGateway(WriteEvidence.defaults());
    expect(
      () => gateway.ensureAllowed(
        '/Home/CreateTempExamOne',
        behavior: '创建考试',
        behaviorId: 'practice',
      ),
      throwsA(isA<WriteBlocked>()),
    );
  });

  test('默认登记表：结算端点按端点级判级', () {
    final gateway = WriteGateway(WriteEvidence.defaults());
    expect(
      () => gateway.ensureAllowed('/Home/CEndTimeOne', behavior: '结算考试'),
      returnsNormally,
    );
    expect(
      () => gateway.ensureAllowed('/Home/CEndTimeMobil', behavior: '结算考试'),
      returnsNormally,
    );
  });
}
