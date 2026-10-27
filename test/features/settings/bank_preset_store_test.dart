import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/features/settings/data/services/bank_preset_store.dart';
import 'package:primelearn/features/settings/domain/entities/bank_catalog.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('预设读写与清除', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = BankPresetStore(prefs);

    expect(store.read(), isNull);

    await store.save(const BankPreset(bankId: 'bank-1', bankName: '刑法修正案十一'));

    final preset = store.read();
    expect(preset?.bankId, 'bank-1');
    expect(preset?.bankName, '刑法修正案十一');

    await store.clear();
    expect(store.read(), isNull);
  });
}
