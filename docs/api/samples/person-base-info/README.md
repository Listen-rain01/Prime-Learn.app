# 个人信息样本

对应接口：`POST /PersonWap/MyBaseInfo`（`pid=Esdt(pid)&sstype=0`）

## 状态

**已采集**：2026-10-28，经账号持有人授权，用真实会话请求；原始响应约 15.5KB HTML。

| 文件 | 内容 |
|---|---|
| `response.json` | 从 HTML 中提取的 `vData`，仅保留白名单字段，全部脱敏 |
| `meta.json` | 请求形态、采集时间、观察结论 |

证据级别为 `observed`：实现者侧实测，尚未独立复核。

## 复采方式

```bash
$env:PL_ID='...'; $env:PL_PWD='...'; dart run tool/live_probe.dart
```

## 脱敏红线（§9.4）

- 姓名、身份证号、手机号、家庭地址、单位名称替换为占位符；
- GUID 替换为 `<guid>`，图片路径替换为 `<path>`；
- 不保存 Cookie、pid 明文或任何有效凭据。
