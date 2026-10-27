# Prime Learn 纯 UI 复刻规格

版本：2026-10-25  
范围：只描述当前 App 的视觉、布局、文案、状态和交互表现；不包含接口、数据来源、业务规则、路由实现或状态管理实现。  
目标：按本文件重建后，页面结构、视觉层级、间距、颜色、文案、状态和弹窗应与当前 UI 一致。

---

## 0. 截图索引

截图目录：`docs/ui/screenshots/`

| 文件 | 页面 |
|---|---|
| `01-login.png` | 登录页 |
| `02-home.png` | 首页 |
| `03-strategy.png` | 策略页 |
| `04-automation.png` | 自动化页（固定控制条状态） |
| `05-automation-sheet.png` | 自动化控制面板 |
| `06-profile.png` | 我的页 |
| `07-bank-units.png` | 题库选择：单位层 |
| `08-bank-categories.png` | 题库选择：分类层 |

截图设备：1080×2424 像素，约 3x 密度，对应约 360×808 dp。  
截图只用于视觉对照；尺寸仍以本文件的 dp 规格为准。

---

## 1. 全局视觉基线

### 1.1 框架与主题

- Material 3。
- Flutter 默认 Material 3 字体，无自定义字体。
- 主色种子：`Colors.blue`，即 `#2196F3`。
- 亮色/暗色均使用 Material 3 `ColorScheme.fromSeed` 生成。
- 主题模式：跟随系统。
- 页面背景：`colorScheme.surface`。
- 状态栏/系统栏：edge-to-edge；亮色模式深色图标，暗色模式浅色图标。
- 不使用 Card、阴影、描边来分隔主内容；使用色块、圆角、留白和细分隔线。
- 所有用户可见文案为简体中文，品牌名和版权除外。

### 1.1.1 复刻环境

为了复刻 Material 3 自动生成的颜色、字体、按钮高度和导航栏样式，建议使用：

```text
Flutter 3.47.x
Dart 3.13.x
Material 3
```

主题配置：

```dart
theme: ThemeData(
  useMaterial3: true,
  colorSchemeSeed: Colors.blue,
),
darkTheme: ThemeData(
  useMaterial3: true,
  colorSchemeSeed: Colors.blue,
  brightness: Brightness.dark,
),
themeMode: ThemeMode.system,
```

颜色不是从截图取色，而是由以上 Material 3 seed 生成。截图中的色值会受设备色彩配置影响，重建时应以主题令牌和 seed 为准。

### 1.1.2 字体与字号来源

- 全部使用 Material 3 默认 `TextTheme`。
- 不加载自定义字体。
- 不手动覆盖全局字号。
- 个别元素有显式样式：
  - 登录输入文字 15dp。
  - 登录主标题 `letterSpacing: -0.5`。
  - 登录按钮 `letterSpacing: 2`。
  - 首页积分数字 `height: 1`。
  - 自动化日志时间使用正文默认行高。

### 1.1.3 资源

- Logo：Flutter 内置 `FlutterLogo`，只显示 mark，不使用自定义图片。
- 图标：全部来自 Material Icons。
- 头像：用户图片；没有图片时显示姓名首字。
- 无背景图、无本地插画、无 Lottie、无自定义 SVG。

### 1.2 语义颜色令牌

不要硬编码蓝色/灰色；按下表使用主题令牌。

| 令牌 | 用途 |
|---|---|
| `primary` | 主操作、选中态、重要状态、图标强调 |
| `onPrimary` | 主色实心按钮文字/图标 |
| `primaryContainer` | 头像底、图标圆底 |
| `onPrimaryContainer` | 头像文字/图标 |
| `surface` | 页面背景 |
| `onSurface` | 主标题、正文、主要数值 |
| `surfaceContainerLow` | 所有内容分组块、输入区背景、按钮底 |
| `surfaceContainerHighest` | 自动化策略摘要块 |
| `onSurfaceVariant` | 次要说明、标签、辅助信息 |
| `outline` | 暂不执行/禁用文案 |
| `outlineVariant` | 0.5–1dp 分隔线 |
| `tertiary` | “需要切换”“有未保存修改” |
| `error` | 错误、退出登录、失败日志 |

### 1.3 圆角

| 元素 | 圆角 |
|---|---:|
| 页面主分组块 | 20dp |
| 登录输入框 | 12dp |
| 登录按钮 | 12dp |
| 自动化策略摘要 | 12dp |
| 自动化状态条/控制条 | 20dp（控制条两端） |
| 复选框 | 4dp |
| 头像 | 圆形 |

### 1.4 间距与页面边距

- 首页、策略页：左右 20dp。
- 我的页：左右 20dp。
- 登录页：左右 24dp，上下 32dp。
- 首页顶部 16dp，底部 32dp。
- 策略页顶部 16dp，底部 32dp。
- 我的页顶部 24dp，底部 32dp。
- 主要分组块之间：16dp。
- 分组块内部：16dp 内边距；底部较大的分组可用 16,16,16,8。
- 分组块内标题到内容：4–10dp。
- 操作按钮之间：8–10dp。

### 1.5 分隔线

