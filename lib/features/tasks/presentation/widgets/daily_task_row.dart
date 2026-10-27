import 'package:flutter/material.dart';
import 'package:primelearn/features/tasks/domain/entities/daily_task.dart';

/// 今日任务行：直接展示接口字段（名称、规则、进度文案、今日得分/上限）。
class DailyTaskRow extends StatelessWidget {
  /// 创建任务行。
  const DailyTaskRow({required this.task, super.key});

  /// 任务数据。
  final DailyTask task;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final secondary = scheme.onSurfaceVariant;

    return Padding(
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
                task.isCompleted ? '已完成' : '未完成',
                style: textTheme.labelMedium?.copyWith(
                  color: task.isCompleted ? scheme.outline : scheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
