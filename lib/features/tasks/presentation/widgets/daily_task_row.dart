import 'package:flutter/material.dart';
import 'package:primelearn/features/tasks/domain/entities/daily_task.dart';

/// 今日任务行。
///
/// 可执行任务显示名称/规则/进度 + 分数/状态；
/// 暂不执行任务淡化显示，只保留名称与「暂不执行」。
class DailyTaskRow extends StatelessWidget {
  /// 创建任务行。
  const DailyTaskRow({required this.task, this.pending = false, super.key});

  /// 任务数据。
  final DailyTask task;

  /// 是否属于「暂不执行」分组。
  final bool pending;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final secondary = scheme.onSurfaceVariant;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: pending ? 10 : 14),
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
                    color: pending ? secondary : scheme.onSurface,
                  ),
                ),
                if (!pending) ...[
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
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                task.score.toString(),
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: pending ? scheme.outline : scheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                pending ? '暂不执行' : (task.isCompleted ? '已完成' : '未完成'),
                style: textTheme.labelMedium?.copyWith(
                  color: pending || task.isCompleted
                      ? scheme.outline
                      : scheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