- 列表/信息行之间使用 `Divider(height: 1, thickness: 0.5, color: outlineVariant)`。
- 分组内部内容分隔使用 `Divider(height: 20, color: outlineVariant)`。
- 不使用粗线或深色分割线。

### 1.6 触控尺寸

- 所有可点击图标/文字按钮：最小点击区域 48×48dp。
- 底部导航每个目的地占满 1/4 宽度。
- 任务行、列表行可点击高度不小于 48dp。

### 1.7 响应式规则

- 以 360dp 宽手机为基准。
- 登录页内容最大宽度 440dp，超出时居中。
- 其他页面不设置固定内容宽度；左右边距固定 20dp。
- 所有长文本最多 1–2 行，超出省略。
- 不横向滚动。
- 小屏时允许纵向滚动，不压缩文字。
- 系统字体放大时，卡片高度随内容增长，不使用固定高度文本容器。
- 暗色模式下仅替换主题令牌，不改变布局、图标和文案。

### 1.8 页面层级和阴影

- 页面层级靠背景色差、圆角、间距和字重建立。
- 主内容块不使用阴影。
- 输入框不使用填充底色。
- 浮层（Bottom Sheet、Dialog）使用 Material 3 默认 elevation 和 scrim。
- 分隔线使用 `outlineVariant`，保持低对比度。

---

## 2. 应用 Shell 与底部导航

### 2.1 结构

```text
Scaffold
├── body: 当前 Tab 页面
└── bottomNavigationBar: NavigationBar
```

### 2.2 NavigationBar

- 高度：64dp。
- 4 个目的地，等宽。
- 未选中使用 outline 图标；选中使用 filled 图标。
- 标签常显，不隐藏。
- 标签和图标颜色由 Material 3 NavigationBar 默认处理；选中态由 `indication`/主题色显示。

| 顺序 | 标签 | 未选中图标 | 选中图标 |
|---:|---|---|---|
| 1 | 首页 | `Icons.home_outlined` | `Icons.home` |
| 2 | 自动化 | `Icons.auto_mode_outlined` | `Icons.auto_mode` |
| 3 | 策略 | `Icons.tune_outlined` | `Icons.tune` |
| 4 | 我的 | `Icons.person_outline` | `Icons.person` |

### 2.3 页面安全区

- 每个 Tab 页面使用 `SafeArea`。
- 自动化页使用 `SafeArea(bottom: false)`，因为底部控制条和导航栏由 Shell 管理。
- 首页、策略页、我的页内容可滚动，底部留 32dp。

### 2.4 页面标题规则

- 首页：没有 AppBar，没有页面大标题；第一块是个人信息/积分块。
- 自动化：没有 AppBar，没有页面大标题；顶部直接是 WebView。
- 策略：没有 AppBar，没有“任务策略”大标题；第一块是当前平台题库。
- 我的：没有 AppBar，没有“我的”大标题；第一块是个人资料卡。
- 资源选择器：有 AppBar，标题分别为“选择题库”“选择试卷”“选择文章”。

---

## 3. 登录页

截图：`01-login.png`

### 3.1 页面结构

```text
Scaffold
└── SafeArea
    └── SingleChildScrollView
        └── Center
            └── MaxWidth 440dp
                └── Column
```

- 页面水平内边距 24dp，垂直 32dp。
- 内容最小高度为视口高度，垂直居中。
- 键盘弹出时允许滚动，拖动时收起键盘。

### 3.2 从上到下

| 元素 | 规格 |
|---|---|
| Logo | `FlutterLogo(size: 100, style: FlutterLogoStyle.markOnly)`，居中 |
| Logo 后间距 | 28dp |
| 主标题 | `Prime Learn`，`headlineMedium`，`w700`，`letterSpacing: -0.5`，`onSurface`，居中 |
| 主标题后间距 | 10dp |
| 副标题 | `欢迎回来，请登录你的账号`，`bodyMedium`，`onSurfaceVariant`，`height: 1.5`，居中 |
| 副标题后间距 | 44dp |
| 身份证输入框 | 见 3.3 |
| 输入框后间距 | 18dp |
| 密码输入框 | 见 3.3 |
| 密码后间距 | 8dp |
| 记住账号行 | 见 3.4 |
| 记住账号后间距 | 24dp |
| 登录按钮 | 见 3.5 |
| 按钮后间距 | 36dp |
| 安全提示 | `Icons.shield_outlined` 14dp + `安全登录 · 仅限授权账号`，`bodySmall`，`onSurfaceVariant`，居中 |
| 安全提示后间距 | 8dp |
| 版权 | `© 2026 Prime Learn · 保留所有权利`，`bodySmall`，`onSurfaceVariant`，居中 |

### 3.3 输入框

两个输入框使用完全相同的 decoration：

- 圆角 12dp。
- 边框颜色 `primary`，宽度默认。
- `enabledBorder`、`focusedBorder`、`border` 均为 `OutlineInputBorder`，圆角 12dp，边框 `primary`。
- 不填充背景，`filled: false`。
- 内容内边距：水平 16dp，垂直 18dp。
- 标签、提示文字颜色 `onSurfaceVariant`。
- 浮动标签颜色 `primary`。
- 输入文字颜色 `onSurface`，字号 15。
- 计数器隐藏：`counterText: ''`。

