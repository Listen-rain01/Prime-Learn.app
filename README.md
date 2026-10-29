# Prime Learn

陕西煤业「素质兴安」平台（澄合矿业全员安全培训管理平台）的移动客户端与智能代理。

**形态**：纯接口客户端，不含 WebView，不做页面自动化。所有平台协议以 `docs/api/` 为唯一事实来源。

**当前版本**：`1.0.0`（build 1）

---

## 下载安装

前往 [Releases](https://github.com/Listen-rain01/Prime-Learn.app/releases) 下载 APK。

**注意：本应用提供两套安装包，分别连接不同服务器，功能完全一致，只是接口地址不同，请勿混装。**

| 服务器 | 接口地址 | 文件名特征 |
|---|---|---|
| A | `219.144.20.38:9090` | 文件名含 `219.144.20.38` |
| B | `61.150.84.25:100` | 文件名含 `61.150.84.25` |

再按手机架构选包（**绝大多数手机选 `arm64-v8a`**）：

| 架构 | 适用设备 | 单包大小 |
|---|---|---|
| `arm64-v8a` | 现代安卓手机（64 位，推荐） | 19.1 MB |
| `armeabi-v7a` | 较老的 32 位手机 | 16.8 MB |
| `x86_64` | 安卓模拟器 / x86 设备 | 20.5 MB |

> 已启用 ABI 拆分与资源收缩，单包体积约为合并包的 1/3。
> 装错服务器会导致数据不互通，请先与管理员确认地址。

---

## 技术栈

| 项 | 版本 |
|---|---|
| Flutter | 3.47.x |
| Dart | 3.13.x |
| 状态管理 | Riverpod 3.x（`@riverpod` 代码生成） |
| 路由 | go_router 18.x（`@TypedGoRoute` 类型化路由） |
| 网络 | Dio + CookieJar（全流程复用同一 Cookie 容器） |
| 存储 | shared_preferences（非敏感）、flutter_secure_storage（账号凭据） |
| 加密 | pointycastle（考试结算 RSA PKCS#1 v1.5 + AES-128-ECB） |

## 快速开始

```bash
flutter pub get

# 内网/测试环境（默认地址见 lib/core/network/api_config.dart）
flutter run --dart-define=API_BASE_URL=http://<platform-host>:<port>

# 生产必须 HTTPS
flutter run --dart-define=API_BASE_URL=https://<domain>
```

> 基础地址由部署环境决定，禁止硬编码到业务代码，只能通过 `--dart-define` 注入。
> 注意传入的是**根地址**（如 `http://host:port`），不要带 `/Home/LoginWap2` 之类的页面路径，
> 否则接口会被拼成 `{根地址}/PersonWap/...` 从而 404。

## 目录结构（Feature-First）

```text
lib/
├── app/                 # 装配：MaterialApp、路由、主题
├── core/                # 基础设施（不依赖任何 feature）
│   ├── network/         # ApiClient、ApiException、超时与错误映射
│   ├── protocol/        # EsdtCodec、SettleCrypto、PipeResponse、JsonEnvelope、VDataExtractor
│   ├── session/         # Session、SessionStore、AccountMemory、会话失效识别
│   ├── errors/          # UseCaseFailure
│   ├── evidence/        # WriteGateway、WriteLevel、WriteEvidence、WriteBlocked
│   ├── utils/           # Redactor、IdCardValidator、DateFormatter
│   └── widgets/         # AppTextField、PrimaryButton、InlineNotice、TonalBlock
├── features/            # 业务功能，一个功能一个目录
│   ├── auth/            # 登录与会话、多账号记忆
│   ├── tasks/           # 今日积分、每日任务、一键完成、执行状态机
│   ├── exam/            # 手机考试 / 模拟考试全链路（含加密结算）
│   ├── checkin/         # 签到
│   ├── reading/         # 阅读学习与阅读预设
│   ├── stats/           # 考试记录、积分明细、排行榜、成绩趋势
│   └── settings/        # 账号、题库预设、个人信息、退出登录
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

## 构建与发布

### 打包（按 ABI 拆分 + 资源收缩）

```bash
# 服务器 A
flutter build apk --release --split-per-abi \
  --dart-define=API_BASE_URL=http://219.144.20.38:9090

# 服务器 B
flutter build apk --release --split-per-abi \
  --dart-define=API_BASE_URL=http://61.150.84.25:100
```

产物在 `build/app/outputs/flutter-apk/`，每次构建会覆盖，建议改名为
`PrimeLearn-v<版本>-<服务器>-<架构>.apk` 后再归档。

### 签名

发布包使用 `android/key.properties` + `android/app/*.jks` 签名，两者均被 `.gitignore` 排除：

```properties
storePassword=...
keyPassword=...
keyAlias=primelearn
storeFile=primelearn-release.jks
```

- `key.properties` 不存在时自动退回 debug 签名（保证 CI/无凭据环境仍可构建）；
- **keystore 必须离线备份**：丢失后将无法更新已发布的应用。

### 校验产物

```bash
# 确认签名证书
apksigner verify --print-certs app-arm64-v8a-release.apk

# 确认接口地址已正确注入（解开 APK 查 libapp.so 内的常量）
```

## UI 基线

当前实现即视觉基线，详见 `docs/ui/README.md`（早期从 Web 项目规格复刻的那份已归档到 `docs/ui/archive/`，不再作为依据）：

- Material 3，`colorSchemeSeed: Colors.blue`，亮/暗色跟随系统；
- 全部使用主题语义令牌，不硬编码颜色；主分组块为 `surfaceContainerLow` + 20dp 圆角、无阴影；
- 通用组件：`core/widgets`（`AppTextField`、`PrimaryButton`、`InlineNotice`、`TonalBlock`）；
- 错误提示：就近内联（字段 `errorText` + 操作按钮上方 `InlineNotice`），不使用 SnackBar；
- 导航：3 Tab（**首页 / 统计 / 我的**），`StatefulShellRoute.indexedStack`，路由 `/`、`/stats`、`/settings`。

## 协议与证据等级

- 接口文档：`docs/api/`
- 证据登记：`docs/api/evidence-register.md`

按 `AGENTS.md` §8.8，证据分四级（`verified` / `observed` / `assumed` / `revalidating`），
**粒度是「接口 + 行为 + 前提」**，不给整份文档打总标签。

当前状态：**10 条 `verified`、20 条 `observed`**。关键写操作已升级为 `verified`：

- 创建考试（`CreateTempExamOne` `type=1` / `type=2`，按行为分别登记）
- 进入考试（`SetOnlineTestOne` `style=0` / `style=1`）
- 提交答案（`DoWriteAnswerAll`）
- 结算（`CEndTimeOne` 加密 / `CEndTimeMobil`）
- 签到（`CheckInOne`）、知识学习（`StudyKnowledgeOne`）、题库切换（`SaveExamTypeIdsOne`）
- 个人积分排行（`GetAccumulateRankingListOne`）

运行期由 `core/evidence/` 的统一写网关校验：`observed` / `assumed` / `revalidating`
的写操作会被阻断且不发出 HTTP。

Esdt 向量的生成方式与来源记录在 `test/vectors/esdt/meta.json`：
由 `docs/dev/esdt-vectors.mjs`（独立 JavaScript 实现）生成，
仅能证明「实现符合文档算法」，不代表协议已在真实平台验证。

## 当前进度

- [x] 工程骨架、依赖、严格静态分析、CI 三件套
- [x] `core/protocol`：Esdt 编码、竖线响应、AES/RSA 结算加密、JSON 信封、vData 提取、黄金向量测试
- [x] `core/network`：Dio + CookieJar、超时、错误映射、会话失效识别
- [x] `core/evidence`：按「端点#行为」分级的写网关
- [x] `features/auth`：登录全链路 + 多账号记住与切换（密码存 secure storage，可删除单账号）
- [x] `features/tasks`：今日任务/积分、按接口自然顺序展示、「一键完成今日任务」状态机
- [x] 3 Tab shell（首页 / 统计 / 我的）
- [x] `features/exam`：手机考试（`type=2` / `style=0` / `CEndTimeOne` 加密）与模拟考试
      （`type=1` / `style=1` / `CEndTimeMobil`）全链路，真实跑通 100 分
- [x] 执行前自动对齐题库（`SaveExamTypeIdsOne` 切换 + `FirstIndexOne` 校验）
- [x] `features/checkin`：签到（写网关 + 平台前置条件提示）
- [x] `features/reading`：阅读预设 + 一键完成今日阅读（按日封顶、幂等）
- [x] `features/stats`：考试记录、积分明细、个人成绩趋势
- [x] 排行榜三选一：成绩榜（本月）、学习时长榜（本周/本月可切）、个人积分榜（本周/本月可切），
      均支持单位/集团
- [x] 学习时长格式化与平台一致（三段式「X小时Y分Z秒」）
- [x] `features/settings`：账号与当前题库、个人信息（脱敏展示）、头像、题库预设、退出登录
- [x] 一键完成：模拟考试 → 手机考试 → 签到 → 知识学习；每步先查进度、已完成跳过、
      积分未到账即停止（避免烧考试次数）
- [ ] 执行记录与审计日志（`AGENTS.md` §9）
- [ ] 手机练习（`AGENTS.md` v1 范围外，协议已取证于 `docs/api/手机练习接口文档.md`）

## 免责声明

本项目仅用于账号持有人自己的学习任务自动化，不绕过验证码或风控；
平台要求二次确认时必须交还用户处理。
