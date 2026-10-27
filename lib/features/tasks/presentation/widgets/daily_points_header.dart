import 'package:flutter/material.dart';

/// 首页顶部个人信息与积分块。
class DailyPointsHeader extends StatelessWidget {
  /// 创建积分块。
  const DailyPointsHeader({
    required this.userName,
    required this.bankName,
    this.points,
    super.key,
  });

  /// 用户姓名。
  final String userName;

  /// 当前题库名称。
  final String bankName;

  /// 今日积分；为空时显示占位符。
  final int? points;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                userName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Row(
              children: [
                Icon(Icons.stars_rounded, size: 20, color: scheme.primary),
                const SizedBox(width: 6),
                Text(
                  '今日积分',
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  points?.toString() ?? '—',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '当前题库：$bankName',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
