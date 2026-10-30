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
| `/ExamManger/P_Paper/SelectCanRunListOne` | 可考试卷（只读） | observed | 2026-10-28 | 待独立复核 | 真实环境实测：当前题库 1 份试卷（总分 100 / 及格 80）；预设「刑法修正案十一」0 份，无法用于考试。**不返回题数** | 未落盘样本 | 平台版本变更 |
| `/ExamManger/P_PaperScore/GetChildList` | 试卷出题数配置（只读） | observed | 2026-10-30 | 账号持有人授权 + 实测 | 参数为 `sjid`（试卷 ID，明文）+ `findName`；**传 `PaperId` 会返回空对象**。响应为非标准 JSON（键未加引号）。`出题数` 按「题型 + 考查分类」逐条配置，本卷题数 = 各条 `出题数` 之和。实测 4 份试卷合计均为 100 题；同一 3985 题题库的两份试卷题型分配不同（50/10/40 vs 40/10/50），证明题数按试卷人工配置、与题库大小无关 | `docs/api/samples/paper-score-config/` | 平台版本变更 / 配置口径变更 |
| `/ExamManger/P_ExamDetail/GetMarkRankingList` | 成绩排名（单位/集团榜，只读） | observed | 2026-10-28 | 待独立复核 | 前端页面 POST `/PersonWap/ScoreList` 代码核对：标题「考试成绩排行榜」、渲染 `考试成绩 Mark`；`type=1/0` 为范围、`id=0/1` 为单位/集团；此前固定 `id=0` 导致的 4152 异常值已定位为参数错误 | 未落盘样本 | 平台版本变更 |
| `/ArchiveManger/D_PersonStudyLog/GetStudyTimeRankingListOne` | 学习时长排名（只读） | observed | 2026-10-28 | 待独立复核 | 真实环境实测 + 前端代码核对：`Mark` 为 null，时长在 `AllCount`（秒），页面渲染 `formatSeconds(AllCount)`；区间为本周 | 未落盘样本 | 平台版本变更 |
| `/ExamManger/P_ExamDetail/GetPersonExamAchievementListOne` | 个人成绩趋势（只读） | observed | 2026-10-28 | 待独立复核 | 真实环境实测（记录页排行，返回多期成绩与日期） | 未落盘样本 | 平台版本变更 |
| `/ArchiveManger/D_PersonAccumulate/GetAccumulateRankingListOne` | 个人积分排行（单位/集团榜，只读） | verified | 2026-10-29 | 账号持有人授权 + 实测 | 账号持有人授权登录，真机调用返回 10 条榜单 + `message` 管道「姓名\|排名\|积分」。`Mark` 恒为 null，积分在 `AllCount`；`type=1` 单位 / `0` 集团；`begin`/`end` 走 Esdt，`type` 不走；周=周一~周日、月=月初~月末 | `docs/api/samples/accumulate-ranking/` | 平台版本变更 / 计分口径变更 |
| `/P_ExamDetail/SetOnlineStuday` | 进入手机练习（写，练习与考试共用练习链路） | observed | 2026-10-29 | 待独立复核 | 账号持有人授权实测：`XXExam("MobileExercises")` 直达练习页（参数全 Esdt，`style='0'`）；详见《手机练习接口文档》 | 未落盘样本 | 平台版本变更 |
| `/P_ExamDetail/OnlineStuday` | 练习页题目数据（HTML 内嵌 allShiTi，只读） | observed | 2026-10-29 | 待独立复核 | 账号持有人授权实测：整卷 3985 题预载、翻题无请求；单条 22 字段与考试 `AllQuestionArray` 同构，`f[13]` 正确答案（显示序）、`f[18]` 服务端答案编码、`f[15]`/`f[16]` 题干/选项（URL 编码） | 未落盘样本 | 平台版本变更 / 数据结构变更 |
| `/ArchiveManger/D_PersonStuday/SetQuestionOne` | 练习单题提交（写） | observed | 2026-10-29 | 待独立复核 | 账号持有人授权实测两题（对/错各一）：答错提交显示字母 → `data:"0"`；按 `f[13]` 答对提交 `f[18]` → `data:"1"`。参数除 Esdt 外明文；`pparms` 含两任务规则与当前题号。v1 范围外，仅取证 | 未落盘样本 | 平台版本变更 / 计分规则变更 |
| `/PersonWap/SyncPersonStat` | 退出练习同步统计（写） | observed | 2026-10-29 | 待独立复核 | 账号持有人授权实测：`CloseStuday()` 触发，`pid` Esdt，`success=true` | 未落盘样本 | 平台版本变更 |
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
| 2026-10-29 | 新增手机练习链路 4 条登记（`SetOnlineStuday` / `OnlineStuday` 页 / `SetQuestionOne` / `SyncPersonStat`），均为 `observed`，配套《手机练习接口文档》v1.0 | 2026-10-29 账号持有人授权 Playwright 真实环境实测（对/错两题双向验证提交语义）；v1 范围外仅取证，升级 `verified` 待独立复核 |
| 2026-10-30 | 新增 `P_PaperScore/GetChildList`（试卷出题数配置）登记为 `observed`；补充 `SelectCanRunListOne` 不返回题数的说明 | 账号持有人授权实测 4 份试卷：题数 = 各条 `出题数` 之和；同题库两份试卷题型分配不同，证明按试卷人工配置、与题库大小无关。样本 `docs/api/samples/paper-score-config/` |

