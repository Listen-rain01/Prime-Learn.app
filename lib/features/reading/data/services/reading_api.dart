import 'package:primelearn/core/network/api_client.dart';
import 'package:primelearn/core/protocol/esdt_codec.dart';
import 'package:primelearn/features/reading/domain/reading_endpoints.dart';

/// 阅读学习接口封装。
class ReadingApi {
  /// 创建 API 封装。
  ReadingApi(this._client);

  final ApiClient _client;
  static const EsdtCodec _esdt = EsdtCodec();

  /// 一级分类。
  Future<String> fetchCategories() => _client.getRaw(readingCategoriesEndpoint);

  /// 子分类（`pid` / `did` 需 Esdt）。
  Future<String> fetchChildren({
    required String parentId,
    required String departmentId,
  }) => _client.getRaw(
    '$readingChildrenEndpoint'
    '?pid=${_esdt.encode(parentId)}'
    '&did=${_esdt.encode(departmentId)}',
  );

  /// 分类下的文章（`typeid` / `pid` 明文）。
  Future<String> fetchArticles({
    required String userId,
    required String typeId,
  }) => _client.getRaw(
    '$readingArticlesEndpoint'
    '?typeid=$typeId&pid=$userId&page=1&rows=20',
  );

  /// 完成阅读（`pid` / `zsid` 需 Esdt）。
  Future<String> completeReading({
    required String userId,
    required String articleId,
  }) => _client.getRaw(
    '$studyKnowledgeEndpoint'
    '?pid=${_esdt.encode(userId)}'
    '&zsid=${_esdt.encode(articleId)}',
  );
}
