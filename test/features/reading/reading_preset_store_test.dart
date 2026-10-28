import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/features/reading/data/services/reading_preset_store.dart';
import 'package:primelearn/features/reading/domain/entities/reading_catalog.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('阅读预设读写与清除', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = ReadingPresetStore(prefs);

    expect(store.read(), isNull);

    await store.save(
      const ReadingPreset(
        articleId: 'article-1',
        title: '顶板伤人事故',
        typeId: 'type-1',
        typeName: '巷道掘进',
      ),
    );

    final preset = store.read();
    expect(preset?.articleId, 'article-1');
    expect(preset?.title, '顶板伤人事故');
    expect(preset?.typeId, 'type-1');
    expect(preset?.typeName, '巷道掘进');

    await store.clear();
    expect(store.read(), isNull);
  });
}
