import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/core/protocol/json_envelope.dart';
import 'package:primelearn/features/reading/data/parsers/reading_catalog_parser.dart';
import 'package:primelearn/features/reading/data/services/reading_api.dart';
import 'package:primelearn/features/reading/domain/entities/reading_catalog.dart';
import 'package:primelearn/features/reading/domain/repositories/reading_repository.dart';

/// 阅读数据仓库实现。
class ReadingRepositoryImpl implements ReadingRepository {
  /// 创建仓库。
  ReadingRepositoryImpl(
    this._api, {
    this.categoryParser = const ReadingCategoryParser(),
    this.articleParser = const ReadingArticleParser(),
  });

  final ReadingApi _api;
  final ReadingCategoryParser categoryParser;
  final ReadingArticleParser articleParser;

  @override
  Future<List<ReadingCategory>> fetchCategories() async =>
      categoryParser.parse(await _api.fetchCategories());

  @override
  Future<List<ReadingCategory>> fetchChildren({
    required String parentId,
    required String departmentId,
  }) async => categoryParser.parse(
    await _api.fetchChildren(parentId: parentId, departmentId: departmentId),
  );

  @override
  Future<List<ReadingArticle>> fetchArticles({
    required String userId,
    required String typeId,
  }) async => articleParser.parse(
    await _api.fetchArticles(userId: userId, typeId: typeId),
  );

  @override
  Future<bool> completeReading({
    required String userId,
    required String articleId,
  }) async {
    try {
      // 平台成功返回 success=true；失败时 JsonEnvelope 会带出 message。
      JsonEnvelope.decode(
        await _api.completeReading(userId: userId, articleId: articleId),
        label: '完成阅读',
      );
      return true;
    } on ApiException catch (error) {
      // 当日已达上限是幂等结果，不算失败。
      if (_meansDailyLimitReached(error.message)) return false;
      rethrow;
    }
  }

  /// 判断文案是否表达「今日已达上限」。
  ///
  /// 平台实际文案会变（实测出现过「已达到或超过每日最多积分!」「已达每日上限!」
  /// 「今天已经完成知识学习」等），因此按关键词组合判定，而不是匹配整句；
  /// 同时要求出现「上限/最多/已完成」这类语义，避免把真正的失败吞成成功。
  bool _meansDailyLimitReached(String message) {
    if (message.isEmpty) return false;
    final reached =
        message.contains('上限') ||
        message.contains('最多') ||
        message.contains('已完成') ||
        message.contains('已经完成');
    if (!reached) return false;
    return message.contains('积分') ||
        message.contains('每日') ||
        message.contains('今日') ||
        message.contains('知识学习');
  }
}
