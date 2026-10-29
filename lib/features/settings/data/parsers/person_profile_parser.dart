import 'package:primelearn/core/network/api_exception.dart';
import 'package:primelearn/core/protocol/v_data_extractor.dart';
import 'package:primelearn/features/settings/data/models/person_profile_dto.dart';

/// 个人信息响应解析。
///
/// `POST /PersonWap/MyBaseInfo` 返回 HTML，基础资料在 HTML 内嵌的
/// `var vData = { ... };` 里，因此需要先从 HTML 中提取 JSON。
/// 只读取白名单字段，其余内容（含照片路径等）不保留。
class PersonProfileParser {
  /// 创建解析器。
  const PersonProfileParser();

  /// 从 HTML 中解析个人信息。
  PersonProfileDto parse(String html) {
    if (html.isEmpty) {
      throw const ApiException(
        kind: ApiErrorKind.protocol,
        message: '服务器返回空响应',
      );
    }

    final result = VDataExtractor.extract(html);
    switch (result.status) {
      case VDataStatus.missing:
        throw const ApiException(
          kind: ApiErrorKind.protocol,
          message: '个人信息响应缺少数据',
        );
      case VDataStatus.malformed:
        throw const ApiException(
          kind: ApiErrorKind.protocol,
          message: '个人信息数据格式异常',
        );
      case VDataStatus.ok:
        break;
    }
    final decoded = result.data!;

    final dto = PersonProfileDto.fromVData(decoded);
    if (dto.name.isEmpty && dto.idCard.isEmpty) {
      throw const ApiException(kind: ApiErrorKind.protocol, message: '个人信息为空');
    }
    return dto;
  }
}
