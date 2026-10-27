import 'package:primelearn/core/protocol/json_envelope.dart';
import 'package:primelearn/features/checkin/data/models/check_in_dto.dart';

/// 签到响应解析：`{success, data, message}`，用 `message` 区分首次/已签到。
class CheckInParser {
  /// 创建解析器。
  const CheckInParser();

  /// 解析签到结果；`success=false` 由 [JsonEnvelope] 抛错。
  CheckInDto parse(String body) =>
      CheckInDto.fromJson(JsonEnvelope.decode(body, label: '签到'));
}
