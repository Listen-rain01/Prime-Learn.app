import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:primelearn/core/errors/use_case_failure.dart';
import 'package:primelearn/core/evidence/write_evidence.dart';
import 'package:primelearn/core/evidence/write_gateway.dart';
import 'package:primelearn/core/evidence/write_level.dart';
import 'package:primelearn/features/settings/application/ensure_bank_preset.dart';
import 'package:primelearn/features/settings/domain/bank_endpoints.dart';
import 'package:primelearn/features/settings/domain/entities/bank_catalog.dart';
import 'package:primelearn/features/settings/domain/repositories/bank_repository.dart';

class _MockBankRepository extends Mock implements BankRepository {}

const _preset = BankPreset(bankId: 'bank-2', bankName: '目标题库');

void main() {
  late _MockBankRepository repository;

  setUp(() {
    repository = _MockBankRepository();
  });

  EnsureBankPreset useCaseWith(WriteLevel level) => EnsureBankPreset(
    repository,
    WriteGateway(WriteEvidence({bankSaveEndpoint: level})),
  );

  test('当前题库与预设一致时不写', () async {
    final switched = await useCaseWith(WriteLevel.verified)
        .execute(userId: 'u1', currentBankId: 'bank-2', preset: _preset);

    expect(switched, isFalse);
    verifyNever(() => repository.saveBank(any(), any()));
  });

  test('不一致且证据未达 verified 时拦截，不发请求', () async {
    await expectLater(
      useCaseWith(WriteLevel.observed)
          .execute(userId: 'u1', currentBankId: 'bank-1', preset: _preset),
      throwsA(
        isA<UseCaseFailure>().having(
          (e) => e.message,
          'message',
          contains('已阻止写入'),
        ),
      ),
    );
    verifyNever(() => repository.saveBank(any(), any()));
  });

  test('不一致且 verified 时切换题库', () async {
    when(() => repository.saveBank('u1', 'bank-2')).thenAnswer((_) async {});

    final switched = await useCaseWith(WriteLevel.verified)
        .execute(userId: 'u1', currentBankId: 'bank-1', preset: _preset);

    expect(switched, isTrue);
    verify(() => repository.saveBank('u1', 'bank-2')).called(1);
  });
}
