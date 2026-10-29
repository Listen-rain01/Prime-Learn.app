import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:primelearn/core/session/account_memory.dart';

class _MockStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockStorage storage;
  late AccountMemory memory;

  setUp(() {
    storage = _MockStorage();
    memory = AccountMemory(storage: storage);
  });

  test('保存单个账号后可读回', () async {
    when(() => storage.read(key: any(named: 'key'))).thenAnswer(
      (_) async =>
          '[{"idCard":"610525199001011238","password":"p1","userName":"张小赞"}]',
    );

    await memory.save(
      const SavedAccount(
        idCard: '610525199001011238',
        password: 'p1',
        userName: '张小赞',
      ),
    );

    final accounts = await memory.readAll();
    expect(accounts, hasLength(1));
    expect(accounts.first.idCard, '610525199001011238');
    expect(accounts.first.password, 'p1');
    expect(accounts.first.userName, '张小赞');
  });

  test('保存多个账号：最近使用的排最前', () async {
    final stored = <String?>[];
    when(() => storage.read(key: any(named: 'key'))).thenAnswer((_) async {
      return stored.isEmpty ? null : stored.last;
    });
    when(
      () => storage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((invocation) async {
      stored.add(invocation.namedArguments[#value] as String?);
    });

    await memory.save(
      const SavedAccount(idCard: '111', password: 'a', userName: '甲'),
    );
    await memory.save(
      const SavedAccount(idCard: '222', password: 'b', userName: '乙'),
    );

    final accounts = await memory.readAll();
    expect(accounts.map((e) => e.idCard).toList(), ['222', '111']);
    expect((await memory.readRecent())?.idCard, '222');
  });

  test('删除指定账号', () async {
    when(() => storage.read(key: any(named: 'key'))).thenAnswer(
      (_) async =>
          '[{"idCard":"111","password":"a","userName":"甲"},'
          '{"idCard":"222","password":"b","userName":"乙"}]',
    );
    String? written;
    when(
      () => storage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((invocation) async {
      written = invocation.namedArguments[#value] as String?;
    });

    await memory.remove('111');

    expect(written, isNotNull);
    expect(written, contains('222'));
    expect(written, isNot(contains('111')));
  });

  test('清空全部账号', () async {
    when(() => storage.delete(key: any(named: 'key'))).thenAnswer((_) async {});
    await memory.clear();
    verify(() => storage.delete(key: any(named: 'key'))).called(1);
  });
}
