import 'package:flutter_test/flutter_test.dart';
import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/features/reading/data/parsers/reading_catalog_parser.dart';

void main() {
  const categoryParser = ReadingCategoryParser();
  const articleParser = ReadingArticleParser();

  test('解析一级分类与子分类', () {
    final categories = categoryParser.parse('''
{"success": true, "data": [
  {"KnowledgeTypeId": "type-1", "TypeName": "股份事故案例", "DepartmentId": "1"}
]}''');

    expect(categories.single.id, 'type-1');
    expect(categories.single.name, '股份事故案例');
    expect(categories.single.departmentId, '1');
  });

  test('解析文章列表', () {
    final articles = articleParser.parse('''
{"success": true, "data": [
  {"KnowledgeSubjectId": "article-1", "Title": "顶板伤人事故", "Style": 0, "CreateTime": "2026-10-20T10:00:00"}
]}''');

    expect(articles.single.id, 'article-1');
    expect(articles.single.title, '顶板伤人事故');
    expect(articles.single.style, 0);
  });

  test('success=false 透传服务端文案', () {
    expect(
      () => categoryParser.parse('{"success": false, "message": "无权限"}'),
      throwsA(isA<ApiException>().having((e) => e.message, 'message', '无权限')),
    );
  });

  test('空响应抛协议异常', () {
    expect(
      () => articleParser.parse(''),
      throwsA(
        isA<ApiException>().having((e) => e.message, 'message', '服务器返回空响应'),
      ),
    );
  });
}
