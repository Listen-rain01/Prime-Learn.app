/// 身份证号校验（GB 11643-1999，18 位）。
///
/// 登录页（即时反馈）与登录用例（领域校验）共用同一规则，避免两处正则漂移。
///
/// 号码结构：`6 位地址码 + 8 位出生日期 + 3 位顺序码 + 1 位校验码`。
///
/// 校验四件事：
/// 1. 长度与字符集：17 位数字 + 校验位（数字或 `X`/`x`）；
/// 2. 地址码省级前缀必须是**大陆 31 个省级行政区**之一
///    （拦截 00/99 这类手误，也拒绝港澳台与境外前缀）；
/// 3. 出生日期段必须是真实存在的日期，且不早于 1900 年、不晚于今天；
/// 4. 末位校验码符合 GB 11643 的加权模 11 规则。
///
/// 末位校验码按项目约定强制校验（平台账号均为标准身份证号），
/// 可拦截手误输错的号码，避免用错号去提交登录。
///
/// 不做的事（有意为之）：
/// - 只校验地址码的**省级前缀**（前 2 位），不校验完整 6 位行政区划：
///   完整码表有数千条且随区划调整变动，维护成本高于收益；
/// - 不校验顺序码的性别奇偶与 `000`：规范未禁止 `000`，且历史数据存在，
///   拒绝它会有误伤真实账号的风险。
abstract final class IdCardValidator {
  static final RegExp _pattern = RegExp(r'^\d{17}[\dXx]$');

  /// 大陆 31 个省级行政区划前缀（GB/T 2260）。
  ///
  /// 平台只接受大陆号码，因此**不含**港澳台（71/81/82/83）与境外（91）前缀。
  static const Set<String> _provincePrefixes = {
    '11', '12', '13', '14', '15', // 华北
    '21', '22', '23', // 东北
    '31', '32', '33', '34', '35', '36', '37', // 华东
    '41', '42', '43', '44', '45', '46', // 中南
    '50', '51', '52', '53', '54', // 西南
    '61', '62', '63', '64', '65', // 西北
  };

  /// 前 17 位的加权因子（GB 11643 表 1）。
  static const List<int> _weights = [
    7,
    9,
    10,
    5,
    8,
    4,
    2,
    1,
    6,
    3,
    7,
    9,
    10,
    5,
    8,
    4,
    2,
  ];

  /// 余数到校验码的映射（GB 11643 表 2）。
  static const List<String> _checkCodes = [
    '1',
    '0',
    'X',
    '9',
    '8',
    '7',
    '6',
    '5',
    '4',
    '3',
    '2',
  ];

  /// 是否为合法的 18 位身份证号，末位可以是 `X`/`x`。
  static bool isValid(String value) {
    final normalized = value.trim().toUpperCase();
    if (!_pattern.hasMatch(normalized)) return false;
    if (!_provincePrefixes.contains(normalized.substring(0, 2))) return false;
    if (!_isValidBirthDate(normalized.substring(6, 14))) return false;
    return _checkCodeOf(normalized.substring(0, 17)) == normalized[17];
  }

  /// 计算前 17 位对应的校验位。
  static String _checkCodeOf(String first17) {
    var sum = 0;
    for (var index = 0; index < 17; index++) {
      sum += int.parse(first17[index]) * _weights[index];
    }
    return _checkCodes[sum % 11];
  }

  /// 校验 `yyyyMMdd` 形式的出生日期段。
  static bool _isValidBirthDate(String segment) {
    final year = int.tryParse(segment.substring(0, 4));
    final month = int.tryParse(segment.substring(4, 6));
    final day = int.tryParse(segment.substring(6, 8));
    if (year == null || month == null || day == null) return false;
    if (year < 1900) return false;
    if (month < 1 || month > 12) return false;
    if (day < 1 || day > 31) return false;
    // DateTime 会把 2 月 30 日滚动到 3 月，用回读比对识别非法日期。
    final date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      return false;
    }
    return !date.isAfter(DateTime.now());
  }
}
