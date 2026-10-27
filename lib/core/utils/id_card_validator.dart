/// 身份证号校验。
///
/// 登录页（即时反馈）与登录用例（领域校验）共用同一规则，避免两处正则漂移。
abstract final class IdCardValidator {
  static final RegExp _pattern = RegExp(r'^\d{17}[\dXx]$');

  /// 是否为合法的 18 位身份证号，末位可以是 `X`/`x`。
  static bool isValid(String value) => _pattern.hasMatch(value.trim());
}
