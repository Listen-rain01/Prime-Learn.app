/// 写操作证据级别（AGENTS.md §8.8）。
enum WriteLevel {
  /// 可复现证据 + 独立验证，可用于真实写操作。
  verified('已验证'),

  /// 真实环境观测，未独立验证；只允许受控查询与取证。
  observed('仅观测'),

  /// 只有推断，禁止用于写操作。
  assumed('未验证'),

  /// 已触发重验，暂停写操作。
  revalidating('重验中');

  const WriteLevel(this.label);

  /// 界面/错误信息用中文标签。
  final String label;
}
