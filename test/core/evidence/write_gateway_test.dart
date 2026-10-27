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
}