#### 身份证号

- label：`身份证号`
- hint：`请输入 18 位身份证号`
- prefix icon：`Icons.badge`，`onSurfaceVariant`
- maxLength：18
- 键盘类型：text
- 输入框有内容时显示 clear 图标：
  - `Icons.clear`，18dp
  - tooltip：`清空身份证号`
- 输入框加载中禁用。

#### 密码

- label：`密码`
- hint：`请输入登录密码`
- prefix icon：`Icons.lock`，`onSurfaceVariant`
- 默认隐藏密码。
- 后缀图标：
  - 隐藏时：`Icons.visibility`，tooltip `显示密码`
  - 显示时：`Icons.visibility_off`，tooltip `隐藏密码`
- 输入框加载中禁用。

### 3.4 记住账号

```text
[24dp Checkbox]  记住账号
```

- Checkbox 圆角 4dp。
- 未选中/选中使用主题默认色。
- “记住账号”为 `bodySmall`，`onSurfaceVariant`。
- 文字与复选框均可点击切换。
- 文字周围有水平 4dp、垂直 12dp 点击区域。

### 3.5 登录按钮

- 宽：撑满（最大 440dp 容器内）。
- 高：50dp。
- `FilledButton`。
- 圆角 12dp。
- 默认文案：`登 录`（中间一个空格）。
- 字体：`labelLarge`，`w600`，`letterSpacing: 2`，颜色 `onPrimary`。
- 加载时：
  - 按钮禁用；
  - 按钮内显示 20×20dp 圆形进度；
  - 进度颜色 `onPrimary`，`strokeWidth: 2`。
- 禁用/加载/正常状态使用 Material 3 FilledButton 默认状态层。

### 3.6 登录页异常提示

> 本仓库修订（2026-10-28）：改用**就近内联**提示，不再使用 SnackBar。
> 原因见 `docs/ui/PURE_UI_SPEC.md` §9.8：底部浮层离出错位置远、会被键盘遮挡、会自动消失。

- 字段校验错误：直接显示在对应输入框下方（Material `errorText`），输入框描边转 `error`，文字为 `bodySmall` 的 `error` 色。
- 提交失败（平台返回文案，如 `密码错误`）：显示在登录按钮上方，使用内联提示条（`errorContainer` 背景 + `onErrorContainer` 文字 + `Icons.error_outline`，12dp 圆角，内边距 12×10）。
- 用户重新编辑任一项时，字段错误与提交失败提示同时清除。
- 文案示例：
  - `请输入有效的 18 位身份证号`
  - `请输入登录密码`
  - 登录失败时显示错误消息。

---

## 4. 首页

截图：`02-home.png`

### 4.1 页面结构

```text
Scaffold
└── SafeArea
    └── ListView
        ├── 今日积分/当前题库分组
        ├── 16dp
        └── 每日任务分组
```

- ListView padding：`20, 16, 20, 32`。

### 4.2 顶部个人信息与积分块

容器：

- `surfaceContainerLow`
- 圆角 20dp
- 内边距 16dp
- 宽度撑满

第一行：

```text
[姓名]                                [星星] 今日积分 [数字]
```

- 姓名：`titleLarge`，`w700`，`onSurface`，最多 2 行，省略。
- 姓名与积分之间 16dp。
- 积分区域右对齐，最小宽度自然。
- 星星：`Icons.stars_rounded`，20dp，`primary`。
- `今日积分`：`bodySmall`，`onSurfaceVariant`。
- 数字：`headlineSmall`，`w700`，`onSurface`，`height: 1`。
- 星星和“今日积分”之间 6dp；“今日积分”和数字之间 6dp。

第二行：

- 距第一行 6dp。
- 正常：`当前题库：<题库名>`，`bodySmall`，`onSurfaceVariant`，最多 2 行。
- 题库为空：`当前题库：未设置`。
- 加载中：`当前题库加载中...`。
- 失败：`当前题库获取失败`。
- 题库名称过长时 Tooltip 显示完整名称。

### 4.3 每日任务块

容器：

- `surfaceContainerLow`
- 圆角 20dp
- padding：`16, 16, 16, 8`

标题行：

```text
每日任务                         2/7 已完成
```

- 左标题：`titleMedium`，`w600`，`onSurface`。
- 右侧统计：`labelMedium`，`onSurfaceVariant`。
- 右侧格式：`已完成/总数 已完成`。
- 标题行后 4dp。

#### 任务分组顺序

```text
可执行任务
  - 按数据顺序排列
暂不执行 · 不获取积分
  - 签到
  - 视频学习
  - 练习时长
```

- 有可执行任务时先显示。
- 暂不执行组与上一组之间 10dp。
- “暂不执行 · 不获取积分”使用 `labelMedium`，`outline`。
- 暂不执行组不显示规则和进度说明。

#### 普通任务行

垂直内边距 14dp。

左列：

- 名称：`titleSmall`，`w600`，`onSurface`，单行省略。
- 规则：`bodySmall`，`onSurfaceVariant`，最多 2 行；距名称 4dp。
- 状态说明：`bodySmall`，`onSurfaceVariant`，单行省略；距上一条 4dp。

