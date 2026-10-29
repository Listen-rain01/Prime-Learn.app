# 协议证据登记表

> 本文件记录每个接口/行为的证据级别。级别规则见新项目 `AGENTS.md` §8.8。
> 升级只能由独立于实现者的评审确认；Agent 只能提议。

| 接口 | 行为 | 级别 | 验证日期 | 验证人 | 验证方式 | 样本路径 | 重验触发 |
|---|---|---|---|---|---|---|---|
| `/PersonWap/GetPersonInfo` | 登录成功解析 userId | observed | 2026-10-26 | 待指定 | 真实环境实测 | `docs/api/samples/login/` | 平台版本变更 |
| `/Home/GetValidateCode` | 建立会话 Cookie | observed | 2026-10-26 | 待指定 | 真实环境实测 | `docs/api/samples/validate-code/` | 平台版本变更 |
| `/Home/CreateTempExamOne` | 手机考试 type=2 创建 | verified | 2026-10-28 | 账号持有人授权 + 实测 | 2026-10-28 真机跑通手机考试全链路（创建→进入→取题→提交→`CEndTimeOne` 加密结算，100 分）；此前 2026-10-27 记为 `observed`，真机复现后与第 14 行同批升级。**按行为登记**：`type=1` 与 `type=2` 分属两种行为，代码用「端点#行为」区分，不能只按路径判级 | 未单独落盘 | 平台版本变更 / type 口径变更 |
| `/Home/CreateTempExamOne` | 模拟考试 type=1 创建 | verified | 2026-10-28 | 账号持有人授权 + 实测 | 文档 2026-10-27 两场 100 分；2026-10-28 客户端真实跑通（创建→进入→取题→提交→结算，100 分合格） | 未单独落盘 | 平台版本变更 / type 口径变更 |
| `/P_ExamDetail/SetOnlineTestOne` | 进入考试（style=1 模拟 / style=0 手机） | verified | 2026-10-28 | 账号持有人授权 + 实测 | 2026-10-28 两种 style 均真机跑通；按行为登记 `mock` / `mobile` | 未单独落盘 | 平台版本变更 |
| `/Home/DoWriteAnswerAll` | 提交答案（模拟 / 手机） | verified | 2026-10-28 | 账号持有人授权 + 实测 | 2026-10-28 两种考试均真实提交成功；响应为非标准 JSON（键未加引号），解析需按顶层 `success` 键判定，不能用无词边界的子串匹配 | 未单独落盘 | 平台版本变更 / 拼接规则变更 |
| `/Home/CEndTimeOne` | 手机考试加密结算（AES-128-ECB + RSA PKCS#1 v1.5） | verified | 2026-10-28 | 账号持有人授权 + 实测 | 文档 2026-10-27 手机考试真实结算 100 分；2026-10-28 账号持有人授权真机跑通手机考试全链路（含加密参数） | 未单独落盘 | 平台版本变更 / 加密口径变更 |
| `/Home/CEndTimeMobil` | 模拟考试结算（空加密） | verified | 2026-10-28 | 账号持有人授权 + 实测 | 文档 2026-10-27 两场真实结算；2026-10-28 客户端真实结算返回「100 分合格」 | `docs/api/samples/settle-mobil/` | 平台版本变更 |
| `/ArchiveManger/D_PersonAccumulate/CheckInOne` | 签到（写） | verified | 2026-10-28 | 账号持有人授权 + 实现者实测 | 2026-10-27 记录成功路径（0→2/3、重复调用「已签到」不重复计分）；2026-10-28 实测未满足前置条件返回 `success=false`「练习50题后才能签到!」；同日平台规则变更：练习不累计、手机/模拟考试按题数累计（账号持有人告知） | `docs/api/samples/checkin/` | 平台版本变更 / 前置规则变更 |
| `/ArchiveManger/D_PersonAccumulate/StudyKnowledgeOne` | 知识学习完成 | verified | 2026-10-28 | 账号持有人授权 + 实现者实测 | 2026-10-27 真实环境完成阅读 0→1；2026-10-28 账号持有人授权真实调用复核，按 §8.8 升级；平台按日封顶、重复调用幂等 | `docs/api/samples/study-knowledge/` | 平台版本变更 / 计分规则变更 |
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
| `/ArchiveManger/D_PersonManager/SaveExamTypeIdsOne` | 保存/切换题库（写） | verified | 2026-10-29 | 账号持有人授权 + 实测 | 2026-10-27 文档记录切换成功并以 FirstIndexOne 校验；2026-10-29 账号持有人要求执行前自动切库，真机验证通过 | 未落盘样本 | 平台版本变更 |
| `/ExamManger/P_Paper/SelectCanRunListOne` | 可考试卷（只读） | observed | 2026-10-28 | 待独立复核 | 真实环境实测：当前题库 1 份试卷（总分 100 / 及格 80）；预设「刑法修正案十一」0 份，无法用于考试 | 未落盘样本 | 平台版本变更 |
| `/ExamManger/P_ExamDetail/GetMarkRankingList` | 成绩排名（单位/集团榜，只读） | observed | 2026-10-28 | 待独立复核 | 前端页面 POST `/PersonWap/ScoreList` 代码核对：标题「考试成绩排行榜」、渲染 `考试成绩 Mark`；`type=1/0` 为范围、`id=0/1` 为单位/集团；此前固定 `id=0` 导致的 4152 异常值已定位为参数错误 | 未落盘样本 | 平台版本变更 |
| `/ArchiveManger/D_PersonStudyLog/GetStudyTimeRankingListOne` | 学习时长排名（只读） | observed | 2026-10-28 | 待独立复核 | 真实环境实测 + 前端代码核对：`Mark` 为 null，时长在 `AllCount`（秒），页面渲染 `formatSeconds(AllCount)`；区间为本周 | 未落盘样本 | 平台版本变更 |
| `/ExamManger/P_ExamDetail/GetPersonExamAchievementListOne` | 个人成绩趋势（只读） | observed | 2026-10-28 | 待独立复核 | 真实环境实测（记录页排行，返回多期成绩与日期） | 未落盘样本 | 平台版本变更 |
| `/ArchiveManger/D_PersonAccumulate/GetAccumulateRankingListOne` | 个人积分排行（单位/集团榜，只读） | verified | 2026-10-29 | 账号持有人授权 + 实测 | 账号持有人授权登录，真机调用返回 10 条榜单 + `message` 管道「姓名\|排名\|积分」。`Mark` 恒为 null，积分在 `AllCount`；`type=1` 单位 / `0` 集团；`begin`/`end` 走 Esdt，`type` 不走；周=周一~周日、月=月初~月末 | `docs/api/samples/accumulate-ranking/` | 平台版本变更 / 计分口径变更 |
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
5. **同一端点承载多种写入行为时，必须按行为逐条登记**（例如
   `CreateTempExamOne` 的 `type=1` / `type=2`、`SetOnlineTestOne` 的
   `style=1` / `style=0`）。只登记端点会让「一种行为验证过」连带放行
   「另一种未验证的行为」；代码侧由 `WriteEvidence` 的 `端点#行为` 键实现，
   行为不匹配时按 `assumed` 处理，不回落到端点级。

## 变更记录

| 日期 | 变更 | 依据 |
|---|---|---|
| 2026-10-29 | 手机考试创建（`type=2`）由 `observed` 升级为 `verified`；`CreateTempExamOne` / `SetOnlineTestOne` / `DoWriteAnswerAll` 改为按行为登记 | 2026-10-28 真机跑通手机考试全链路（含加密结算 100 分）；此前登记为 `observed` 与同批实测结论不一致 |
| 2026-10-29 | 明确「规则文案与接口字段不一致」时以字段为准 | `docs/api/samples/today-accumulate/`：手机考试 `MaxAccumulate=16`、`Accumulate=6`，模拟考试 `MaxAccumulate=8` |

