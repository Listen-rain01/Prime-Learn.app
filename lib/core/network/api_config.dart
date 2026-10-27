/// 接口地址配置。
///
/// 基础地址由部署环境决定，禁止硬编码到业务代码；通过
/// `--dart-define=API_BASE_URL=http://host:port` 注入。
abstract final class ApiConfig {
  /// 基础地址，默认值为文档中的内网示例地址。
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://61.150.84.25:100',
  );
}