右列：

- 分数：`labelLarge`，`w600`，`onSurface`。
- 状态：`labelMedium`；距分数 2dp。
  - 已完成：`已完成`，`outline`
  - 未完成：`未完成`，`primary`
- 左右列之间 16dp。

#### 暂不执行任务行

- 垂直内边距 10dp。
- 名称颜色 `onSurfaceVariant`。
- 不显示规则和状态说明。
- 右侧分数颜色 `outline`。
- 右侧状态固定为 `暂不执行`，颜色 `outline`。
- 分组内任务之间使用 0.5dp 分隔线。

### 4.4 加载状态

- 垂直 24dp。
- 20×20dp 圆形进度，`strokeWidth: 2`，`primary`。
- 后 12dp。
- 文案：`正在加载每日任务...`，`bodyMedium`，`onSurfaceVariant`。

### 4.5 错误状态

- 垂直 16dp，左对齐。
- 标题：`每日任务加载失败`，`titleMedium`，`w600`，`onSurface`。
- 6dp。
- 错误消息：`bodyMedium`，`onSurfaceVariant`。
- 4dp。
- `TextButton.icon`：
  - icon `Icons.refresh`
  - label `重试`

---

## 5. 策略页

截图：`03-strategy.png`

### 5.1 页面结构

无页面标题。

```text
ListView padding: 20, 16, 20, 32
├── 当前平台题库
├── 16
├── 练习策略
├── 16
├── 考试策略
├── 16
├── 知识学习策略
├── 20
├── 保存状态
├── 8
├── 保存按钮
├── 8
└── 页面说明
```

### 5.2 当前平台题库块

- `surfaceContainerLow`，圆角 20dp，内边距 16dp。
- 左侧 CircleAvatar：
  - 半径 22dp
  - `primaryContainer` 背景
  - `onPrimaryContainer` 前景
  - 图标 `Icons.account_balance_outlined`
- 12dp。
- 中间：
  - 小标签 `当前平台题库`，`bodySmall`，`onSurfaceVariant`。
  - 4dp。
  - 题库名：`titleMedium`，`w600`，`onSurface`，最多 2 行。
  - 加载中显示 `正在获取...`，`titleMedium`，`onSurfaceVariant`。
  - 失败显示 `获取失败`，`titleMedium`，`error`。
- 右侧 IconButton：
  - `Icons.refresh`
  - tooltip：`刷新当前题库`
  - 48×48dp 点击面积。

### 5.3 策略分组块

三种分组使用同一容器：

- `surfaceContainerLow`
- 圆角 20dp
- padding：`16, 16, 16, 8`
- 宽度撑满

标题行：

```text
[图标] 分组标题                     状态
```

- 图标 20dp，`primary`。
- 图标与标题之间 8dp。
- 标题 `titleMedium`，`w600`，`onSurface`。
- 状态右对齐，`labelMedium`。
- 标题行后 10dp。

图标：

| 分组 | 图标 |
|---|---|
| 练习策略 | `Icons.fitness_center_outlined` |
| 考试策略 | `Icons.assignment_outlined` |
| 知识学习策略 | `Icons.menu_book_outlined` |

### 5.4 状态文案

| 状态 | 文案 | 颜色 |
|---|---|---|
| 已匹配 | `已匹配` | `primary` |
| 需要切换 | `需要切换` | `tertiary` |
| 未配置 | `未配置` | `onSurfaceVariant` |
| 已配置 | `已配置` | `primary` |
| 查询失败 | `查询失败` | `error` |

### 5.5 目标行

每行结构：

```text
[84dp 标签] [目标值]                          [选择]
```

- 行底部 8dp。
- 标签：固定宽 84dp，`bodySmall`，`onSurfaceVariant`。
- 值：
  - 已配置：`bodyMedium`，`onSurface`。
  - 未配置：`未配置`，`bodyMedium`，`onSurfaceVariant`。
  - 最多 2 行，省略。
- 右侧 `选择`：
  - `TextButton`
  - 最小尺寸 64×48dp
  - 水平 padding 10dp
  - 标签 `选择`
- 没有编辑动作的行不显示“选择”。

### 5.6 练习策略

```text
练习策略                          未配置/已匹配/需要切换
  目标题库    未配置              选择
```

### 5.7 考试策略

```text
考试策略                          未配置/已匹配/需要切换
  目标题库    未配置              选择
  ─────────────────────────────
  目标试卷    未配置              选择
```

- 两行之间 `Divider(height: 20, outlineVariant)`。
- 目标试卷行只有在已有目标题库后才显示“选择”。

### 5.8 知识学习策略

```text
知识学习策略                      未配置/已配置
  目标文章    未配置              选择
  ─────────────────────────────
  目标分类    ...
  ─────────────────────────────
  阅读类型    图文/PDF
```

- 目标分类和阅读类型只在该分组已有目标文章时显示。
- 阅读类型文案：`图文` 或 `PDF`。
- 没有编辑动作的行不显示“选择”。

### 5.9 保存状态与按钮

保存状态行：

```text
[16dp 图标] 有未保存修改 / 已保存
```

