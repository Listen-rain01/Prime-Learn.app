import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primelearn/core/errors/use_case_failure.dart';
import 'package:primelearn/features/records/domain/entities/exam_record.dart';
import 'package:primelearn/features/records/presentation/widgets/exam_record_row.dart';
import 'package:primelearn/features/records/presentation/widgets/point_entry_row.dart';
import 'package:primelearn/features/records/records_providers.dart';

/// 记录 Tab：考试记录 + 积分明细（均为只读）。
class RecordsPage extends StatelessWidget {
  /// 创建记录页。
  const RecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                '记录',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
            ),
            TabBar(
              labelColor: scheme.primary,
              unselectedLabelColor: scheme.onSurfaceVariant,
              indicatorColor: scheme.primary,
              tabs: const [
                Tab(text: '考试'),
                Tab(text: '积分'),
              ],
            ),
            const Expanded(
              child: TabBarView(
                children: [_ExamRecordsTab(), _PointsLedgerTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExamRecordsTab extends ConsumerStatefulWidget {
  const _ExamRecordsTab();

  @override
  ConsumerState<_ExamRecordsTab> createState() => _ExamRecordsTabState();
}

class _ExamRecordsTabState extends ConsumerState<_ExamRecordsTab> {
  ExamRecordCategory _category = ExamRecordCategory.mobile;

  @override
  Widget build(BuildContext context) {
    final records = ref.watch(examRecordsProvider(_category));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: SegmentedButton<ExamRecordCategory>(
            showSelectedIcon: false,
            segments: [
              for (final category in ExamRecordCategory.values)
                ButtonSegment<ExamRecordCategory>(
                  value: category,
                  label: Text(category.label),
                ),
            ],
            selected: {_category},
            onSelectionChanged: (selection) =>
                setState(() => _category = selection.first),
          ),
        ),
        Expanded(
          child: records.when(
            loading: () => const _Loading(message: '正在加载考试记录...'),
            error: (error, _) => _ErrorView(
              message: error is UseCaseFailure ? error.message : '加载失败',
              onRetry: () => ref.invalidate(examRecordsProvider(_category)),
            ),
            data: (list) => list.isEmpty
                ? const _Empty(message: '暂无考试记录')
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    itemCount: list.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      thickness: 0.5,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    itemBuilder: (context, index) =>
                        ExamRecordRow(record: list[index]),
                  ),
          ),
        ),
      ],
    );
  }
}

class _PointsLedgerTab extends ConsumerWidget {
  const _PointsLedgerTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(pointsLedgerProvider);

    return entries.when(
      loading: () => const _Loading(message: '正在加载积分明细...'),
      error: (error, _) => _ErrorView(
        message: error is UseCaseFailure ? error.message : '加载失败',
        onRetry: () => ref.invalidate(pointsLedgerProvider),
      ),
      data: (list) => list.isEmpty
          ? const _Empty(message: '暂无积分记录')
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              itemCount: list.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                thickness: 0.5,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              itemBuilder: (context, index) =>
                  PointEntryRow(entry: list[index]),
            ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(color: scheme.onSurfaceVariant),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '加载失败',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }
}
