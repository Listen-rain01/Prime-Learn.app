# 个人积分排行 接口样本

| 项 | 值 |
|---|---|
| 接口 | `POST /ArchiveManger/D_PersonAccumulate/GetAccumulateRankingListOne` |
| 采集时间 | 2026-10-29 |
| 采集人 | 聂伟（用户本人授权登录）|
| 平台版本 | 陕西煤业-素质兴安-全员考试 |
| 采集方式 | 真实环境登录后调用（tool/rank_probe.dart）|

## 请求参数

| 参数 | 类型 | 必填 | 说明 |
|---|---|---|---|
| `pid` | string | 是 | 用户 ID（Esdt 编码）|
| `page` | int | 是 | 页码 |
| `rows` | int | 是 | 每页条数 |
| `begin` | string | 是 | 开始日期 `yyyy-MM-dd`（Esdt 编码）|
| `end` | string | 是 | 结束日期 `yyyy-MM-dd`（Esdt 编码）|
| `type` | int | 是 | `1` 单位榜，`0` 集团榜 |

> 注意：`begin`/`end` 也走 Esdt 编码，`type` 不走。

## 响应结构

`data` 为数组，每条字段：

| 字段 | 类型 | 说明 |
|---|---|---|
| `Cur` | int | 页内序号 |
| `PersonId` | string | 用户 ID |
| `PhotoUrl` | string | 头像地址 |
| `PersonName` | string | 姓名 |
| `DepartmentId` | string | 单位 ID |
| `DepartmentFullName` | string | 单位全路径 |
| `Mark` | null | 恒为 null（积分榜不用）|
| `AllCount` | int | **积分**（个人积分排行的数值）|
| `Ranking` | int | 排名 |

`message` 为管道文本 `姓名|排名|积分`，如 `聂伟|54|1055`，用于顶部「我的排名」。

## 四个 Tab 与参数映射

| Tab | type | 区间 |
|---|---|---|
| 本单位周排行 | `1` | 周一 ~ 周日 |
| 本单位月排行 | `1` | 月初 ~ 月末 |
| 集团周排行 | `0` | 周一 ~ 周日 |
| 集团月排行 | `0` | 月初 ~ 月末 |

## 脱敏说明

GUID、用户 ID、头像路径已替换为 `<guid>`；姓名保留（榜单本身公开可见）。
