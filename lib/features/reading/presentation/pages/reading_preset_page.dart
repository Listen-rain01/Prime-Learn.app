import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primelearn/core/errors/use_case_failure.dart';
import 'package:primelearn/core/widgets/inline_notice.dart';
import 'package:primelearn/features/reading/domain/entities/reading_catalog.dart';
import 'package:primelearn/features/reading/reading_providers.dart';

/// 阅读预设页：选定每天要读的文章，并可一键完成今日阅读。
class ReadingPresetPage extends ConsumerStatefulWidget {
  /// 创建阅读预设页。
  const ReadingPresetPage({super.key});

  @override
  ConsumerState<ReadingPresetPage> createState() => _ReadingPresetPageState();
}

class _ReadingPresetPageState extends ConsumerState<ReadingPresetPage> {
  ReadingCategory? _category;
  ReadingCategory? _child;
  ReadingArticle? _article;
  String? _typeId;
  String _typeName = '';
  bool _hasChildren = false;
  String? _message;
  bool _messageIsError = false;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final preset = ref.watch(readingPresetProvider);
    final categories = ref.watch(readingCategoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('阅读预设')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          _SummaryCard(preset: preset),
          const SizedBox(height: 20),
          Text(
            '选择文章',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
          _SelectorRow(
            label: '分类',
            value: _category?.name,
            placeholder: '选择分类',
            loading: categories.isLoading,
            onTap: categories.value == null || categories.value!.isEmpty
                ? null
                : () => _pickCategory(categories.value!),
          ),
          if (_hasChildren)
            _SelectorRow(
              label: '子分类',
              value: _child?.name,
              placeholder: '选择子分类',
              onTap: () => _pickChild(),
            ),
          if (_typeId != null)
            _SelectorRow(
              label: '文章',
              value: _article?.title,
              placeholder: '选择文章',
              onTap: () => _pickArticle(_typeId!),
            ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '预设一篇文章；每天点上方「完成今日阅读」即可调用接口完成阅读。',
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '知识学习按日封顶 1 分，重复完成不会重复计分。',
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (_message != null) ...[
            const SizedBox(height: 16),
            InlineNotice(
              message: _message!,
              tone: _messageIsError
                  ? InlineNoticeTone.error
                  : InlineNoticeTone.success,
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: FilledButton(
          onPressed: _article != null && !_saving ? _save : null,
          child: Text(_saving ? '保存中...' : '保存阅读预设'),
        ),
      ),
    );
  }

  Future<void> _pickCategory(List<ReadingCategory> categories) async {
    final choice = await showModalBottomSheet<ReadingCategory>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _ChoiceSheet<ReadingCategory>(
        title: '选择分类',
        items: categories,
        labelOf: (item) => item.name,
      ),
    );
    if (choice == null) return;
    setState(() {
      _category = choice;
      _child = null;
      _article = null;
      _typeId = null;
      _typeName = '';
      _hasChildren = false;
      _message = null;
    });
    try {
      final children = await ref.read(
        readingChildrenProvider((
          parentId: choice.id,
          departmentId: choice.departmentId,
        )).future,
      );
      if (!mounted) return;
      if (children.isEmpty) {
        setState(() {
          _typeId = choice.id;
          _typeName = choice.name;
          _hasChildren = false;
        });
        await _pickArticle(choice.id);
      } else {
        setState(() => _hasChildren = true);
        await Future<void>.delayed(const Duration(milliseconds: 200));
        if (!mounted) return;
        await _pickChild(children: children);
      }
    } on Object {
      // 子分类加载失败时停在当前步，可手动重试。
    }
  }

  Future<void> _pickChild({List<ReadingCategory>? children}) async {
    final category = _category;
    if (category == null) return;
    final List<ReadingCategory> list =
        children ??
        await ref.read(
          readingChildrenProvider((
            parentId: category.id,
            departmentId: category.departmentId,
          )).future,
        );
    if (!mounted) return;
    if (list.isEmpty) {
      setState(() {
        _typeId = category.id;
        _typeName = category.name;
        _hasChildren = false;
      });
      await _pickArticle(category.id);
      return;
    }
    final choice = await showModalBottomSheet<ReadingCategory>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _ChoiceSheet<ReadingCategory>(
        title: '选择子分类',
        contextLabel: category.name,
        items: list,
        labelOf: (item) => item.name,
      ),
    );
    if (choice == null) return;
    setState(() {
      _child = choice;
      _typeId = choice.id;
      _typeName = choice.name;
      _article = null;
      _message = null;
    });
    await _pickArticle(choice.id);
  }

