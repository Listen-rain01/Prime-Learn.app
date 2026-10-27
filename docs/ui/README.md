# UI 基线

> 2026-10-28 起，本项目**不再参照** `F:\Web项目` 的纯 UI 复刻规格。
> 该规格与截图已移至 `docs/ui/archive/`，仅作历史参考，不作为验收依据。

## 当前基线（实现为准）

- Material 3，`colorSchemeSeed: Colors.blue`；亮/暗双主题跟随系统。
- 所有颜色走主题语义令牌（`colorScheme`），不硬编码。
- 分组块：`surfaceContainerLow` + 20dp 圆角、无阴影无边框（`TonalBlock`）。
- 输入框：12dp 圆角、primary 描边、`label` + `hint`、字段级 `errorText`。
- 按钮：主操作 `FilledButton`，登录页高 50dp、12dp 圆角。
- 错误提示：就近内联（字段错误 + 操作按钮上方的 `InlineNotice`），不使用 SnackBar。
- 页面留白：左右 20dp；登录页 24dp。

组件位于 `lib/core/widgets/`：

| 组件 | 用途 |
|---|---|
| `TonalBlock` | 页面主分组块 |
| `AppTextField` | 通用输入框（含错误态） |
| `PrimaryButton` | 主操作按钮（含加载态） |
| `InlineNotice` | 内联提示（错误/说明/成功） |

## 截图

- `docs/screenshot-login.png`：登录页
- `docs/screenshot-login-dark.png`：登录页暗色
- `docs/screenshot-validation.png`：字段内联校验
- `docs/screenshot-home.png`：首页（演示数据）

## 待定：导航结构

底部 Tab 的数量与命名**尚未确定**，因此暂不实现 `StatefulShellRoute`。
在至少两个 Tab 有真实内容之前不搭 shell，避免空壳导航。
