import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:primelearn/core/errors/use_case_failure.dart';
import 'package:primelearn/core/evidence/write_evidence.dart';
import 'package:primelearn/core/evidence/write_gateway.dart';
import 'package:primelearn/core/evidence/write_level.dart';
import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/features/checkin/application/perform_check_in.dart';
import 'package:primelearn/features/checkin/domain/check_in_endpoint.dart';
import 'package:primelearn/features/checkin/domain/entities/check_in_result.dart';
import 'package:primelearn/features/checkin/domain/repositories/check_in_repository.dart';

class _MockCheckInRepository extends Mock implements CheckInRepository {}

void main() {
  late _MockCheckInRepository repository;

  setUp(() {
    repository = _MockCheckInRepository();
  });

  WriteGateway gatewayWith(WriteLevel level) =>
      WriteGateway(WriteEvidence({checkInEndpoint: level}));

  test('证据未达 verified 时阻止，不发请求', () async {
    final useCase = PerformCheckIn(
      repository,
      gatewayWith(WriteLevel.observed),
    );

    await expectLater(
      useCase.execute('u1'),
      throwsA(
        isA<UseCaseFailure>().having(
          (e) => e.message,
          'message',
          contains('已阻止写入'),
        ),
      ),
    );
    verifyNever(() => repository.checkIn(any()));
  });

  test('verified 时执行签到', () async {
    when(() => repository.checkIn('u1')).thenAnswer(
      (_) async =>
          const CheckInResult(alreadyCheckedIn: false, message: '操作成功'),
    );
    final useCase = PerformCheckIn(
      repository,
      gatewayWith(WriteLevel.verified),
    );

    final result = await useCase.execute('u1');

    expect(result.displayMessage, '签到成功');
    verify(() => repository.checkIn('u1')).called(1);
  });

  test('会话失效映射为 sessionExpired', () async {
    when(() => repository.checkIn(any())).thenThrow(
      const ApiException(kind: ApiErrorKind.sessionExpired, message: '会话已失效'),
    );
    final useCase = PerformCheckIn(
      repository,
      gatewayWith(WriteLevel.verified),
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
    when(() => repository.checkIn(any())).thenThrow('boom');
    final useCase = PerformCheckIn(
      repository,
      gatewayWith(WriteLevel.verified),
    );

    await expectLater(
      useCase.execute('u1'),
      throwsA(
        isA<UseCaseFailure>().having((e) => e.message, 'message', '签到失败，请稍后重试'),
      ),
    );
  });
}
