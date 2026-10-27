import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:primelearn/core/errors/use_case_failure.dart';
import 'package:primelearn/features/exam/domain/entities/exam_paper.dart';
import 'package:primelearn/features/exam/domain/repositories/exam_repository.dart';
import 'package:primelearn/features/settings/application/save_bank_preset.dart';
import 'package:primelearn/features/settings/domain/entities/bank_catalog.dart';
import 'package:primelearn/features/settings/domain/repositories/bank_preset_repository.dart';

class _MockExamRepository extends Mock implements ExamRepository {}

class _MockBankPresetRepository extends Mock implements BankPresetRepository {}

const _preset = BankPreset(bankId: 'bank-2', bankName: '目标题库');

void main() {
  late _MockExamRepository examRepository;
  late _MockBankPresetRepository presetRepository;

  setUpAll(
    () => registerFallbackValue(
      const BankPreset(bankId: 'bank-x', bankName: 'x'),
    ),
  );

  setUp(() {
    examRepository = _MockExamRepository();
    presetRepository = _MockBankPresetRepository();
  });

  test('题库没有试卷时拒绝保存', () async {
    when(
      () => examRepository.fetchPapers(
        userId: any(named: 'userId'),
        bankId: any(named: 'bankId'),
      ),
    ).thenAnswer((_) async => const []);

    await expectLater(
      SaveBankPreset(
        examRepository,
        presetRepository,
      ).execute(userId: 'u1', preset: _preset),
      throwsA(
        isA<UseCaseFailure>().having(
          (e) => e.message,
          'message',
          '该题库没有可开考试卷，无法用于考试',
        ),
      ),
    );
    verifyNever(() => presetRepository.save(any()));
  });

  test('有试卷时保存预设', () async {
    when(
      () => examRepository.fetchPapers(
        userId: any(named: 'userId'),
        bankId: any(named: 'bankId'),
      ),
    ).thenAnswer(
      (_) async => const [
        ExamPaper(id: 'p1', name: '试卷 A', totalScore: 100, passingGrade: 80),
      ],
    );
    when(() => presetRepository.save(any())).thenAnswer((_) async {});

    await SaveBankPreset(
      examRepository,
      presetRepository,
    ).execute(userId: 'u1', preset: _preset);

    verify(() => presetRepository.save(_preset)).called(1);
  });
}