- 有修改：`Icons.edit_outlined`，`tertiary`；文案 `有未保存修改`，`bodySmall`，`tertiary`。
- 无修改：`Icons.check_circle_outline`，`onSurfaceVariant`；文案 `已保存`，`bodySmall`，`onSurfaceVariant`。
- 图标与文字之间 6dp。

保存按钮：

- 撑满宽度。
- `FilledButton`。
- 高度 Material 3 默认。
- 有修改：`保存修改`，可点击。
- 保存中：`保存中...`，禁用。
- 无修改：`已保存`，禁用。
- 按钮上方 8dp。

页面说明：

```text
策略只保存执行目标；任务执行请在自动化页操作。
```

- `bodySmall`，`onSurfaceVariant`，居中。
- 按钮下 8dp。

---

## 6. 自动化页

截图：`04-automation.png`、`05-automation-sheet.png`

### 6.1 页面结构

自动化页在 WebView 下方有一个固定控制条，控制条不覆盖 WebView。

```text
Scaffold
└── SafeArea(bottom: false)
    └── Column
        ├── Expanded: WebView
        └── AutomationStatusBar
```

- WebView 区域撑满剩余空间。
- 控制条高度 64dp。
- 控制条占据布局高度，不悬浮覆盖 WebView。
- 底部导航栏在控制条下方。

WebView 内显示的是平台网页，不属于 App 自定义视觉；复刻 App 外壳时只需要还原 WebView 容器及其加载态。网页内容本身不纳入本规格。

### 6.1.1 WebView 初始加载态

覆盖整个 WebView 区域，不覆盖底部控制条：

- 背景：`surface`。
- 居中。
- 加载图形：
  - 容器 48×48dp。
  - 底层静态圆环：`CircularProgressIndicator(value: 1, strokeWidth: 3, color: outlineVariant)`。
  - 上层旋转进度：`CircularProgressIndicator(strokeWidth: 3, color: primary)`。
- 16dp。
- 文案：`正在加载页面...`，`bodyMedium`，`onSurfaceVariant`。

### 6.1.2 WebView 崩溃态

整个 WebView 区域居中显示：

- `Icons.error_outline`，48dp，`error`。
- 12dp。
- 标题：`网页进程异常`，`titleMedium`。
- 8dp。
- 说明：`请重新加载自动化页面`，`bodyMedium`，`onSurfaceVariant`。
- 16dp。
- `OutlinedButton`，文案 `重新加载`。

### 6.2 固定控制条

容器：

- `surfaceContainerLow`
- 高度 64dp
- 水平内边距 16dp
- 可点击，打开控制面板

从左到右：

- 状态图标/加载指示：
  - 加载中：18×18dp CircularProgressIndicator，`strokeWidth: 2`。
  - 失败：`Icons.error_outline`，20dp，`error`。
  - 已完成：`Icons.check_circle_outline`，20dp。
  - 普通：`Icons.smart_toy_outlined`，20dp。
- 10dp。
- 文字列：
  - 第一行 `自动化`，`titleSmall`，`w600`，`onSurface`。
  - 第二行状态，`bodySmall`，单行省略。
- 8dp。
- 右侧 `Icons.keyboard_arrow_up`，`onSurfaceVariant`。

状态文案：

```text
正在读取策略...
策略读取失败
正在执行...
任务已就绪
未配置任务
```

状态颜色：

- 加载/未配置/执行中：`onSurfaceVariant`
- 失败：`error`
- 就绪：`primary`

### 6.3 控制面板

点击控制条后打开可拖拽 Bottom Sheet。

- 通过 `showModalBottomSheet` 打开。
- 顶部显示 drag handle。
- 使用 `DraggableScrollableSheet`：
  - 初始高度 55%。
  - 最小高度 35%。
  - 最大高度 90%。
- 面板内容可滚动。
- 面板使用默认 `surface` 背景，顶部圆角按 Material 3 Bottom Sheet 默认。
- 内容内边距：左右 20dp，顶部 4dp，底部 24dp。

#### 面板标题

```text
自动化控制
任务使用已保存的策略，执行结果会写入日志。
```

- 标题：`titleLarge`，`w600`，`onSurface`。
- 说明：`bodySmall`，`onSurfaceVariant`，距标题 4dp。
- 说明后 16dp。

#### 策略摘要块

- `surfaceContainerHighest`
- 圆角 12dp
- 内边距 12dp
- 两行文字，`bodySmall`：

```text
考试：<题库名> / <试卷名>  或 未配置考试策略
知识：<文章标题>            或 未配置知识学习文章
```

- 两行之间 4dp。
- 加载中显示 `读取中...`。
- 摘要块后 16dp。

#### 任务按钮

第一行两个等宽按钮：

```text
[手机考试]  [模拟考试]
```

- `FilledButton.tonalIcon`
- 图标 18dp：
  - 手机考试：`Icons.phone_android`
  - 模拟考试：`Icons.assignment_outlined`
- 两个按钮之间 8dp。
- 未配置/执行中时禁用。
- 按钮下 10dp。

第二行：

```text
[按策略完成知识学习]
```

