import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:primelearn/core/evidence/write_evidence.dart';
import 'package:primelearn/core/evidence/write_gateway.dart';
import 'package:primelearn/core/evidence/write_level.dart';
import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/core/session/session.dart';
import 'package:primelearn/core/session/session_store.dart';
import 'package:primelearn/features/checkin/check_in_providers.dart';
import 'package:primelearn/features/checkin/domain/check_in_endpoint.dart';
import 'package:primelearn/features/checkin/domain/entities/check_in_result.dart';
import 'package:primelearn/features/checkin/domain/repositories/check_in_repository.dart';
import 'package:primelearn/features/checkin/presentation/widgets/check_in_card.dart';

class _MockCheckInRepository extends Mock implements CheckInRepository {}

void main() {
  late _MockCheckInRepository repository;

  setUp(() {
    repository = _MockCheckInRepository();
  });

  Future<void> pumpCard(
    WidgetTester tester, {
    required WriteLevel level,
    bool alreadyCheckedIn = false,
  }) async {
    final container = ProviderContainer(
      overrides: [
        checkInRepositoryProvider.overrideWithValue(repository),
        writeGatewayProvider.overrideWithValue(
          WriteGateway(WriteEvidence({checkInEndpoint: level})),
        ),
      ],
    );
    addTearDown(container.dispose);
    container
        .read(sessionStoreProvider.notifier)
        .save(const Session(userId: 'u1', userName: '张小赞'));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(body: CheckInCard(alreadyCheckedIn: alreadyCheckedIn)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('签到成功展示结果', (tester) async {
    when(() => repository.checkIn('u1')).thenAnswer(
      (_) async =>
          const CheckInResult(alreadyCheckedIn: false, message: '操作成功'),
    );
    await pumpCard(tester, level: WriteLevel.verified);

    await tester.tap(find.text('签到'));
    await tester.pumpAndSettle();

    expect(find.text('签到成功'), findsOneWidget);
    verify(() => repository.checkIn('u1')).called(1);
  });

  testWidgets('证据不足时提示拦截，且不发请求', (tester) async {
    await pumpCard(tester, level: WriteLevel.observed);

    await tester.tap(find.text('签到'));
    await tester.pumpAndSettle();

    expect(find.textContaining('已阻止写入'), findsOneWidget);
    verifyNever(() => repository.checkIn(any()));
  });

  testWidgets('服务端前置条件不满足时展示原文案', (tester) async {
    when(() => repository.checkIn('u1')).thenThrow(
      const ApiException(kind: ApiErrorKind.protocol, message: '练习50题后才能签到!'),
    );
    await pumpCard(tester, level: WriteLevel.verified);

    await tester.tap(find.text('签到'));
    await tester.pumpAndSettle();

    expect(find.text('练习50题后才能签到!'), findsOneWidget);
    verify(() => repository.checkIn('u1')).called(1);
  });

  testWidgets('已签到时按钮禁用', (tester) async {
    await pumpCard(tester, level: WriteLevel.verified, alreadyCheckedIn: true);

    expect(find.text('已签到'), findsOneWidget);
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
    verifyNever(() => repository.checkIn(any()));
  });
}
