import 'package:flutter/material.dart';
import 'package:primelearn/features/records/domain/entities/ranking_board.dart';

/// 榜单中的一行：排名、姓名/单位、数值（得分或时长）。
class RankingEntryRow extends StatelessWidget {
  /// 创建榜单行。
  const RankingEntryRow({
    super.key,
    required this.entry,
    required this.valueText,
    this.isMe = false,
  });

  /// 榜单条目。
  final RankingEntry entry;

  /// 右侧数值文案；为 null 时不显示（口径未确认的榜单）。
  final String? valueText;

  /// 是否为当前用户（用于高亮）。
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              '${entry.rank}',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: entry.rank <= 3
                    ? scheme.primary
                    : scheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.personName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: isMe ? FontWeight.w700 : FontWeight.w500,
                    color: isMe ? scheme.primary : scheme.onSurface,
                  ),
                ),
                if (entry.department.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    entry.department,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (valueText != null) ...[
            const SizedBox(width: 12),
            Text(
              valueText!,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