- 撑满宽度。
- `OutlinedButton.icon`。
- 图标 `Icons.menu_book_outlined`。
- 知识学习执行中：16×16dp 进度指示，文案 `正在完成知识学习...`。
- 未配置/执行中时禁用。

#### 日志入口

```text
[日志图标] 执行日志
            暂无执行记录 / N 条记录        >
```

- `ListTile` 内容内边距 0。
- 图标 `Icons.receipt_long_outlined`，`primary`。
- 标题 `执行日志`，`titleSmall`，`onSurface`。
- 副标题：`暂无执行记录` 或 `${N} 条记录`，默认 bodySmall。
- 尾部 `Icons.chevron_right`。

#### 执行失败提示

- 在日志入口下方 4dp。
- 显示当前错误消息，`bodySmall`，`error`。

### 6.4 开始考试确认弹窗

标题：

```text
开始手机考试 / 开始模拟考试
```

正文：

```text
目标题库：<题库名>
目标试卷：<试卷名>

将自动读取题目、选择答案并交卷，产生一次考试记录。
```

按钮：

- `取消`：TextButton
- `开始`：FilledButton

点击开始后关闭控制面板，让用户看到下方 WebView。

### 6.5 知识学习确认弹窗

标题：

```text
完成知识学习
```

正文：

```text
目标文章：<文章标题>

将直接调用知识学习完成接口，并校验今日积分。
```

按钮：

- `取消`
- `开始`

### 6.6 执行日志弹窗

- 从控制面板打开第二个 Bottom Sheet。
- 高度为屏幕高度 65%。
- 顶部 drag handle。
- 左右内边距 20dp，底部 16dp。
- 标题：`执行日志`，`titleMedium`，`w600`。
- 标题下 8dp。
- 日志列表：
  - 每行时间宽 62dp，`bodySmall`，`onSurfaceVariant`。
  - 时间格式 `HH:mm:ss`。
  - 级别图标：
    - info：7dp 圆点
    - success：`Icons.check_circle_outline` 14dp，`primary`
    - error：`Icons.error_outline` 14dp，`error`
  - 图标与消息之间 8dp。
  - 消息使用 `SelectableText`，`bodySmall`；普通 `onSurface`，成功 `primary`，失败 `error`。
  - 日志项之间 8dp。
- 无日志时居中显示 `暂无日志`，`bodyMedium`，`onSurfaceVariant`。

---

## 7. 我的页

截图：`06-profile.png`

### 7.1 页面结构

```text
Scaffold
└── SafeArea
    └── ListView padding: 20, 24, 20, 32
        ├── 个人资料卡
        ├── 16
        ├── 个人信息卡
        ├── 16
        └── 退出登录按钮
```

### 7.2 个人资料卡

- `surfaceContainerLow`，圆角 20dp，内边距 16dp。
- 左侧 CircleAvatar：
  - 半径 36dp。
  - 背景 `primaryContainer`，前景 `onPrimaryContainer`。
  - 有头像时显示头像。
  - 无头像时显示姓名首字，`headlineSmall`，`w600`。
- 16dp。
- 右侧：
  - 姓名：`titleLarge`，`w600`，`onSurface`，单行省略。
  - 姓名为空时显示 `未填写姓名`。
  - 4dp。
  - 单位：`bodyMedium`，`onSurfaceVariant`，最多 2 行。

### 7.3 个人信息卡

- `surfaceContainerLow`，圆角 20dp。
- padding：`16, 16, 16, 8`。
- 标题 `个人信息`，`titleMedium`，`w600`，`onSurface`。
- 标题下 8dp。

行顺序：

```text
工号
姓名
身份证号
工作单位
联系方式
家庭地址
```

行规格：

- 垂直内边距 13dp。
- 左标签固定宽度 80dp，`bodyMedium`，`onSurfaceVariant`。
- 标签与值之间 16dp。
- 值 `bodyMedium`，`onSurface`。
- 值为空显示 `未填写`。
- 行之间 0.5dp `outlineVariant` 分隔线。

### 7.4 退出登录

- 独立 `surfaceContainerLow` 块，圆角 20dp。
- 高度 56dp。
- 使用 TextButton，撑满宽度。
- 文案 `退出登录`，颜色 `error`。
- 加载中禁用，文案 `退出中...`。
- 与其他内容间隔 16dp。

### 7.5 加载/错误

加载：

- 垂直 48dp，水平居中。
- 20×20dp 进度，`strokeWidth: 2`，`primary`。
- 12dp。
- 文案 `正在加载个人信息...`，`bodyMedium`，`onSurfaceVariant`。

错误：

- 垂直 32dp。
- 标题 `个人信息加载失败`，`titleMedium`，`w600`。
- 6dp。
- 错误消息居中，`bodyMedium`，`onSurfaceVariant`。
- 4dp。
- `TextButton.icon`：`Icons.refresh` + `重试`。

---

## 8. 资源选择器

### 8.1 通用页面骨架

所有选择器使用：

```text
Scaffold
├── AppBar
│   ├── leading: Icons.arrow_back
│   └── title
└── SafeArea
    └── Column
        ├── 可选：当前层级标题
        ├── 可选：搜索框
        └── Expanded 列表
```

