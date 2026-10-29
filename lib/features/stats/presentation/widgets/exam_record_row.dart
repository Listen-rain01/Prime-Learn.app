import 'package:flutter/material.dart';
import 'package:primelearn/core/utils/date_formatter.dart';
import 'package:primelearn/features/stats/domain/entities/exam_record.dart';

/// 考试记录行。
class ExamRecordRow extends StatelessWidget {
  /// 创建记录行。
  const ExamRecordRow({required this.record, super.key});

  /// 记录数据。
  final ExamRecord record;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final meta = [
      if (record.examType.isNotEmpty) record.examType,
      if (record.startTime != null) DateFormatter.dateTime(record.startTime),
    ].join(' · ');
    final score = record.isWholeMark
        ? record.mark.round().toString()
        : record.mark.toStringAsFixed(1);

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
                  record.examName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  meta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                score,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                record.qualified ? '合格' : '不合格',
                style: textTheme.labelMedium?.copyWith(
                  color: record.qualified ? scheme.primary : scheme.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
