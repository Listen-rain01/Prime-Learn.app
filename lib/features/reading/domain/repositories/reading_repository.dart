import 'package:primelearn/features/reading/domain/entities/reading_catalog.dart';

/// 阅读数据接口。
abstract interface class ReadingRepository {
  /// 一级分类。
  Future<List<ReadingCategory>> fetchCategories();

  /// 子分类。
  Future<List<ReadingCategory>> fetchChildren({
    required String parentId,
    required String departmentId,
  });

  /// 分类下的文章。
  Future<List<ReadingArticle>> fetchArticles({
    required String userId,
    required String typeId,
  });

  /// 完成阅读（计分，按日封顶）。
  ///
  /// 返回 `true` 表示本次调用完成；`false` 表示今日已达上限（平台视为幂等）。
  Future<bool> completeReading({
    required String userId,
    required String articleId,
  });
}