- AppBar 使用 Material 3 默认高度/背景。
- 返回按钮 tooltip：`返回`。
- 列表左右内边距 16dp。
- 列表底部 24dp。
- 列表项 `contentPadding: EdgeInsets.zero`。
- 列表项之间 `Divider(height: 1)`。
- 列表项尾部统一 `Icons.chevron_right`。

### 8.2 题库选择

截图：`07-bank-units.png`、`08-bank-categories.png`

AppBar 标题：`选择题库`

层级：

```text
单位 -> 分类/年份 -> 题库
```

#### 单位层

- 可选：当前单位标题，`bodySmall`，`onSurfaceVariant`，左右 16dp，顶部 8dp。
- 列表项：
  - 标题：单位名
  - trailing：chevron
  - 点击进入分类层。
- 空状态：`当前账号没有可选单位`。
- 错误：居中错误文本 + 12dp + `OutlinedButton('重试')`，四周 24dp。
- 加载：居中 `CircularProgressIndicator`。

#### 分类层

- 当前单位标题显示在列表上方。
- 列表项：
  - 标题：分类名
  - 副标题：年份（如果有）
  - trailing：chevron
  - 点击进入下一层或题库。
- 空状态：`该单位下没有分类`。

#### 题库层

- 顶部显示当前分类名称，`bodySmall`，`onSurfaceVariant`。
- 搜索框：
  - hint `搜索题库名称`
  - prefix `Icons.search`
  - 左右 16dp，顶部 8dp，底部 4dp。
- 列表项：
  - 标题：题库名，最多 2 行省略。
  - 副标题：`单位名 · N 题`，空缺项省略。
  - trailing：chevron。
  - 点击选择并返回。
- 空状态：`该分类下没有题库`。

### 8.3 试卷选择

AppBar 标题：`选择试卷`

- 顶部显示目标题库名称：`titleMedium`，`w600`，`onSurface`。
- 题库名下方 4dp：
  - `仅显示当前题库下可以开始的试卷。`
  - `bodySmall`，`onSurfaceVariant`。
- 8dp 后列表。
- 列表项：
  - 标题：试卷名，最多 2 行省略。
  - 副标题：`编号 <number> · 总分 <totalScore> · 及格 <passingGrade>`。
  - trailing：chevron。
- 空状态：`该题库下没有可用试卷`。
- 加载：`正在读取可用试卷...` + CircularProgressIndicator。
- 错误：错误消息 + `重试` OutlinedButton。

### 8.4 知识文章选择

AppBar 标题：`选择文章`

层级：

```text
一级分类 -> 子分类 -> 文章
```

- 当前分类标题显示在顶部，`bodySmall`，`onSurfaceVariant`。
- 文章层显示搜索框：
  - hint `搜索文章标题`
  - prefix `Icons.search`
- 分类列表项：
  - 标题：分类名。
  - trailing：chevron。
- 文章列表项：
  - 标题：文章标题，最多 2 行省略。
  - 副标题：`图文 · 分类名` 或 `PDF · 分类名`。
  - trailing：chevron。
- 空状态：`没有可选分类` / `该分类下没有文章`。
- 加载：居中 `CircularProgressIndicator`，无额外文案。
- 错误：错误消息 + 重试按钮。

---

## 9. 公共组件规格

### 9.1 Tonal 分组块

```text
Container
  color: surfaceContainerLow
  borderRadius: 20
  padding: 16
```

- 不使用 Card、elevation、border。
- 同一页面内分组块间距 16dp。

### 9.2 主操作按钮

- 主操作：FilledButton。
- 次级操作：FilledButton.tonal / OutlinedButton / TextButton。
- 不使用自定义渐变、阴影。
- 按钮文字使用 Material 3 默认 label 样式；需要强调时 `w600`。
- 所有按钮最小高度 48dp（登录按钮 50dp）。

### 9.3 状态标签

- 使用 `labelMedium`。
- 成功/已匹配/已配置：`primary`。
- 需要操作：`tertiary`。
- 未配置：`onSurfaceVariant`。
- 失败：`error`。
- 不加重背景色，不加大写。

### 9.4 加载状态

- 小型内联加载：20×20dp，`strokeWidth: 2`，`primary`。
- 页面级加载：居中 CircularProgressIndicator。
- 加载文案使用 `bodyMedium` 或 `bodySmall`，`onSurfaceVariant`。

### 9.5 空状态

- 居中。
- 文案 `bodyMedium`，`onSurfaceVariant`。
- 不显示插画，不使用大图标。

### 9.6 弹窗

- 使用 Material 3 AlertDialog。
- 标题使用默认 titleLarge。
- 内容使用默认 bodyMedium。
- 操作按钮：
  - 取消：TextButton
  - 确认：FilledButton
- 危险操作使用 error 色（退出登录）。

### 9.7 Bottom Sheet

- 使用 Material 3 默认背景和顶部圆角。
- 顶部显示 drag handle。
- 可滚动内容使用 ListView / DraggableScrollableSheet。
- 内容左右 20dp。

### 9.8 内联提示（替代 SnackBar）

用于表单校验与提交失败，原则是「错误出现在出错的位置」：

