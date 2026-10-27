import 'package:primelearn/features/checkin/data/parsers/check_in_parser.dart';
import 'package:primelearn/features/checkin/data/services/check_in_api.dart';
import 'package:primelearn/features/checkin/domain/entities/check_in_result.dart';
import 'package:primelearn/features/checkin/domain/repositories/check_in_repository.dart';

/// 签到仓储实现。
class CheckInRepositoryImpl implements CheckInRepository {
  /// 创建仓储实现。
  CheckInRepositoryImpl(this._api);

  final CheckInApi _api;
  static const CheckInParser _parser = CheckInParser();

  @override
  Future<CheckInResult> checkIn(String userId) async {
    final body = await _api.checkIn(userId);
    final dto = _parser.parse(body);
    return CheckInResult(
      alreadyCheckedIn: dto.message.contains('已签到'),
      message: dto.message,
    );
  }
}
