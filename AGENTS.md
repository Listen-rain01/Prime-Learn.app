# Prime Learn Agent · AGENTS.md

> 本文件是 Prime Learn Agent 新项目的唯一工程规则。
> 适用基线：Flutter 3.47.x / Dart 3.13.x / Riverpod 3.x / go_router 18.x。
>
> 项目形态：**纯接口客户端 + 智能代理**。
> 不包含 WebView，不做 DOM 自动化；平台协议以 `docs/api/` 为唯一事实来源。
>
> **范围（v1）**：登录、今日任务/积分、手机考试、模拟考试、签到、阅读学习、成绩、学习统计、题库/阅读偏好。
> **不做**：手机练习（业务上不需要；平台侧积分延迟/不稳定）、视频学习、练习时长、任何 WebView 自动化。

---

## 0. 规则优先级

1. 系统指令、开发者指令、用户明确指令 > 本文件。
2. 冲突按领域判定，不用单一序列：
   - 框架/语言 API：以对应版本的官方文档为准；
   - 项目架构、隐私、安全红线：以本文件为准，除非有更高优先级指令；
   - 平台协议：以 `docs/api/evidence-register.md` 中经过登记的实测/复核证据为准；
   - 示例代码：不得覆盖任何明确规则。
3. 平台协议与 `docs/api/` 冲突时，以实测记录为准，并立即回写文档。
4. 不允许用“页面能点通”替代接口验证；本项目没有页面自动化。
5. 任何“猜测协议”的代码都视为缺陷。

---

## 1. 会话启动规则

开始任务前：

1. **读文档**：按任务读 `docs/api/` 对应接口文档，不凭记忆写参数。
2. **技能**：
   - **只使用 Flutter 官方技能**（vendored 在 `.agents/skills/`，25 个）；
   - 不引入、不复制第三方技能；新仓库初始化时只复制官方技能目录；
   - 技能内容与本文件冲突时，以本文件为准。
3. **MCP**：若工具暴露 Dart/Flutter MCP（如 `mcp__dart__*`），分析/测试/运行优先走 MCP；否则回退 CLI。
4. **回答开头**：一句话说明参考了哪些文档/技能；没有如实说明。
5. 用户要求跳过某步时，以用户指令为准。

---

## 2. 依赖

### 2.1 运行时依赖

```text
flutter_riverpod
riverpod_annotation
go_router
dio
cookie_jar
dio_cookie_manager
freezed_annotation
json_annotation
shared_preferences          # 非敏感偏好
flutter_secure_storage      # 账号标识等敏感信息
pointycastle                # AES-128-ECB + RSA PKCS#1 v1.5（考试结算）
```

### 2.2 开发依赖

```text
build_runner
riverpod_generator
go_router_builder
json_serializable
freezed
riverpod_lint
mocktail
```

### 2.3 安装方式

- 一律 `flutter pub add` / `flutter pub add dev:<pkg>`；
- 不手写、不猜测版本号；`pubspec.lock` 必须提交；
- `riverpod_lint` 必须在 `analysis_options.yaml` 顶层 `plugins` 启用。

### 2.4 禁止

- 禁止 `flutter_inappwebview`、`webview_flutter`、任何 WebView；
- 禁止用 `shared_preferences` 存密码、Cookie、令牌；
- 禁止自实现 AES/RSA 等密码学原语；
- 禁止引入来源不明的依赖。

---

## 3. 架构与目录（Feature-First）

### 3.1 一句话原则

```text
先按“功能”分目录，再在功能内部按“层”分。
页面只管显示，用例只管流程，Repository 只管数据。
```

不要建全局的 `models/`、`services/`、`widgets/`；所有业务代码都归属于某个 feature。

例外（仅限无业务语义的视觉基元）：跨 feature 复用的通用 Widget 统一放 `core/widgets/`，不建 `lib/widgets/`；
只给单个页面用的组件仍放 `features/<feature>/presentation/widgets/`。
判断标准：**能不能不 import 任何 `features/` 就编译通过**。共享 Widget 里出现 provider、实体或接口调用，说明放错了，应回到对应 feature。

### 3.2 顶层只有三块

```text
lib/
├── app/          # 装配：MaterialApp、路由、主题
├── core/         # 基础设施：网络、协议、会话、证据、日志
├── features/     # 业务功能，一个功能一个目录
└── main.dart
```

`core/` 放什么：

| 目录 | 职责 | 例子 |
|---|---|---|
| `core/network` | Dio、Cookie、超时、错误映射 | `ApiClient`、`ApiException` |
| `core/protocol` | 平台协议编解码 | `EsdtCodec`、`SettleCrypto`、`PipeResponse` |
| `core/session` | 登录态、会话失效、账号记忆 | `SessionStore`、`AccountMemory` |
| `core/errors` | 跨层错误分类 | `UseCaseFailure` |
| `core/evidence` | 写入许可证：按证据级别拦截真实写操作（§8.8.1） | `WriteGateway`、`WriteLevel`、`WriteEvidence`、`WriteBlocked` |
| `core/logging` | 执行记录、诊断日志 | `RunLogStore` |
| `core/utils` | 纯工具 | `Redactor`、`IdCardValidator`、时间格式化 |
| `core/widgets` | 跨 feature 的通用视觉基元（不含业务语义） | `InlineNotice`、`TonalBlock`、`StatusLabel` |

规则：`core/` 不允许 import 任何 `features/`；`features/` 可以 import `core/`。

### 3.3 一个 feature 长什么样

以考试为例，完整结构如下：

```text
features/exam/
├── data/
│   ├── models/          # 接口返回长什么样（DTO）
│   │   ├── exam_paper_dto.dart
│   │   └── question_dto.dart
│   ├── services/        # 怎么调接口（一个 service 对应一组端点）
│   │   └── exam_api.dart
│   ├── parsers/         # 特殊响应解析（vData、竖线、HTML 片段）
│   │   └── exam_page_parser.dart
│   └── repositories/    # 把 DTO 变成 Entity
│       └── exam_repository_impl.dart
├── domain/
│   ├── entities/        # 业务对象，纯 Dart
│   │   ├── exam_paper.dart
│   │   ├── exam_result.dart
│   │   └── exam_question.dart
│   └── repositories/    # 接口：我需要什么数据
│       └── exam_repository.dart
├── application/
│   └── run_mobile_exam.dart   # 用例：创建→进入→取题→提交→结算
└── presentation/
    ├── providers/       # 页面状态（Riverpod）
    │   └── exam_run_provider.dart
    ├── pages/           # 页面
    │   └── exam_page.dart
    └── widgets/         # 页面内组件
        └── question_progress.dart
```

