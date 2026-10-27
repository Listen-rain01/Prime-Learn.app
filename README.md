# Prime Learn

陕西煤业「素质兴安」平台（澄合矿业全员安全培训管理平台）的移动客户端与智能代理。

**形态**：纯接口客户端，不含 WebView，不做页面自动化。所有平台协议以 `docs/api/` 为唯一事实来源。

## 技术栈

| 项 | 版本 |
|---|---|
| Flutter | 3.47.x |
| Dart | 3.13.x |
| 状态管理 | Riverpod 3.x（`@riverpod` 代码生成） |
| 路由 | go_router 18.x（`@TypedGoRoute` 类型化路由） |
| 网络 | Dio + CookieJar（全流程复用同一 Cookie 容器） |
| 存储 | shared_preferences（非敏感）、flutter_secure_storage（账号标识） |

## 快速开始

```bash
flutter pub get

# 内网/测试环境（默认地址见 lib/core/network/api_config.dart）
flutter run --dart-define=API_BASE_URL=http://<platform-host>:<port>

# 生产必须 HTTPS
flutter run --dart-define=API_BASE_URL=https://<domain>
```

> 基础地址由部署环境决定，禁止硬编码到业务代码，只能通过 `--dart-define` 注入。

## 目录结构（Feature-First）

```text
lib/
├── app/                 # 装配：MaterialApp、路由、主题
├── core/                # 基础设施：网络、协议、会话、工具、通用组件
│   ├── network/         # ApiClient、ApiException、超时与错误映射
│   ├── protocol/        # EsdtCodec、PipeResponse
│   ├── session/         # Session、SessionStore、AccountMemory、会话失效识别
│   ├── errors/          # UseCaseFailure
│   ├── utils/           # Redactor、IdCardValidator
│   └── widgets/         # AppTextField、PrimaryButton、InlineNotice、TonalBlock
├── features/            # 业务功能，一个功能一个目录
│   ├── auth/            # 登录与会话（data / domain / application / presentation）
│   └── tasks/           # 指挥台（今日任务待接入）
└── main.dart
```

依赖方向：`presentation → application → domain ← data`，`core` 不依赖 `features`。

## 开发命令

```bash
dart run build_runner build        # 生成 Riverpod / go_router 代码
dart format .
flutter analyze
flutter test
```

提交前必须通过 `dart format --set-exit-if-changed .`、`flutter analyze`、`flutter test`。

`test/architecture/conventions_test.dart` 把约定变成测试：文件名 `lower_snake_case`、
`core` 不依赖 `features`、`presentation`/`application` 不直接依赖 `data`、
`domain` 不引入 Flutter/Dio/Riverpod、feature 目录名在约定集合内。

真实环境探针（不参与 CI）：凭据只走环境变量，不落盘、不提交。

```bash
$env:PL_ID='...'; $env:PL_PWD='...'; dart run tool/live_probe.dart
Remove-Item Env:PL_ID,Env:PL_PWD
```

## UI 基线

当前实现即视觉基线，详见 `docs/ui/README.md`（早期从 Web 项目规格复刻的那份已归档到 `docs/ui/archive/`，不再作为依据）：

- Material 3，`colorSchemeSeed: Colors.blue`，亮/暗色跟随系统；
- 全部使用主题语义令牌，不硬编码颜色；主分组块为 `surfaceContainerLow` + 20dp 圆角、无阴影；
- 通用组件：`core/widgets`（`AppTextField`、`PrimaryButton`、`InlineNotice`、`TonalBlock`）；
- 错误提示：就近内联（字段 `errorText` + 操作按钮上方 `InlineNotice`），不使用 SnackBar；
- 导航：3 Tab（今日 / 记录 / 我的），`StatefulShellRoute.indexedStack`。

## 协议与证据等级

- 接口文档：`docs/api/`
- 证据登记：`docs/api/evidence-register.md`

当前所有关键写操作（创建考试、提交答案、结算、签到）的证据级别为 `observed`，
**未达到 `verified`，因此运行期阻断真实写操作**。详见 `AGENTS.md` §8.8。

Esdt 向量的生成方式与来源记录在 `test/vectors/esdt/meta.json`：
由 `docs/dev/esdt-vectors.mjs`（独立 JavaScript 实现）生成，
仅能证明「实现符合文档算法」，不代表协议已在真实平台验证。

## 当前进度

- [x] 工程骨架、依赖、严格静态分析、CI 三件套
- [x] `core/protocol`：Esdt 编码、竖线响应解析、黄金向量测试
- [x] `core/network`：Dio + CookieJar、超时、错误映射、会话失效识别
- [x] `features/auth`：登录全链路（预建会话 → 登录 → 校验会话/取题库）
- [x] 登录页（Material 3 seed 蓝、FlutterLogo、字段内联校验）、类型化路由、登录态守卫
- [x] `features/tasks`：今日任务/积分（`GetPersonTodayAccumulateOne`，真实环境验证通过）、今日页（按接口自然顺序展示任务、今日得分/上限、加载/错误/空态）、会话失效清理
- [x] 3 Tab shell（今日 / 记录 / 我的，`StatefulShellRoute.indexedStack`）
- [x] `features/records`：考试记录（手机/模拟/理论，`GetMyExamListOne`）+ 积分明细（`GetMyAccumulateListOne`），真实环境验证通过
- [x] `features/settings`：账号与当前题库、个人信息（`MyBaseInfo` 的 vData：工号/身份证/单位/联系方式/地址，身份证与手机号脱敏展示）与头像（`GetPersonPhoto`，独立加载、失败回退姓名首字）、退出登录（题库切换待接入）
- [ ] 排名与学习统计（`GetMarkRankingList` 等）
- [ ] 手机考试 / 模拟考试流程（写操作需先完成协议取证 + 写网关）
- [ ] 签到 / 阅读学习（同上）
- [ ] 执行记录与审计日志

## 免责声明

本项目仅用于账号持有人自己的学习任务自动化，不绕过验证码或风控；
平台要求二次确认时必须交还用户处理。
