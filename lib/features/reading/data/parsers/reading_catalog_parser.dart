import 'package:primelearn/core/protocol/json_envelope.dart';
import 'package:primelearn/features/reading/domain/entities/reading_catalog.dart';

/// 阅读分类响应解析（`GetAllTypeOne` / `GetAllChildTypeOne`）。
class ReadingCategoryParser {
  /// 创建解析器。
  const ReadingCategoryParser();

  /// 解析分类列表。
  List<ReadingCategory> parse(String body) => JsonEnvelope.list(
    body,
    label: '阅读分类',
  ).map(_toCategory).toList(growable: false);

  ReadingCategory _toCategory(Map<String, dynamic> json) => ReadingCategory(
    id: _asText(json['KnowledgeTypeId']),
    name: _asText(json['TypeName']),
    departmentId: _asText(json['DepartmentId']),
  );
}

/// 阅读文章响应解析（`GetStudyOne`）。
class ReadingArticleParser {
  /// 创建解析器。
  const ReadingArticleParser();

  /// 解析文章列表。
  List<ReadingArticle> parse(String body) => JsonEnvelope.list(
    body,
    label: '阅读文章',
  ).map(_toArticle).toList(growable: false);

  ReadingArticle _toArticle(Map<String, dynamic> json) => ReadingArticle(
    id: _asText(json['KnowledgeSubjectId']),
    title: _asText(json['Title']),
    style: _asInt(json['Style']),
  );
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim()) ?? 0;
  return 0;
}

String _asText(Object? value) => value?.toString().trim() ?? '';
