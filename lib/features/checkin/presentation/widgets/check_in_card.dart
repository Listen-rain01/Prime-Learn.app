import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primelearn/core/errors/use_case_failure.dart';
import 'package:primelearn/core/session/session_store.dart';
import 'package:primelearn/core/widgets/inline_notice.dart';
import 'package:primelearn/core/widgets/tonal_block.dart';
import 'package:primelearn/features/checkin/check_in_providers.dart';

/// 今日签到卡：签到按钮、结果与拦截提示。
class CheckInCard extends ConsumerWidget {
  /// 创建签到卡。
  const CheckInCard({
    super.key,
    required this.alreadyCheckedIn,
    this.onSuccess,
    this.inSheet = false,
  });

  /// 今日是否已签到（来自每日任务的 CheckIn 进度）。
  final bool alreadyCheckedIn;

  /// 签到成功后的回调（用于刷新今日任务）。
  final VoidCallback? onSuccess;

  /// 是否作为弹层内容展示（不再套 TonalBlock）。
  final bool inSheet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(checkInControllerProvider);
    final submitting = state.isLoading;
    final result = state.value;
    final error = state.error;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '今日签到',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '每日签到 1 分，连续登录每日多 1 分，最多 3 分',
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '平台要求：当日完成 50 题（手机考试/模拟考试累计）才能签到',
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.tonal(
              onPressed: alreadyCheckedIn || submitting
                  ? null
                  : () => _submit(context, ref),
              child: submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(alreadyCheckedIn ? '已签到' : '签到'),
            ),
          ],
        ),
        if (error is UseCaseFailure) ...[
          const SizedBox(height: 10),
          InlineNotice(message: error.message),
        ],
        if (result != null) ...[
          const SizedBox(height: 10),
          Text(
            result.displayMessage,
            style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.primary,
            ),
          ),
        ],
      ],
    );
    if (inSheet) return content;
    return TonalBlock(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: content,
    );
  }

  /// 提交签到。
  ///
  /// 弹层可能在等待期间被关闭，之后不能再碰 ref/回调（会抛已 dispose）；
  /// 会话失效时统一清会话，由 App 层跳回登录页。
  Future<void> _submit(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(checkInControllerProvider.notifier);
    await notifier.submit();
    if (!context.mounted) return;
    final next = ref.read(checkInControllerProvider);
    final failure = next.error;
    if (failure is UseCaseFailure && failure.sessionExpired) {
      ref.read(sessionStoreProvider.notifier).clear();
      return;
    }
    if (next.hasValue && next.value != null) {
      onSuccess?.call();
    }
  }
}
