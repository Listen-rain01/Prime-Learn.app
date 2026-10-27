import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 命名与分层约定的自动化守卫。
///
/// 把 AGENTS.md §3.5 / §3.7 / §4.1 的规则变成测试，
/// 避免"文档写了但代码慢慢跑偏"。
void main() {
  final libFiles = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList();

  Iterable<String> importsOf(File file) sync* {
    final pattern = RegExp(r"""^\s*import\s+'([^']+)'""");
    for (final line in file.readAsLinesSync()) {
      final match = pattern.firstMatch(line);
      final uri = match?.group(1);
      if (uri != null) yield uri;
    }
  }

  bool importsAny(File file, List<String> needles) =>
      importsOf(file).any((uri) => needles.any(uri.contains));

  List<File> filesUnder(String prefix) => libFiles
      .where((file) => file.path.replaceAll(r'\', '/').startsWith(prefix))
      .toList();

  test('Dart 文件名使用 lower_snake_case', () {
    final invalid = <String>[];
    final pattern = RegExp(r'^[a-z0-9_]+(\.[a-z0-9_]+)*\.dart$');
    for (final file in libFiles) {
      final name = file.uri.pathSegments.last;
      if (!pattern.hasMatch(name)) invalid.add(file.path);
    }
    expect(
      invalid,
      isEmpty,
      reason: '以下文件名不符合 lower_snake_case：\n${invalid.join('\n')}',
    );
  });

  test('core 不 import features', () {
    final violations = filesUnder('lib/core/')
        .where(
          (file) => importsAny(file, ['primelearn/features/', '/features/']),
        )
        .map((file) => file.path)
        .toList();
    expect(
      violations,
      isEmpty,
      reason: 'core 反向依赖了业务功能：\n${violations.join('\n')}',
    );
  });

  test('presentation 不直接 import data', () {
    final violations = <String>[];
    for (final feature in Directory(
      'lib/features',
    ).listSync().whereType<Directory>()) {
      final prefix = '${feature.path.replaceAll(r'\', '/')}/presentation/';
      for (final file in filesUnder(prefix)) {
        if (importsAny(file, ['/data/'])) violations.add(file.path);
      }
    }
    expect(
      violations,
      isEmpty,
      reason: '页面层直接依赖了 data：\n${violations.join('\n')}',
    );
  });

  test('application 不 import data', () {
    final violations = <String>[];
    for (final feature in Directory(
      'lib/features',
    ).listSync().whereType<Directory>()) {
      final prefix = '${feature.path.replaceAll(r'\', '/')}/application/';
      for (final file in filesUnder(prefix)) {
        if (importsAny(file, ['/data/'])) violations.add(file.path);
      }
    }
    expect(
      violations,
      isEmpty,
      reason: '用例层直接依赖了 data：\n${violations.join('\n')}',
    );
  });

  test('domain 不依赖 Flutter / Dio / JSON / Riverpod', () {
    final forbidden = [
      'package:flutter/',
      'package:dio/',
      'dart:convert',
      'dart:ui',
      'package:riverpod',
    ];
    final violations = <String>[];
    for (final feature in Directory(
      'lib/features',
    ).listSync().whereType<Directory>()) {
      final prefix = '${feature.path.replaceAll(r'\', '/')}/domain/';
      for (final file in filesUnder(prefix)) {
        if (importsAny(file, forbidden)) violations.add(file.path);
      }
    }
    expect(
      violations,
      isEmpty,
      reason: 'domain 混入了框架依赖：\n${violations.join('\n')}',
    );
  });

  test('feature 目录名在约定集合内', () {
    const allowed = {
      'auth',
      'tasks',
      'records',
      'exam',
      'reading',
      'stats',
      'settings',
      'agent',
    };
    final names = Directory('lib/features')
        .listSync()
        .whereType<Directory>()
        .map((dir) => dir.uri.pathSegments.where((s) => s.isNotEmpty).last)
        .toSet();
    expect(names.difference(allowed), isEmpty, reason: '出现未约定的 feature 目录');
  });
}