  Future<void> _pickArticle(String typeId) async {
    try {
      final articles = await ref.read(readingArticlesProvider(typeId).future);
      if (!mounted) return;
      if (articles.isEmpty) {
        setState(() {
          _message = '该分类下暂无文章';
          _messageIsError = true;
        });
        return;
      }
      final choice = await showModalBottomSheet<ReadingArticle>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => _ChoiceSheet<ReadingArticle>(
          title: '选择文章',
          contextLabel: _typeName,
          items: articles,
          labelOf: (item) => item.title,
          subtitleOf: (item) => item.style == 0 ? '' : 'PDF 文档',
        ),
      );
      if (choice == null) return;
      setState(() {
        _article = choice;
        _message = null;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _message = error is UseCaseFailure ? error.message : '文章加载失败';
        _messageIsError = true;
      });
    }
  }

  Future<void> _save() async {
    final article = _article!;
    final useCase = await ref.read(saveReadingPresetProvider.future);
    setState(() => _saving = true);
    try {
      await useCase.execute(
        ReadingPreset(
          articleId: article.id,
          title: article.title,
          typeId: _typeId ?? '',
          typeName: _typeName,
        ),
      );
      ref.invalidate(readingPresetProvider);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on UseCaseFailure catch (error) {
      if (!mounted) return;
      setState(() {
        _message = error.message;
        _messageIsError = true;
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

/// 顶部：当前阅读预设。
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.preset});

  final AsyncValue<ReadingPreset?> preset;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return preset.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, _) => const Text('读取阅读预设失败'),
      data: (value) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '当前阅读预设',
                    style: textTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: value == null
                        ? scheme.surfaceContainerHigh
                        : scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    value == null ? '未设置' : '已设置',
                    style: textTheme.labelSmall?.copyWith(
                      color: value == null
                          ? scheme.onSurfaceVariant
                          : scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value?.title ?? '还没有设置阅读文章',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
            if (value != null && value.typeName.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                value.typeName,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 单行选择器。
class _SelectorRow extends StatelessWidget {
  const _SelectorRow({
    required this.label,
    required this.value,
    required this.placeholder,
    required this.onTap,
    this.loading = false,
  });

  final String label;
  final String? value;
  final String placeholder;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasValue = value != null && value!.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
        child: Row(
          children: [
            SizedBox(
              width: 64,
              child: Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              child: Text(
                hasValue ? value! : (loading ? '加载中...' : placeholder),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyLarge?.copyWith(
                  color: hasValue ? scheme.onSurface : scheme.outline,
                  fontWeight: hasValue ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
            if (loading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(Icons.chevron_right, color: scheme.outlineVariant),
          ],
        ),
      ),
    );
  }
}

/// 通用单选弹层（带搜索）。
class _ChoiceSheet<T> extends StatefulWidget {
  const _ChoiceSheet({
    required this.title,
    required this.items,
    required this.labelOf,
    this.subtitleOf,
    this.contextLabel = '',
  });

  final String title;
  final List<T> items;
  final String Function(T) labelOf;
  final String Function(T)? subtitleOf;
  final String contextLabel;

  @override
  State<_ChoiceSheet<T>> createState() => _ChoiceSheetState<T>();
}

class _ChoiceSheetState<T> extends State<_ChoiceSheet<T>> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final filtered = widget.items
        .where(
          (item) => widget
              .labelOf(item)
              .toLowerCase()
              .contains(_query.trim().toLowerCase()),
        )
        .toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.title, style: textTheme.titleMedium),
            const SizedBox(height: 2),
            Text(
              widget.contextLabel.isEmpty
                  ? '共 ${widget.items.length} 项'
                  : '${widget.contextLabel} · 共 ${widget.items.length} 项',
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: '搜索',
                isDense: true,
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  final subtitle = widget.subtitleOf?.call(item) ?? '';
                  return ListTile(
                    title: Text(widget.labelOf(item)),
                    subtitle: subtitle.isEmpty ? null : Text(subtitle),
                    onTap: () => Navigator.of(context).pop(item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
