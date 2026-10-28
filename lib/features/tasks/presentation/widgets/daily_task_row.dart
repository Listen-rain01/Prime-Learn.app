import 'package:flutter/material.dart';
import 'package:primelearn/features/tasks/domain/entities/daily_task.dart';

/// 今日任务行：直接展示接口字段（名称、规则、进度文案、今日得分/上限）。
class DailyTaskRow extends StatelessWidget {
  /// 创建任务行。
  const DailyTaskRow({required this.task, this.onTap, super.key});

  /// 任务数据。
  final DailyTask task;

  /// 可选的点击动作（目前仅知识学习使用）。
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final secondary = scheme.onSurfaceVariant;
    // 签到 3 分包含连续签到累计，当天最多 +1；currentScore > 0 即今日已签到。
    final checkedInToday =
        task.criterion == Criterion.checkIn && task.currentScore > 0;
    final doneForToday = task.isCompleted || checkedInToday;
    final statusLabel = task.isCompleted
        ? '已完成'
        : checkedInToday
        ? '今日已签到'
        : '未完成';

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.rule,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(color: secondary),
                    ),
                    if (task.progressText.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.progressText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(color: secondary),
                      ),
                    ],
                    if (checkedInToday && !task.isCompleted) ...[
                      const SizedBox(height: 4),
                      Text(
                        '连续签到累计 ${task.currentScore}/${task.maxScore}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(color: secondary),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${task.currentScore}/${task.maxScore}',
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    statusLabel,
                    style: textTheme.labelMedium?.copyWith(
                      color: doneForToday ? scheme.outline : scheme.primary,
                    ),
                  ),
                  if (onTap != null) ...[
                    const SizedBox(height: 4),
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: scheme.outlineVariant,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
