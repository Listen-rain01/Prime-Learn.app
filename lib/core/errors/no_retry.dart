/// 禁止 Riverpod 对失败 provider 做自动重试。
///
/// Riverpod 3 默认会对失败的 provider 指数退避重试，界面上会长时间停留在
/// loading（错误被吞掉）。按 AGENTS.md §8.6，查询失败应直接呈现给用户，
/// 由用户点击「重试」触发，写操作更不能自动重试。
Duration? noProviderRetry(int retryCount, Object error) => null;
