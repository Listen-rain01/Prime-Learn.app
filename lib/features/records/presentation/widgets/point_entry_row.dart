import 'package:flutter/material.dart';
import 'package:primelearn/core/utils/date_formatter.dart';
import 'package:primelearn/features/records/domain/entities/point_entry.dart';

/// 积分明细行。
class PointEntryRow extends StatelessWidget {
  /// 创建明细行。
  const PointEntryRow({required this.entry, super.key});

  /// 明细数据。
  final PointEntry entry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final positive = entry.amount >= 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                if (entry.date != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    DateFormatter.dateTime(entry.date),
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            positive ? '+${entry.amount}' : '${entry.amount}',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: positive ? scheme.primary : scheme.error,
            ),
          ),
        ],
      ),
    );
  }
}