每层一句话：

| 目录 | 一句话 | 典型内容 |
|---|---|---|
| `data/models` | 接口返回的结构 | `ExamPaperDto`、`QuestionDto` |
| `data/services` | 怎么调接口 | `ExamApi.createExam()`、`ExamApi.submit()` |
| `data/parsers` | 特殊响应的解析 | `vData`、`AllQuestionArray`、`\|` 分隔文本 |
| `data/repositories` | DTO → Entity | `ExamRepositoryImpl` |
| `domain/entities` | 业务对象 | `ExamResult(score, passed)` |
| `domain/repositories` | 数据接口（抽象）| `Future<ExamResult> run(...)` |
| `application` | 多步流程编排 | `RunMobileExam.execute()` |
| `presentation/providers` | 页面状态 | `ExamRunNotifier` |
| `presentation/pages` | 页面 | `ExamPage` |
| `presentation/widgets` | 页面内组件 | `QuestionProgress` |

哪些层可以没有：

- 简单查询（如签到）：可以只有 `data + presentation`；
- 有业务对象：加 `domain/entities`；
- 有多个步骤/多个 Repository：加 `application/`；
- 考试、Agent：**必须有 application/**。

### 3.4 一次考试，谁调谁

用户点“开始考试”后：

```text
ExamPage
  └─ ref.read(examRunProvider.notifier).start()
       └─ ExamRunNotifier.start()
            └─ RunMobileExam.execute()
                 └─ ExamRepository（抽象）
                      └─ ExamRepositoryImpl
                           ├─ ExamApi.createExam()
                           ├─ ExamApi.enter()
                           ├─ ExamApi.fetchPage()
                           ├─ ExamPageParser.parse()
                           ├─ ExamApi.submit()
                           └─ ExamApi.settle()
```

每层拿到的数据：

```text
Page        → Widget
Notifier    → ExamRunState（idle/running/success/failed）
UseCase     → ExamResult（Entity）
Repository  → ExamResult（Entity）
Api         → DTO / String
Parser      → DTO
```

### 3.5 依赖规则（以及为什么）

```text
presentation ──▶ application ──▶ domain
      │                │            ▲
      │                │            │ implements
      └──────────────▶ core         data
```

| 规则 | 原因 |
|---|---|
| 页面不 import `data` | 换接口/换解析方式不用改页面 |
| 用例不 import `data` | 用例可单测，可替换 Repository 实现 |
| `domain` 不 import Flutter/Dio/JSON | 业务规则与框架解耦 |
| `data` 实现 `domain` 的接口 | 依赖倒置，高层不依赖低层细节 |
| feature 之间不互相 import `data` | 避免功能耦合；协作走用例或 `core/` |
| `core` 不 import `features` | 基础设施不能反向依赖业务 |

坏例子（页面直接调接口）：

```dart
// ❌ Widget 里直接发请求
final dio = Dio();
await dio.post('/Home/CreateTempExamOne', data: {...});
```

好例子：

```dart
// ✅ 页面只触发状态
ref.read(examRunProvider.notifier).start();
```

坏例子（用例绕过接口）：

```dart
// ❌ 用例直接 new API
class RunMobileExam {
  final api = ExamApi(Dio());
}
```

好例子：

```dart
// ✅ 用例依赖抽象
class RunMobileExam {
  RunMobileExam(this._repository);
  final ExamRepository _repository;
}
```

### 3.6 新增一个功能，文件放哪

按顺序：

```text
1. domain/entities/        定义业务对象
2. data/models/            定义 DTO
3. data/parsers/           需要时解析特殊响应
4. domain/repositories/    定义接口
5. data/services/          写接口调用
6. data/repositories/      实现接口（DTO → Entity）
7. application/            有多步流程时写用例
8. presentation/providers/ 写 Notifier
9. presentation/pages/     写页面
10. presentation/widgets/  写组件
```

如果只有一步查询，可跳过 7；如果有实时状态/轮询，放在 Notifier 或 UseCase，不放在页面。

### 3.7 命名与目录规则

- feature 目录用业务名：`auth`、`tasks`、`stats`、`checkin`、`exam`、`reading`、`settings`、`agent`；
- 页面统一 `xxx_page.dart` / `XxxPage`，不要 `screens/`、`_screen.dart`；
- 用例 `xxx_usecase.dart` / `XxxUseCase`；
- Repository 接口 `xxx_repository.dart`，实现 `xxx_repository_impl.dart`；
- DTO 以 `_dto.dart` 结尾，Entity 不带后缀；
- 禁止全局 `models/`、`services/`、`widgets/`（跨 feature 的通用 Widget 放 `core/widgets/`）；
- 非页面组件放 `presentation/widgets/`，不要放 `pages/`。

---

## 4. 分层红线与检查

### 4.1 每层红线

| 层 | 必须 | 禁止 |
|---|---|---|
| `presentation` | 订阅状态、触发用例、展示错误 | 调 Dio、拼参数、写业务规则、碰 DTO |
| `application` | 编排步骤、重试/停止、返回 Entity | 依赖 Flutter、BuildContext、直接发 HTTP |
| `domain` | 纯 Dart 实体与接口 | import Flutter/Dio/JSON、写 UI 文案 |
| `data` | 调接口、解析、映射 | 依赖 UI、把 DTO 传到 UI、写页面状态 |
| `core` | 通用基础设施 | import features、承载业务规则 |

### 4.2 错误处理链路

```text
Dio / 协议错误
  → data：ApiException（endpoint、code、message）
  → application：UseCaseFailure（可重试/不可重试/会话失效）
  → presentation：UI 状态（文案 + 重试）
```

- 禁止把原始异常直接抛到 UI；
- 禁止吞异常返回空数据；
- 会话失效统一识别，不在每层重复判断。

### 4.3 DTO 边界

- DTO 只存在于 `data/`；
- Repository 负责 DTO → Entity；
- `AllQuestionArray`、`vData`、`|` 响应只在 `data/parsers` 解析；
- UI 与用例只使用 Entity。

### 4.4 测试分层

| 层 | 测什么 |
|---|---|
| `data/parsers` | 黄金响应：成功、空、错误文案 |
| `data/repositories` | DTO → Entity 映射、错误分支 |
| `application` | 用例流程、重试、停止、延迟入账 |
| `presentation` | Notifier 状态迁移、页面关键交互 |
| `core/protocol` | Esdt / AES / RSA 固定向量 |

### 4.5 代码注释

- 所有代码注释（`///` 与 `//`）使用中文；以下除外：生成文件、第三方代码、`// ignore:` / `// ignore_for_file:` 等分析器指令、必要的英文标识符或 URL。
- public 类、方法、属性用 `///` 写简短中文说明；`@override`、私有成员、生成代码、显而易见的 getter/setter 可豁免。
- 复杂业务逻辑上方用 `//` 说明“为什么”，不写“给变量赋值”这类复述代码的废话。
- 生成文件（`*.g.dart`、`*.freezed.dart`）不手改，其英文注释不受本节约束。

### 4.6 代码评审六问

1. 页面里有没有直接发请求？
2. 用例有没有 import `data`？
3. DTO 有没有漏到 UI？
4. 新功能有没有放进对应 feature？
5. 错误有没有被吞掉？
6. 这一步有没有测试覆盖？

---

## 5. 状态管理

- 业务状态一律 `@riverpod` 代码生成，禁止手写 `StateNotifier`；
- 框架/插件控制器才允许 `ChangeNotifier`；
- `keepAlive: true` 用于：会话、网络、Repository、AgentEngine；
- `ref.watch` 用于 build 依赖；`ref.read` 只用于事件回调。

### 5.1 代理状态机

```dart
sealed class AgentRunState {
  const AgentRunState();
}

class AgentIdle extends AgentRunState {
  const AgentIdle();
}

class AgentPlanning extends AgentRunState {
  const AgentPlanning();
}

class AgentReady extends AgentRunState {
  const AgentReady(this.plan);
  final AgentPlan plan;
}

class AgentRunning extends AgentRunState {
  const AgentRunning({
    required this.stepIndex,
    required this.title,
    required this.detail,
    this.answered,
    this.total,
  });
  final int stepIndex;
  final String title;
  final String detail;
  final int? answered;
  final int? total;
}

class AgentSuccess extends AgentRunState {
  const AgentSuccess(this.report);
  final AgentReport report;
}

class AgentPartial extends AgentRunState {
  const AgentPartial(this.report);
  final AgentReport report;
}

class AgentFailed extends AgentRunState {
  const AgentFailed(this.reason);
  final String reason;
}

class AgentCancelled extends AgentRunState {
  const AgentCancelled(this.reason);
  final String reason;
}

class AgentUnknown extends AgentRunState {
  const AgentUnknown(this.reason);
  final String reason;
}
```

### 5.2 AgentEngine 模板

```dart
class AgentCancelToken {
  bool isCancelled = false;
  void cancel() => isCancelled = true;
}

@Riverpod(keepAlive: true)
class AgentEngine extends _$AgentEngine {
  @override
  AgentRunState build() => const AgentIdle();

  bool _running = false;
  AgentCancelToken? _token;

  Future<void> prepare() async {
    if (_running) return;
    try {
      state = const AgentPlanning();
      final plan = await ref.read(planBuilderProvider).build();
      state = AgentReady(plan);
    } on Object catch (error) {
      state = AgentFailed('计划生成失败：$error');
    }
  }

  Future<void> run() async {
    if (_running) return;
    final plan = switch (state) {
      AgentReady(:final plan) => plan,
      _ => return,
    };

    _running = true;
    final token = AgentCancelToken();
    _token = token;
    try {
      for (var i = 0; i < plan.steps.length; i++) {
        if (token.isCancelled) {
          state = const AgentCancelled('用户停止');
          return;
        }
        final step = plan.steps[i];
        state = AgentRunning(stepIndex: i, title: step.title, detail: '开始');
        final result = await step.execute(token).timeout(step.timeout);
        if (!result.ok) {
          state = AgentFailed(result.reason);
          return;
        }
      }
      if (token.isCancelled) {
        state = const AgentCancelled('用户停止');
        return;
      }
      final report = await ref
          .read(reportBuilderProvider)
          .build()
          .timeout(const Duration(seconds: 5));
      state = report.hasSkips ? AgentPartial(report) : AgentSuccess(report);
    } on TimeoutException {
      state = const AgentUnknown('步骤超时：写操作结果未知，禁止后续写，先只读对账');
    } on Object catch (error) {
      state = AgentFailed('执行异常：$error');
    } finally {
      _running = false;
      _token = null;
    }
  }

  void cancel() => _token?.cancel();
}
```

约束：

- 同一时间只允许一个 `run()`；锁必须在引擎内部，不能只靠 UI 禁用按钮；
- 取消令牌必须传入步骤执行器并继续传到网络层（如 Dio `CancelToken`），不能只在循环边界检查；
- 每步必须有超时；超时、异常、取消都必须产生明确终态；
- **`Future.timeout` 不会取消底层请求**：超时后必须标记“写操作结果未知”，禁止后续写步骤，只能走 §8.9 只读对账；
- 用户停止 → `AgentCancelled`（不是 `AgentFailed`），取消后续步骤，不撤销已提交内容；
- 报告至少包含 `cancelled`、`completedSteps`、`pendingWrites`，区分“取消”与“部分完成”。

---

## 6. 路由

三个 Tab（`StatefulShellRoute.indexedStack` 承载，各自保留导航栈）：

```text
/login          登录（shell 之外）
/               首页（Tab 1）：今日积分、每日任务（按接口顺序）、任务入口
/stats          统计（Tab 2）：考试记录、积分明细、排行/成绩趋势（只读）
/settings       我的（Tab 3）：账号、当前题库、题库预设、退出登录
/settings/bank-preset 题库预设（「我的」分支内 push）
/settings/reading-preset 阅读预设（「我的」分支内 push）
/run            执行中（push，暂未实现）
/result         结果（push，暂未实现）
```

- 使用 `@TypedGoRoute` + `GoRouteData`，禁止字符串路由；shell 用 `@TypedStatefulShellRoute`；
- Tab 顺序：首页 / 统计 / 我的；新增 Tab 需先改本节与 `lib/app/app_shell.dart`；
- 执行中离开需二次确认；
- 深链只开放 `/` 与 `/stats`；
- 会话失效统一跳 `/login`，登录后回原页。

---

## 7. 数据模型与协议解析

### 7.1 JSON

- Freezed（`abstract`）+ json_serializable；
- 字段不统一用 `@JsonKey`；
- DTO 容错：数字/字符串统一转换，未知字段忽略。

### 7.2 竖线响应

登录、会话、结算等接口返回 `|` 分隔文本：

- 单独 parser，不在 UI 内 `split('|')`；
- 首段为空表示成功；
- 空响应必须判失败；
- 每个 parser 必须有成功/失败/空三种测试。

### 7.3 考试题目字段

`AllQuestionArray` 每条 22 字段（下标以接口文档为准）：

```text
0  答题记录 ID
1  题目 GUID
2  排序
3  标记
4  用户答案（提交前为空）
10 分值
13 正确答案（显示顺序）
14 题型（1 单选 / 2 多选 / 3 判断）
15 题干（URL 编码）
16 选项文本
21 来源说明
```

规则：

- 考试交卷：`[4] = [13]`；
- 禁止在业务代码散落魔法下标，统一常量或解析模型。

### 7.4 时间

- 接口 ISO 时间解析为 `DateTime`；
- 展示转本地时区；
- 存储统一 ISO 8601。

---

## 8. 平台协议（核心）

### 8.1 会话

```text
GET  /Home/GetValidateCode                建立 ASP.NET_SessionId
POST /PersonWap/GetPersonInfo             登录（Esdt 参数）
POST /PersonWap/FirstIndexOne             校验会话 + 当前题库
```

- 全流程复用同一 Cookie 容器；
- 会话失效：清本地态 → 登录页；
- 登录失败直接展示错误，不自动重试。

#### 8.1.1 身份证号校验（GB 11643）

登录前的本地校验，实现在 `lib/core/utils/id_card_validator.dart`，登录页与用例共用。

号码结构：`6 位地址码 + 8 位出生日期 + 3 位顺序码 + 1 位校验码`。

必校项（四项缺一不可）：

1. 长度与字符集：17 位数字 + 校验位（`0-9` 或 `X`/`x`，小写归一为大写）；
2. **地址码省级前缀**必须是**大陆 31 个省级行政区**之一；`00`、`99` 这类手误，
   以及港澳台（`71/81/82/83`）与境外（`91`）前缀一律拒绝——平台只接受大陆号码；
3. 出生日期段必须是真实存在的日期：拒绝 13 月、2 月 30 日、非闰年 2 月 29 日，
   早于 1900 年或晚于今天的也拒绝（1900-01-01 为允许的下边界）；
4. 末位校验码 = 前 17 位加权求和后对 11 取模，按 `[1,0,X,9,8,7,6,5,4,3,2]` 映射。

不校验项（有意为之，不得擅自加严）：

- 完整 6 位行政区划码表（数千条且随区划调整变动，只校省级前缀）；
- 顺序码的性别奇偶与 `000`（规范未禁止 `000`，且历史数据存在，
  拒绝会有误伤真实账号的风险）。

顺序码第 15–17 位奇数为男、偶数为女，仅用于**展示性别**，
不参与合法性判定。

### 8.2 Esdt

- 所有标注 Esdt 的参数必须走统一 `EsdtCodec`；
- 算法：逐码元十进制串拼接 + `^` + 长度列表，再做 ECMAScript `escape()`；
- 必须有黄金向量测试（参考 `docs/dev/esdt-vectors.mjs`）；
- 禁止在 service 内手写转义。

### 8.3 考试矩阵

| 类型 | CreateTempExamOne.type | SetOnlineTestOne.style | 结算 | 记录标签 | 查询过滤 |
|---|---|---|---|---|---|
| 手机考试 | `2` | `0` | `CEndTimeOne` + AES/RSA | `手机自测` | `GetMyExamListOne?type=2` |
| 模拟考试 | `1` | `1` | `CEndTimeMobil`（空加密）| `手机模拟` | `GetMyExamListOne?type=3` |

> 实测（2026-10-27）：`type=2` 创建的记录在成绩页/接口中显示为「手机自测」，`type=1` 显示为「手机模拟」；`type=0` 只返回「理论考试」。
> 因此**空列表可能只是过滤口径错了**：不能拿 `type=0` 的空结果判断手机考试未创建/未结算。

流程：

```text
GET  SelectCanRunListOne          试卷列表
POST ExistsNoFinish               未完成检查
POST CreateTempExamOne            创建考试 → ksmxid
POST SetOnlineTestOne             进入考试
GET  OnlineTestOne                取 vData / AllQuestionArray
POST DoWriteAnswerAll             提交答案
POST CEndTimeOne / CEndTimeMobil  结算
GET  GetMyExamListOne             查询记录（恢复/对账）
```

- 类型/样式写错会把积分记到错误任务，必须有单测；
- 答案拼接：每条取 0–14 字段，`[4]=[13]`，记录间 `|`；
- **结算加密是实现细节，不在主规范展开**：见 `docs/api/手机考试接口文档.md` §5.7；
- 加密方案当前证据级别为 `verified`（2026-10-28 真机跑通手机考试 100 分，见 `docs/api/evidence-register.md`）；结算实现见 `docs/api/手机考试接口文档.md` §5.7；
- 恢复/对账使用 `GetMyExamListOne` 查询记录状态，并带正确过滤：手机考试 `type=2`、模拟考试 `type=3`。


### 8.4 签到 / 阅读

```text
POST /ArchiveManger/D_PersonAccumulate/CheckInOne          { pid: Esdt }
GET  /LearnManger/L_KnowledgeType/GetAllTypeOne
GET  /LearnManger/L_KnowledgeType/GetAllChildTypeOne       { pid, did: Esdt }
GET  /LearnManger/L_KnowledgeSubject/GetStudyOne           { typeid, pid, page, rows }
GET  /ArchiveManger/D_PersonAccumulate/StudyKnowledgeOne   { pid, zsid: Esdt }
```

### 8.5 积分

- 今日任务：`GET /AccumulateManger/S_Accumulate/GetPersonTodayAccumulateOne?pid=Esdt`；
- 以 `CurAccumulate / MaxAccumulate` 为准；
- 规则文案可能滞后，以接口字段为准。实测（`docs/api/samples/today-accumulate/`，
  2026-10-28）：手机考试 `MaxAccumulate=16`、`Accumulate=6`，模拟考试
  `MaxAccumulate=8`；**“每日上限 8/16 不一致”指的是规则文案与字段不一致，
  不是字段本身不可用**，实现必须按字段判断是否需要再跑一场；
- 结算成功 ≠ 积分到账：每 10–15s 轮询一次，最多 90s（实现取 10s × 9 次）；
- “本场是否到账”与“是否还要再考一场”必须分开判断：轮询窗口内
  `CurAccumulate` 没上涨时，**停止而不是继续创建考试**（避免烧掉考试次数）；
  窗口取值不得小于 90s，否则会把延迟入账误判成“未产生积分”；
- 查询返回里找不到该任务时属于“状态未知”，不得当成“已完成”；
- 禁止把“请求成功”直接展示为“积分 +N”。

### 8.6 重试与幂等

- **查询**可重试 1 次，间隔 1–2 秒；仅限网络/超时类错误；
- **写操作**（创建考试/提交答案/结算/签到）不得自动重试；超时后先查询状态，再按 §8.9 决策；
- 会话失效错误不得当作普通网络错误重试；
- 同一任务运行中禁止并发；
- 每步超时 30–60s，整轮设置总预算；
- 用户停止：取消后续步骤，已提交内容不回滚，并提示。

### 8.7 安全边界

- 只访问 `API_BASE_URL` 同域；
- 不实现绕过验证码/风控的逻辑；
- 平台要求验证码/二次确认时，停下并交给用户；
- 不抓取、不存储他人数据。

### 8.8 协议证据分级与升级权限（P0）

| 级别 | 定义 | 允许用途 |
|---|---|---|
| `verified` | 可复现证据 + 独立测试 | 可用于真实写操作/加密实现 |
| `observed` | 真实环境观测，未独立验证 | 仅限受控查询与取证；可写代码/测试，但不得启用真实写操作 |
| `assumed` | 只有推断，证据不足 | **禁止**用于创建考试、提交答案、结算、签到、加密；只允许只读实验并显式标注 |
| `revalidating` | 已触发重验、尚未完成 | 暂停对应关键写操作，直到重验完成 |

规则：

1. **粒度**：`verified` 针对「具体接口 + 具体行为 + 具体前提」，不给整份文档打总标签；
   **同一端点承载多种写入行为时必须按行为分别登记**（如 `CreateTempExamOne` 的
   `type=1/2`、`SetOnlineTestOne` 的 `style=1/0`）。代码侧用 `端点#行为` 键实现，
   行为不匹配按 `assumed` 处理，不回落到端点级；
2. **登记**：`docs/api/evidence-register.md` 记录接口、行为、级别、验证日期、验证人、验证方式、样本路径、重验触发条件；
3. **升级权限**：人（开发者/负责人）可直接升级，但必须由独立于实现者的评审确认并在 `evidence-register.md` 记录依据；Agent 只能**提议**，不得自行提升；
4. **过期**：`observed` 超过 90 天未重验自动降为 `assumed`；`verified` 在平台版本变更或连续 2 次结算异常时触发重验；
5. **样本**：放 `docs/api/samples/<接口名>/`，含请求、响应、采集时间、采集人、平台版本；
6. **人工验收**：必须写明验收人角色、验收时点（PR / 发布前 / 运行后）、记录位置，否则视为“缺少验收标准”。

#### 8.8.1 开发许可 vs 运行许可

| 许可 | 内容 | 条件 |
|---|---|---|
| 开发许可 | 在隔离测试中编写、审查、测试未验证实现 | 功能开关关闭，不接触真实账号 |
| 运行许可 | 真实环境执行关键写操作 | 对应行为必须 `verified`，且未处于 `revalidating` |

- PR 中的“取证计划”只能支持开发许可，**不能授予运行许可**；
- 运行时必须检查证据级别，`observed`/`assumed`/`revalidating` 一律阻断写操作；
- 检查必须放在**统一写网关**（Repository 写方法/`WriteGateway`，实现见 `lib/core/evidence/`），而不是只在 UI 或 AgentEngine 启动时查一次；
- 每次写请求前重新解析证据状态（接口 + 行为 + 上下文 + 当前级别），拒绝时抛 `WriteBlocked`，**不得发出 HTTP**；
- 证据状态与 `revalidating` 必须持久化；应用重启后仍然阻断，直到独立评审完成；
- 只有独立评审完成升级后，才允许打开功能开关。

### 8.9 写操作状态判定与失败恢复（P0）

原则：

1. **空列表 ≠ 未提交**：只有“查询成功 + 同上下文 + 等待重查仍无记录 + 查询语义 verified”才可视为未提交；
2. 查询必须匹配上下文（同一用户、考试类型、试卷、时间窗口）；
3. 查询有延迟：首次为空时等待 2–5 秒重查，最多 2 次；仍为空才进入判定；
4. 积分变化不能单独作为某次写操作成功的证据；
5. 无法确认 → 停止自动写，保留诊断。

#### 8.9.1 分操作状态表

| 操作 | 权威查询 | 已完成 | 明确未完成 | 处理中 | 无法确认 |
|---|---|---|---|---|---|
| 创建考试 | `GetMyExamListOne?type=2`（手机）/`type=3`（模拟），同用户/同卷/近期；`ExistsNoFinish` 仅在语义 verified 后可用 | 同上下文记录存在 | 查询成功 + 重查后仍无记录（仅当查询语义覆盖可见性窗口）| 记录存在但状态中间 | 停止，禁止再次创建 |
| 提交答案 | 考试记录中的交卷/答案状态（需 verified）| 记录显示已交卷/已有答案 | 无可信接口前**不得判定**未提交 | 记录存在但未交卷 | 停止，禁止重提交 |
| 结算 | `GetMyExamListOne?type=2`/`type=3` 的分数/结束时间 | 分数或结束时间已产生 | — | 记录存在但无分数/无结束时间 | 停止；仅 `verified` 且支持续结算时才续结算 |
| 签到 | 可关联“本次签到”的 verified 状态；`CurAccumulate` 只能作辅助 | 已确认本次签到成功 | 明确显示本次未签到 | 结果未知 | 停止，不自动重试 |

> `CurAccumulate > 0` **不能**单独证明本次签到成功：它可能是历史累计或其他任务积分。无法关联到本次操作时，结果记为未知。

**查询语义 verified 的可审计条件**（缺一不可）：

1. 覆盖当前操作与用户上下文（同一用户、类型、试卷/任务）；
2. 已测量最大可见延迟，重查窗口覆盖该延迟；
3. 过滤条件、分页与排序完整，不会漏掉刚创建的记录；
4. 有真实样本与独立复核记录，登记在 `evidence-register.md`。

重查规则：首次查询 + 最多 2 次重查（总计 3 次），每次间隔 2–5 秒；窗口必须来自证据，否则停止。

#### 8.9.2 恢复决策

| 已完成动作 | 平台可确认状态 | 允许动作 | 禁止动作 |
|---|---|---|---|
| 创建请求发出，结果未知 | 同上下文重查仍无记录（查询语义 verified）| 重试创建 1 次 | 连续盲目重试 |
| 创建结果未知 | 无法确认 | 停止，保留诊断 | 再次创建 |
| 答案已提交，结算未知 | 记录存在且结算未完成，协议 verified 支持续结算 | 仅续结算 | 重新创建/重提交答案 |
| 答案已提交，结算未知 | 记录存在但无法确认结算能力 | 停止，标记“待取证” | 猜测续结算 |
| 结算返回失败 | 平台显示已完成 | 对账并记录 | 重提交/重结算 |
| 会话过期发生在写入中 | 状态未知 | 停止；重新登录后先查状态 | 自动重放写操作 |
| 任意状态未知 | 无法确认 | 停止自动写，保留记录 | “先试一下” |

硬规则：

- **不得仅因结算失败就自动重新创建考试或再次提交答案**；
- 不可逆后果（结算、隐私）优先级高于可逆后果（签到）；
- 状态未知时，停止自动写操作是默认动作，不是异常处理。

### 8.10 部分提交后的用户可见状态（P0）

| 状态 | 用户看到 | 允许操作 |
|---|---|---|
| `settling` | “答案已提交，正在确认结算…” + 进度 | 等待（自动轮询）|
| `pending_evidence` | “结算状态待确认，记录已保留” | 继续确认、导出诊断、结束并保留 |
| `unknown` | “无法确认平台状态，已停止自动操作” | 导出诊断、联系管理员；不提供“重试写入” |
| `completed` | 分数/积分结果 | 查看记录 |

- `settling` 超过 §8.5 的轮询上限（90s）仍未确认 → 转 `pending_evidence`，**不转 `unknown`**；
- `unknown` 只用于查询本身失败/无法判断（网络、解析、会话失效）；
- `pending_evidence` 继续确认成功后直接转 `completed`，不再回到 `settling`；
- 只有协议 `verified` 且操作幂等时，才允许“手动继续结算”按钮；
- “继续确认”是只读操作：间隔 5s → 15s → 30s，最多 3 次；不得触发写请求；
- 应用重启后从审计记录恢复 `pending_evidence`，允许再次只读确认；
- “结束并保留”后仍可重新打开只读确认，但不自动恢复执行；
- 未确认前不得把状态显示为失败，也不得显示“积分 +N”；
- 结束并保留 = 保留审计记录，不删除、不重写。

### 8.11 重复提交与会话过期（P0）

**重复提交**：

写操作（创建考试、提交答案、结算、签到）前，必须查询权威状态。

**每种写操作以 §8.9.1 的操作矩阵为唯一决策入口**；下列通用清单只做兜底，不能覆盖操作专属条件：

```text
1. 考试记录是否存在（GetMyExamListOne）
2. 该记录的状态/分数是否已产生
3. 任务积分是否已变化
4. 候选接口（如 ExistsNoFinish）仅在语义 verified 后才能作为依据
```

判定：

- 只有平台状态**明确证明未提交**，才允许写入；
- 查询失败、状态未知、接口未验证 → **禁止写入**；
- “请求成功”不等于“平台已接受”；
- 不假设平台存在幂等键；没有证据时禁止自动重试写操作。

**会话过期**：

- 不预设所有过期都表现为 HTTP 401；
- 信号必须登记在 `docs/api/`，并标注置信度：

| 信号 | 置信度 | 处理 |
|---|---|---|
| HTTP 401 | 高 | 判为会话失效 |
| HTTP 403 | 低/待证 | 默认按权限限制或状态未知处理；未验证不得清会话，也不得重放写操作 |
| 302 跳转登录页 | 高 | 判为会话失效 |
| 响应为登录页 HTML | 高 | 判为会话失效 |
| 业务错误文案（“请重新登录”等）| 中 | 结合上下文判断 |
| Cookie 缺失/失效 | 中 | 先验证再判断 |
| 普通业务错误 | 低 | 不得判为过期 |

- 低置信度时按“状态未知”处理：停止写操作，提示重新登录；
- 重新登录后必须先查平台状态，再决定是否继续；
- 不确定时不得自动重放写操作。

> 上表置信度是**项目规则**，不是平台事实。用于自动清除会话或触发写操作重放前，必须先在 `docs/api/samples/` 登记真实样本并完成独立确认；未登记前一律按“状态未知”处理。
> HTTP 403 可能是权限/风控限制，不能单独判为会话失效。

---

## 9. 隐私、日志与执行记录

### 9.1 三层记录

| 层 | 内容 | 存储 | 用户可见 |
|---|---|---|---|
| UI 进度 | 当前步骤、已答/总数、状态 | 内存 | 是（执行页）|
| 技术日志 | 时间、步骤、接口路径、状态码、耗时、错误、重试 | 滚动文件 | 仅“导出诊断” |
| 审计记录 | 每次运行的步骤结果、考试/阅读明细、分数、积分变化 | 本地持久化 | “执行记录”页 |

### 9.2 考试审计字段

```text
RunRecord
  runId, startedAt, finishedAt, mode(auto/manual), status, totalSteps

StepRecord
  stepId, type(exam/checkin/reading), title,
  startedAt, finishedAt, status, errorCode

ExamRecord
  examType(mobile/mock), paperId, paperName,
  score, passed, questionCount

QuestionRecord（数组）
  questionId, order, submittedAnswer, isCorrect
  correctAnswer?  // 可选，默认不持久化；仅调试开关开启时写入
```

QuestionRecord 默认持久化字段为 `questionId/order/submittedAnswer/isCorrect`；`correctAnswer` 是可选字段，历史记录缺失时必须能反序列化。

规则：

- **默认只存题目 ID + 提交答案 + 正确与否**；
- **不默认存题干、选项全文、用户身份信息**；
- 调试构建可开启“完整明细”（题干/选项），release 必须关闭；
- 单次考试 100 题约 20KB；保留最近 7 天或 20 次运行，总量上限 5MB，超出滚动删除最旧记录。

### 9.3 技术日志

- 只记录：步骤、接口路径（不含 query 中的敏感值）、HTTP 状态、耗时、错误码、重试次数；
- 不记录：请求体/响应体全文、Cookie、身份证、密码、`mxid2/mxid3`；
- `ksmxid` 如需关联，只保留前 8 位；
- release 默认 warn/error + 审计；debug 可开 verbose。

### 9.4 脱敏与导出

- 身份证展示脱敏（前 6 后 4）；
- 日志/崩溃上报/埋点同样脱敏；
- 导出诊断日志必须二次脱敏，且由用户主动触发；
- `docs/api/samples/` 中的协议样本同样脱敏：Cookie/会话值替换为占位符，身份证/姓名脱敏，不保存有效凭据；
- 账号标识只进 secure storage。

### 9.5 存储与实现

- `core/logging/` 提供 `RunLogStore` 接口 + 文件实现（JSON Lines）；
- 文件：`runs.jsonl`（审计）、`diag.log`（诊断，滚动）；
- v1 不引入数据库依赖；
- 写入失败不得影响主流程，但要在 debug 日志中提示。

### 9.6 测试

- 脱敏测试：身份证/密码/Cookie/加密串不出现在日志；
- 保留策略：超过 20 次或 5MB 删除最旧；
- 审计记录序列化/反序列化；
- 单次运行结束后审计记录完整（步骤、分数、积分变化）。

---

## 10. 开发工作流与质量门禁

每个需求：

1. 读 `docs/api/` 对应文档；
2. 写 DTO / parser + 黄金响应测试；
3. 写 service / repository；
4. 写 agent 步骤 / 状态机；
5. 写页面；
6. `dart run build_runner build --delete-conflicting-outputs`；
7. `dart format .`、`flutter analyze`、`flutter test`；
8. 协议有差异时更新 `docs/api/`，并登记证据级别与样本。

提交前必须通过：

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

- 不允许提交 analyze error；
- 新行为必须有测试；
- 生成文件不手改。

### 10.1 主规范 / docs/api / CI 分工

| 内容 | 放哪 |
|---|---|
| 证据分级定义与写操作红线 | 主规范 |
| 层间依赖、安全边界 | 主规范 |
| 重试、幂等、取消、失败恢复原则 | 主规范 |
| 审计记录最低要求 | 主规范 |
| 每个接口的字段语义、错误码、会话失效信号 | `docs/api/` |
| 证据登记（级别/日期/验证人/样本）| `docs/api/evidence-register.md` |
| 请求/响应样本 | `docs/api/samples/<接口名>/` |
| format / analyze / test / 向量 / parser / 状态机 / 可注入时钟 | CI |

- CI 能验证“代码符合已有测试”，不能证明“测试向量代表真实协议”；
- **测试通过 ≠ 协议已验证**，这是两个独立验收结论。

---

## 11. 测试策略

- HTTP 用 `mocktail` mock `Dio` 或注入 fake client；
- 每个 parser：成功、失败文案、空响应；
- Esdt / AES / RSA：固定向量测试；
- Agent 状态机：
  - 全部完成
  - 部分完成（有跳过）
  - 硬失败
  - 会话失效
  - 积分延迟入账
- 不允许真实网络测试进入 CI。

### 11.1 向量资产 vs 协议正确性

这是两个独立验收结论：

| 验收 | 回答的问题 | 归属 |
|---|---|---|
| 向量资产完整性 | 向量文件是否存在、有独立来源、有预期结果、测试真的消费了它 | 仓库/CI |
| 协议正确性 | 向量是否代表真实平台行为、独立实现是否与实测一致 | 协议取证 |

- 不得因为协议未完全验证就推迟向量资产；
- 不得因为向量测试通过就宣称协议正确（预期结果若由被测实现生成，只是自证）；
- 向量可信必须同时满足：
  1. 来自真实请求/响应样本，**或**由独立于被测实现的工具生成（二选一）；
  2. 有采集时间、采集人、平台版本记录（必要项，不能替代第 1 条）；
- 向量放 `test/vectors/<protocol>/`，并附 `meta.json` 记录来源。

示例：

```dart
class MockDio extends Mock implements Dio {}

test('登录成功解析 userId', () async {
  final dio = MockDio();
  when(() => dio.post<String>(any(), data: any(named: 'data')))
      .thenAnswer((_) async => Response<String>(
            data: '|user-id|张小赞|hash|0008',
            statusCode: 200,
            requestOptions: RequestOptions(path: '/PersonWap/GetPersonInfo'),
          ));
  // ...
});
```

---

## 12. 网络与环境

- `API_BASE_URL` 通过 `--dart-define` 注入，默认内网地址；
- 生产必须 HTTPS；HTTP 仅限内网；
- 统一超时：连接 10s / 接收 20s；
- 会话失效判定以 §8.11 信号表为准，本节不重复定义；
- 错误映射为中文用户提示，不把原始异常抛给 UI；
- 不关闭 TLS 校验。

---

## 13. 知识盲区

遇到以下领域先查文档，不凭经验写：

- 平台 Esdt / AES / RSA 协议；
- 积分延迟、规则变更、任务上限；
- 平台限流、风控、验证码；
- Flutter 3.47 的 material_ui / listen 迁移；
- 依赖大版本升级。

---

## 14. 参考文档

```text
docs/api/登录接口文档.md
docs/api/积分查询接口文档.md
docs/api/手机考试接口文档.md
docs/api/模拟考试接口文档.md
docs/api/签到接口文档.md
docs/api/阅读学习接口文档.md
docs/api/成绩查询与学习统计接口文档.md
docs/api/题库切换接口文档.md
docs/api/evidence-register.md（协议证据登记）
```

补充：

- 设计（如继续做 UI）：`docs/design/一键自动化UI方案.md`
- Flutter 官方技能：`.agents/skills/`（仅官方 25 个）

---

## 15. 新项目初始化清单

```text
1. 新建 Flutter 项目，Flutter 3.47+
2. 复制本文件为根目录 AGENTS.md
3. 复制 docs/api/ 与 .agents/skills/
4. 添加 §2 依赖
5. 配置 analysis_options（riverpod_lint、strict-casts/inference/raw-types）
6. 实现 core/network + core/protocol + auth
7. 实现 tasks + agent 状态机
8. 实现 exam（先手机考试，再模拟考试）
9. 实现 checkin / reading
10. 实现 stats / settings
11. CI: format --set-exit-if-changed / analyze / test
12. 真实环境跑通：登录 → 今日 → 一键执行
```

---

## 16. 变更记录

| 版本 | 日期 | 变更 |
|---|---|---|
| v1.0 | 2026-10-27 | 新项目独立规则首版 |
| v1.1 | 2026-10-27 | 移除手机练习业务（业务决策），范围收敛为考试/签到/阅读/成绩 |
| v1.2 | 2026-10-27 | 技能范围收敛为仅 Flutter 官方技能 |
| v1.3 | 2026-10-27 | 增加执行记录/审计/技术日志规范 |
| v1.4 | 2026-10-27 | 补充分层架构：职责、依赖方向、import 矩阵、纵向切片 |
| v1.5 | 2026-10-27 | 重写架构章节：完整 feature 结构、考试调用链、好/坏示例、评审六问 |
| v1.6 | 2026-10-27 | 增加协议证据分级/升级权限、失败恢复决策表、部分提交用户状态、向量验收拆分 |
| v1.7 | 2026-10-27 | 增加重复提交状态查询与会话过期信号规则 |
| v1.8 | 2026-10-27 | 收口 4 处矛盾：加密细节移出主规范、创建未知语义、settling 超时状态、会话判定统一；补充取消态与向量可信条件 |
| v1.9 | 2026-10-27 | 按独立评审核口：写操作状态矩阵、运行许可、Agent 模板并发/取消/超时、样本脱敏、规则领域优先级 |
| v2.0 | 2026-10-27 | 收口 403/签到/查询语义/写网关/超时竞态；新增可执行验收矩阵 |
| v2.1 | 2026-10-27 | 浏览器实测修正：type=2 记录为手机自测、type=1 为手机模拟；查询须带 type=2/3 |
| v2.2 | 2026-10-27 | 补回代码注释约束（§4.5：中文注释、public API 用 `///`、复杂逻辑说明“为什么”、生成文件与 analyzer 指令豁免）；原「代码评审六问」顺延为 §4.6 |
| v2.3 | 2026-10-29 | 按实测修正 §8.5 积分口径（手机考试 `Max=16`/`Accumulate=6`、模拟 `Max=8`，需跑 2 场；“未到账即停止”而非继续创建）；§8.8 增加「同一端点按行为分别登记」；回写 evidence-register 手机考试 `observed→verified` 与行为级登记 |
| v2.4 | 2026-10-29 | 新增 §8.1.1 身份证号校验（GB 11643）：补地址码省级前缀校验、明确四项必校与两项有意不校；积分轮询窗口定为 10s × 9 = 90s |
| v2.5 | 2026-10-29 | 身份证地址码收敛为**大陆 31 个省级区划**：移除港澳台（71/81/82/83）与境外（91）前缀，与平台只接受大陆号码一致 |
| v2.6 | 2026-10-29 | 按 `riverpod_lint` 修订三类问题：①`only_use_keep_alive_inside_keep_alive`——keepAlive provider 引用 autoDispose provider（`bankPreset`/`readingPreset` 改为 keepAlive）；②`avoid_public_notifier_properties`——删除 `DailyAutoRunner.running` getter，改由 `state` 推导；③同类问题：轮询配置从 notifier 可变字段改为 `creditPollIntervalProvider`/`creditPollCountProvider`，测试用 override 注入 |
| v2.7 | 2026-10-29 | 全项目审计后按实测修复（每项均有复现）：①预设页换年份后保存按钮可点、`_bank!` 崩溃；②结算「未合格」被判合格、`100.0` 解析失败；③提交答案正则无词边界致 `success:false` 判成功；④一键执行异常冒泡、UI 无终态、状态跨账号残留；⑤vData 提取抽出 `VDataExtractor`（花括号配对，区分 missing/malformed）；⑥`JsonEnvelope` 补读 `error` 字段与字符串 `success`；⑦RSA 公钥 XML 容错（属性/大小写/跨行）+ Base64 空白清洗 + 长度预检；⑧阅读「已达上限」改关键词组合判定；⑨`ref.invalidate` 前补 `mounted` 守卫；⑩签到会话失效清理；⑪身份证补 GB 11643 校验位与大陆省级地址码 |
| v2.8 | 2026-10-29 | 记录 Tab 新增「个人积分榜」：账号持有人授权真机实测 `POST /ArchiveManger/D_PersonAccumulate/GetAccumulateRankingListOne`（`pid`/`begin`/`end` 走 Esdt、`type` 明文 `1`单位/`0`集团；`Mark` 恒 null、积分在 `AllCount`、`message` 为「姓名\|排名\|积分」），等级 `verified` 并落盘样本。成绩榜/学习时长榜**保留**，与积分榜三选一并存；积分榜额外提供「本周/本月」切换 |
| v2.9 | 2026-10-29 | 底部导航与模块重命名：Tab 1「今日」→「首页」、Tab 2「记录」→「统计」；feature 目录 `records`→`stats`、路由 `/records`→`/stats`、类名 `RecordsApi/Repository/Page/Route`→`Stats*`；业务级 `record`（`ExamRecord`/`fetchExamRecords` 等）保留不变；时长榜补「本周/本月」切换；时长格式化改为与平台一致的三段式「X小时Y分Z秒」 |
