import 'package:flutter/material.dart';
import 'package:primelearn/features/checkin/presentation/widgets/check_in_card.dart';

/// 打开签到执行弹层（与考试/阅读统一入口）。
Future<void> showCheckInSheet(
  BuildContext context, {
  required bool alreadyCheckedIn,
  VoidCallback? onSuccess,
}) => showModalBottomSheet<void>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('签到', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          CheckInCard(
            alreadyCheckedIn: alreadyCheckedIn,
            onSuccess: onSuccess,
            inSheet: true,
          ),
        ],
      ),
    ),
  ),
);
