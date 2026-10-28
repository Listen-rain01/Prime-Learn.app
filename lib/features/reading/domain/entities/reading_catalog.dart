/// 阅读分类（一级/子分类共用）。
class ReadingCategory {
  /// 创建分类。
  const ReadingCategory({
    required this.id,
    required this.name,
    this.departmentId = '',
  });

  /// 分类 ID。
  final String id;

  /// 分类名称。
  final String name;

  /// 所属单位 ID（仅一级分类有，用于查询子分类）。
  final String departmentId;
}

/// 阅读文章。
class ReadingArticle {
  /// 创建文章。
  const ReadingArticle({required this.id, required this.title, this.style = 0});

  /// 文章 ID（完成阅读的 `zsid`）。
  final String id;

  /// 标题。
  final String title;

  /// `0` 普通文章，非 0 为 PDF。
  final int style;
}

/// 阅读预设：每天要完成的那篇文章。
class ReadingPreset {
  /// 创建预设。
  const ReadingPreset({
    required this.articleId,
    required this.title,
    this.typeId = '',
    this.typeName = '',
  });

  /// 文章 ID。
  final String articleId;

  /// 文章标题。
  final String title;

  /// 文章所属子分类 ID。
  final String typeId;

  /// 子分类名称，用于展示。
  final String typeName;
}
