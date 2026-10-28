import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/features/settings/data/services/bank_preset_store.dart';
import 'package:primelearn/features/settings/domain/entities/bank_catalog.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('预设读写与清除（含题数/试卷数快照）', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = BankPresetStore(prefs);

    expect(store.read(), isNull);

    await store.save(
      const BankPreset(
        bankId: 'bank-1',
        bankName: '刑法修正案十一',
        questionCount: 20,
        paperCount: 1,
        singleCount: 9,
        multipleCount: 4,
        judgeCount: 7,
        paperName: '日常练习',
        paperTotalScore: 100,
        paperPassingGrade: 80,
      ),
    );

    final preset = store.read();
    expect(preset?.bankId, 'bank-1');
    expect(preset?.bankName, '刑法修正案十一');
    expect(preset?.questionCount, 20);
    expect(preset?.paperCount, 1);
    expect(preset?.singleCount, 9);
    expect(preset?.multipleCount, 4);
    expect(preset?.judgeCount, 7);
    expect(preset?.paperName, '日常练习');
    expect(preset?.paperTotalScore, 100);
    expect(preset?.paperPassingGrade, 80);

    await store.clear();
    expect(store.read(), isNull);
  });

  test('旧预设没有题数/试卷数时返回 null 字段', () async {
    SharedPreferences.setMockInitialValues({
      'bank_preset_id': 'bank-1',
      'bank_preset_name': '旧预设',
    });
    final prefs = await SharedPreferences.getInstance();
    final preset = BankPresetStore(prefs).read();

    expect(preset?.bankName, '旧预设');
    expect(preset?.questionCount, isNull);
    expect(preset?.paperCount, isNull);
  });
}
