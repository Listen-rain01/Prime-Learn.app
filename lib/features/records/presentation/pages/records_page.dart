import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primelearn/core/errors/use_case_failure.dart';
import 'package:primelearn/core/utils/date_formatter.dart';
import 'package:primelearn/features/records/domain/entities/exam_record.dart';
import 'package:primelearn/features/records/domain/entities/ranking_board.dart';
import 'package:primelearn/features/records/presentation/widgets/exam_record_row.dart';
import 'package:primelearn/features/records/presentation/widgets/point_entry_row.dart';
import 'package:primelearn/features/records/presentation/widgets/ranking_entry_row.dart';
import 'package:primelearn/features/records/presentation/widgets/record_format.dart';
import 'package:primelearn/features/records/records_providers.dart';

/// 记录 Tab：考试记录 + 积分明细 + 排名/成绩趋势（均为只读）。
class RecordsPage extends StatelessWidget {
  /// 创建记录页。
  const RecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DefaultTabController(
      length: 3,
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
                Tab(text: '排行'),
              ],
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  _ExamRecordsTab(),
                  _PointsLedgerTab(),
                  _RankingTab(),
                ],
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

/// 排行 Tab：成绩榜 / 学习时长榜（单位 / 集团）+ 个人成绩趋势。
class _RankingTab extends ConsumerStatefulWidget {
  const _RankingTab();

  @override
  ConsumerState<_RankingTab> createState() => _RankingTabState();
}

class _RankingTabState extends ConsumerState<_RankingTab> {
  RankingKind _kind = RankingKind.mark;
  RankingScope _scope = RankingScope.unit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    // 平台页面：成绩排行按本月统计，学习时长排行按本周统计。
    final now = DateTime.now();
    final range = _kind == RankingKind.mark
        ? DateFormatter.monthRange(now)
        : DateFormatter.weekRange(now);
    final query = (
      kind: _kind,
      scope: _scope,
      begin: range.begin,
      end: range.end,
    );
    final board = ref.watch(rankingProvider(query));
    final trend = ref.watch(scoreTrendProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        SegmentedButton<RankingKind>(
          showSelectedIcon: false,
          segments: [
            for (final kind in RankingKind.values)
              ButtonSegment<RankingKind>(value: kind, label: Text(kind.label)),
          ],
          selected: {_kind},
          onSelectionChanged: (selection) =>
              setState(() => _kind = selection.first),
        ),
        const SizedBox(height: 8),
        SegmentedButton<RankingScope>(
          showSelectedIcon: false,
          segments: [
            for (final scope in RankingScope.values)
              ButtonSegment<RankingScope>(
                value: scope,
                label: Text(scope.label),
              ),
          ],
          selected: {_scope},
          onSelectionChanged: (selection) =>
              setState(() => _scope = selection.first),
        ),
        if (_kind == RankingKind.mark) ...[
          const SizedBox(height: 8),
          Text(
            '考试成绩 · 本月',
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ] else ...[
          const SizedBox(height: 8),
          Text(
            '学习时长 · 本周',
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 12),
        board.when(
          loading: () => const _Loading(message: '正在加载排名...'),
          error: (error, _) => _ErrorView(
            message: error is UseCaseFailure ? error.message : '加载失败',
            onRetry: () => ref.invalidate(rankingProvider(query)),
          ),
          data: (value) => value.isEmpty
              ? const _Empty(message: '暂无排名数据')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _myRankText(_kind, value.myRank, value.myMark),
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    for (var index = 0; index < value.entries.length; index++)
                      Column(
                        children: [
                          if (index > 0)
                            Divider(
                              height: 0.5,
                              thickness: 0.5,
                              color: scheme.outlineVariant,
                            ),
                          RankingEntryRow(
                            entry: value.entries[index],
                            valueText: _entryValueText(
                              _kind,
                              value.entries[index],
                            ),
                            isMe:
                                value.entries[index].personName == value.myName,
                          ),
                        ],
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 24),
        Text(
          '我的成绩趋势',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        trend.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: _Loading(message: '正在加载成绩趋势...'),
          ),
          error: (error, _) => _ErrorView(
            message: error is UseCaseFailure ? error.message : '加载失败',
            onRetry: () => ref.invalidate(scoreTrendProvider),
          ),
          data: (points) => points.isEmpty
              ? const _Empty(message: '暂无成绩记录')
              : Column(
                  children: [
                    for (final point in points.take(5))
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 48,
                              child: Text(
                                DateFormatter.date(point.time).length >= 10
                                    ? DateFormatter.date(point.time)
                                          .substring(5)
                                    : '',
                                style: textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                point.examName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurface,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              RecordFormat.score(point.mark),
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: scheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

/// 我的排名文案；成绩榜数值为考试成绩，学习时长榜为时长。
String _myRankText(RankingKind kind, int? rank, double? value) {
  if (rank == null) return '我的排名：暂无';
  final label = switch (kind) {
    RankingKind.mark => '考试成绩',
    RankingKind.studyTime => '学习时长',
  };
  return '我的排名：第 $rank 名 · $label ${_myValueText(kind, value)}';
}

/// 我的排名数值：成绩榜为 `Mark`，学习时长榜按秒展示。
String _myValueText(RankingKind kind, double? value) => switch (kind) {
  RankingKind.mark => value == null ? '暂无' : RecordFormat.score(value),
  RankingKind.studyTime => value == null ? '暂无' : RecordFormat.duration(value),
};

/// 榜单行数值：成绩榜取 `Mark`，学习时长榜取 `AllCount`（秒）。
String _entryValueText(RankingKind kind, RankingEntry entry) => switch (kind) {
  RankingKind.mark => RecordFormat.score(entry.mark),
  RankingKind.studyTime => RecordFormat.duration(entry.allCount),
};

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
