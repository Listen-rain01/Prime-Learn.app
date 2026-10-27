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
| `/ArchiveManger/D_PersonAccumulate/CheckInOne` | 签到（写） | verified | 2026-10-28 | 账号持有人授权 + 实现者实测 | 2026-10-27 记录成功路径（0→2/3、重复调用「已签到」不重复计分）；2026-10-28 实测未满足前置条件返回 `success=false`「练习50题后才能签到!」；同日平台规则变更：练习不累计、手机/模拟考试按题数累计（账号持有人告知） | `docs/api/samples/checkin/` | 平台版本变更 / 前置规则变更 |
| `/ArchiveManger/D_PersonAccumulate/StudyKnowledgeOne` | 知识学习完成 | observed | 2026-10-26 | 待指定 | 真实环境实测 | `docs/api/samples/study-knowledge/` | 平台版本变更 |
| `/ExamManger/P_ExamDetail/GetMyExamListOne` | type=2 → 手机自测；type=3 → 手机模拟；type=0 → 理论考试 | observed | 2026-10-27 | 待指定 | 真实环境实测 | `docs/api/samples/my-exam-list/` | 平台版本变更 |
| `/AccumulateManger/S_Accumulate/GetPersonTodayAccumulateOne` | 今日任务 / 积分查询（只读） | observed | 2026-10-28 | 待独立复核 | 真实环境实测（登录→取 7 条任务，样本已脱敏） | `docs/api/samples/today-accumulate/` | 平台版本变更 / 任务上限调整 |
| `/ArchiveManger/D_PersonAccumulate/GetMyAccumulateListOne` | 积分明细（只读） | observed | 2026-10-28 | 待独立复核 | 真实环境实测（记录页展示，未落盘样本） | `docs/api/samples/points-ledger/` | 平台版本变更 |
| `/PersonWap/MyRule` | 积分规则页（HTML，只读；当前客户端未使用） | observed | 2026-10-28 | 待独立复核 | 真实环境实测（3033 字符 HTML → 588 字符文本） | `docs/api/samples/my-rule/` | 平台版本变更 |
| `/PersonWap/MyBaseInfo` | 个人信息基础资料（HTML 内嵌 vData，只读） | observed | 2026-10-28 | 待独立复核 | 按接口手册实施 + 真实会话验证（15 个 vData 键，样本已脱敏） | `docs/api/samples/person-base-info/` | 平台版本变更 |
| `/ArchiveManger/D_PersonManager/GetPersonPhoto` | 头像图片（`did`/`pid` 均 Esdt，只读） | observed | 2026-10-28 | 待独立复核 | 真实会话实测（JPEG 28.5KB，需会话 Cookie） | 二进制样本不入库 | 平台版本变更 |
| `/PersonWap/SelectExamType` | 题库单位列表（HTML 内嵌 vData.Units，只读） | observed | 2026-10-28 | 待独立复核 | 真实会话实测：3 个单位（股份/澄合矿业/西卓煤矿），格式 `id,路径,名称,编码`，`^` 分隔 | 未落盘样本 | 平台版本变更 |
| `/ExamManger/P_ExamTypeStyle/GetAllTypeEx` | 题库大类（只读） | observed | 2026-10-28 | 待独立复核 | 真实会话实测：返回 14 条分类 | 未落盘样本 | 平台版本变更 |
| `/ExamManger/P_ExamTypeStyle/GetAllChildTypeEx` | 题库子分类/年份（只读） | observed | 2026-10-28 | 待独立复核 | 真实会话实测：返回 2022 年层级（Level=3） | 未落盘样本 | 平台版本变更 |
| `/ExamManger/P_ExamType/GetExamTypeListExOne` | 题库列表（只读） | observed | 2026-10-28 | 待独立复核 | 真实会话实测：单位=1、2022 年返回「刑法修正案十一」20 题；`Year`/`Style` 明文，其余 Esdt | 未落盘样本 | 平台版本变更 |
| `/ArchiveManger/D_PersonManager/SaveExamTypeIdsOne` | 保存/切换题库（写） | observed | 2026-10-28 | 待独立复核 | 文档有真实环境记录，本客户端尚未实测；写网关按 `observed` 拦截 | 未落盘样本 | 完成真实切换验证后升级 |
| `/ExamManger/P_ExamDetail/GetMarkRankingList` | 成绩排名（单位/集团榜，只读） | observed | 2026-10-28 | 待独立复核 | 前端页面 POST `/PersonWap/ScoreList` 代码核对：标题「考试成绩排行榜」、渲染 `考试成绩 Mark`；`type=1/0` 为范围、`id=0/1` 为单位/集团；此前固定 `id=0` 导致的 4152 异常值已定位为参数错误 | 未落盘样本 | 平台版本变更 |
| `/ArchiveManger/D_PersonStudyLog/GetStudyTimeRankingListOne` | 学习时长排名（只读） | observed | 2026-10-28 | 待独立复核 | 真实环境实测 + 前端代码核对：`Mark` 为 null，时长在 `AllCount`（秒），页面渲染 `formatSeconds(AllCount)`；区间为本周 | 未落盘样本 | 平台版本变更 |
| `/ExamManger/P_ExamDetail/GetPersonExamAchievementListOne` | 个人成绩趋势（只读） | observed | 2026-10-28 | 待独立复核 | 真实环境实测（记录页排行，返回多期成绩与日期） | 未落盘样本 | 平台版本变更 |
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
