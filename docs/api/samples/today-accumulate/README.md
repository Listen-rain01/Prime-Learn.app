# 今日任务 / 积分样本

对应接口：`GET /AccumulateManger/S_Accumulate/GetPersonTodayAccumulateOne?pid={Esdt(userId)}`

## 状态

**已采集**：2026-10-28，由 `tool/live_probe.dart` 在真实环境执行（账号持有人授权）。

| 文件 | 内容 |
|---|---|
| `response.json` | 原始响应体，GUID 已替换为 `<guid>` |
| `meta.json` | 采集时间、采集人、观察结论 |

证据级别仍为 `observed`：本次是**实现者侧**实测，尚未由独立评审复核，也未做重复采样；
按 AGENTS.md §8.8，Agent 只能提议升级，不能自行标 `verified`。

## 复采方式

```bash
$env:PL_ID='...'; $env:PL_PWD='...'; $env:PL_DUMP='1'
dart run tool/live_probe.dart
Remove-Item Env:PL_ID,Env:PL_PWD,Env:PL_DUMP
```

## 脱敏红线（§9.4）

- Cookie / `ASP.NET_SessionId` 不记录；
- `pid`、`PersonId`、姓名、身份证替换为占位符；
- 不得保存任何有效凭据。
