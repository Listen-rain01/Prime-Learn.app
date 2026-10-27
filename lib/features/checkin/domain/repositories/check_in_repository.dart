import 'package:primelearn/features/checkin/domain/entities/check_in_result.dart';

/// 签到数据接口。
abstract interface class CheckInRepository {
  /// 执行签到。
  Future<CheckInResult> checkIn(String userId);
}