- 字段级：`InputDecoration.errorText`，输入框描边转 `error`，提示文字 `bodySmall`。
- 表单级：登录按钮等主操作上方，`errorContainer` 背景、`onErrorContainer` 文字、`Icons.error_outline`，12dp 圆角，内边距 12×10。
- 语气：错误 / 说明 / 成功分别使用 `errorContainer`、`secondaryContainer`、`primaryContainer`。
- 无障碍：容器使用 `Semantics(liveRegion: true)`，读屏器播报。
- 不使用 SnackBar：底部浮层离错误位置远、会被键盘遮挡、会自动消失，且容易被忽略。
- 成功类反馈（保存成功等）同样使用内联提示，不弹浮层。

---

## 10. 页面状态矩阵

| 页面 | 正常 | 加载 | 空 | 失败 |
|---|---|---|---|---|
| 登录 | 表单可编辑 | 输入禁用、按钮转圈 | — | 字段内联错误 / 按钮上方内联提示 |
| 首页 | 积分+任务分组 | 积分摘要/任务加载 | 暂无任务 | 每日任务加载失败 + 重试 |
| 策略 | 配置分组 | 当前题库/策略加载 | 未配置 | 查询失败/加载失败 |
| 自动化 | WebView+控制条 | 页面加载遮罩 | 未配置任务 | 状态条错误色 + 日志 |
| 我的 | 资料+退出 | 个人信息加载 | 未填写 | 个人信息加载失败 + 重试 |
| 题库选择 | 分级列表 | 居中加载 | 没有可选单位/分类/题库 | 错误+重试 |
| 试卷选择 | 试卷列表 | 读取试卷 | 没有可用试卷 | 错误+重试 |
| 文章选择 | 分类/文章列表 | 读取文章 | 没有可选分类/文章 | 错误+重试 |

---

## 11. 必须固定的文案

```text
Prime Learn
欢迎回来，请登录你的账号
身份证号
请输入 18 位身份证号
密码
请输入登录密码
记住账号
登 录
安全登录 · 仅限授权账号
© 2026 Prime Learn · 保留所有权利

首页
自动化
策略
我的

每日任务
已完成
未完成
暂不执行
暂不执行 · 不获取积分
当前题库加载中...
当前题库获取失败
正在加载每日任务...
每日任务加载失败
重试

当前平台题库
刷新当前题库
练习策略
考试策略
知识学习策略
目标题库
目标试卷
目标文章
目标分类
阅读类型
图文
PDF
选择
已匹配
需要切换
未配置
已配置
查询失败
有未保存修改
已保存
保存修改
保存中...
策略只保存执行目标；任务执行请在自动化页操作。

自动化
正在读取策略...
策略读取失败
正在执行...
任务已就绪
未配置任务
自动化控制
任务使用已保存的策略，执行结果会写入日志。
手机考试
模拟考试
按策略完成知识学习
正在完成知识学习...
执行日志
暂无执行记录
暂无日志
开始手机考试
开始模拟考试
完成知识学习
取消
开始

个人信息
工号
姓名
身份证号
工作单位
联系方式
家庭地址
未填写
未填写姓名
退出登录
退出中...
正在加载个人信息...
个人信息加载失败

选择题库
搜索题库名称
该单位下没有分类
该分类下没有题库
当前账号没有可选单位

选择试卷
仅显示当前题库下可以开始的试卷。
该题库下没有可用试卷

选择文章
搜索文章标题
没有可选分类
该分类下没有文章
```

---

## 12. 复刻顺序

1. 建立 Material 3 主题：seed `#2196F3`，亮/暗色跟随系统。
2. 实现 64dp NavigationBar 和四个 Tab。
3. 实现通用组件：
   - Tonal 分组块（radius 20）
   - 输入框（radius 12）
   - 主按钮/次级按钮
   - 状态标签
   - 列表行/chevron
   - Bottom Sheet / AlertDialog
4. 登录页。
5. 首页。
6. 策略页。
7. 自动化页固定控制条 + 控制面板 + 日志面板。
8. 我的页。
9. 三个资源选择器。
10. 按第 10 节逐项做状态页。
11. 按截图做像素级对照。

---

## 13. 验收标准

- 无 Card 阴影；主内容均为 20dp 圆角色块。
- 页面左右边距 20dp；登录页 24dp。
- 底部导航 4 个 Tab，图标与选中图标严格对应。
- 首页任务有“每日任务”和 `x/y 已完成` 标题行。
- 首页任务分为可执行与“暂不执行 · 不获取积分”两组。
- 策略页没有页面大标题，只有当前题库和三个策略分组。
- 策略页有“有未保存修改/已保存”状态，保存按钮文字随之变化。
- 自动化页 WebView 不被固定控制面板覆盖；控制条占固定 64dp。
- 自动化控制通过可拖拽 Bottom Sheet 打开，初始 55%，范围 35%–90%。
- 执行日志使用时间 + 级别图标 + 可复制消息。
- 登录页使用 FlutterLogo，无外层方框。
- 所有列表行尾部使用 chevron；所有分组状态使用主题语义色。
- 明暗主题下均无硬编码颜色。
