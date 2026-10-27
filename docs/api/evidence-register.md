# 协议证据登记表

> 本文件记录每个接口/行为的证据级别。级别规则见新项目 `AGENTS.md` §8.8。
> 升级只能由独立于实现者的评审确认；Agent 只能提议。

| 接口 | 行为 | 级别 | 验证日期 | 验证人 | 验证方式 | 样本路径 | 重验触发 |
|---|---|---|---|---|---|---|---|
| `/PersonWap/GetPersonInfo` | 登录成功解析 userId | observed | 2026-10-26 | 待指定 | 真实环境实测 | `docs/api/samples/login/` | 平台版本变更 |
| `/Home/GetValidateCode` | 建立会话 Cookie | observed | 2026-10-26 | 待指定 | 真实环境实测 | `docs/api/samples/validate-code/` | 平台版本变更 |
| `/Home/CreateTempExamOne` | 手机考试 type=2 创建 | observed | 2026-10-27 | 待指定 | 真实环境实测 | `docs/api/samples/create-mobile-exam/` | 平台版本变更 / 结算异常 |
| `/Home/CEndTimeOne` | 加密结算 | observed | 2026-10-27 | 待指定 | 真实环境实测（100 分） | `docs/api/samples/settle-encrypted/` | 平台版本变更 / 结算异常 |
| `/Home/CEndTimeMobil` | 模拟考试结算（空加密） | observed | 2026-10-26 | 待指定 | 真实环境实测 | `docs/api/samples/settle-mobil/` | 平台版本变更 |
| `/ArchiveManger/D_PersonAccumulate/CheckInOne` | 签到 | observed | 2026-10-26 | 待指定 | 真实环境实测 | `docs/api/samples/checkin/` | 平台版本变更 |
| `/ArchiveManger/D_PersonAccumulate/StudyKnowledgeOne` | 知识学习完成 | observed | 2026-10-26 | 待指定 | 真实环境实测 | `docs/api/samples/study-knowledge/` | 平台版本变更 |
| `/ExamManger/P_ExamDetail/GetMyExamListOne` | type=2 → 手机自测；type=3 → 手机模拟；type=0 → 理论考试 | observed | 2026-10-27 | 待指定 | 真实环境实测 | `docs/api/samples/my-exam-list/` | 平台版本变更 |
| `/AccumulateManger/S_Accumulate/GetPersonTodayAccumulateOne` | 今日任务 / 积分查询（只读） | observed | 2026-10-28 | 待独立复核 | 真实环境实测（登录→取 7 条任务，样本已脱敏） | `docs/api/samples/today-accumulate/` | 平台版本变更 / 任务上限调整 |
| 会话失效 | 识别登录页/错误文案/状态码 | assumed | — | — | 待补信号表 | — | 首次实现前必须验证 |

## 字段说明

- **级别**：`verified` / `observed` / `assumed`；
- **验证方式**：样本、实测、独立工具、推断；
- **样本路径**：请求、响应、`meta.json`（采集时间、采集人、平台版本）；
- **重验触发**：平台版本变更、连续 2 次结算异常、超过 90 天。

## 规则

1. `assumed` 不得用于创建考试、提交答案、结算、签到、加密；
2. `observed` 只能用于查询与取证；
3. 升级由独立评审确认并记录依据；
4. 超过 90 天未重验的 `observed` 自动降为 `assumed`。
