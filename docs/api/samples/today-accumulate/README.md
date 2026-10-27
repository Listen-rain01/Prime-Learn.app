# 今日任务 / 积分样本

对应接口：`GET /AccumulateManger/S_Accumulate/GetPersonTodayAccumulateOne?pid={Esdt(userId)}`

## 状态

**待采集**。`docs/api/evidence-register.md` 中该接口当前为 `observed`，
依据是 `docs/api/积分查询接口文档.md` 的真实环境实测记录；尚未有落盘样本，也没有独立复核。

## 采集要求（AGENTS.md §8.8）

目录内容需包含：

| 文件 | 说明 |
|---|---|
| `request.txt` | 完整请求（URL、方法、Cookie 用占位符） |
| `response.json` | 原始响应体 |
| `meta.json` | 采集时间、采集人、平台版本、账号脱敏说明 |

`meta.json` 模板：

```json
{
  "endpoint": "/AccumulateManger/S_Accumulate/GetPersonTodayAccumulateOne",
  "collectedAt": "<ISO 8601>",
  "collectedBy": "<采集人>",
  "platformVersion": "<平台版本/部署标识>",
  "account": "身份证后 4 位或占位符",
  "note": "Cookie、pid、PersonId 已脱敏"
}
```

## 脱敏红线（§9.4）

- Cookie / `ASP.NET_SessionId` 换成 `<cookie>`；
- `pid`、`PersonId`、姓名、身份证替换为占位符；
- 不得保存任何有效凭据。
