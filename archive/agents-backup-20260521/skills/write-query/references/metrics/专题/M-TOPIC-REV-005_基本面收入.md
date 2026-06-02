---
metric_id: "M-TOPIC-REV-005"
metric_name: "基本面收入"
domain: "专题"
category: "收入"
period: "月"
cdap_flow: "（修改结算）YZSR子流程-1-收入生产"
owners:
  business: "田智"
  technical: "黎可馨"
source_file: "收入.md"
---

# [M-TOPIC-REV-005] 基本面收入

## 指标属性

| 字段 | 值 |
|------|-----|
| 业务板块 | 专题 |
| 业务分类 | 收入 |
| 统计周期 | 月 |
| 业务口径责任人 | 田智 |
| 技术口径责任人 | 黎可馨 |
| CDAP生产流程 | （修改结算）YZSR子流程-1-收入生产 |

## 业务口径

基本面收入来自收入生产视图，常用 `sum(fee_fm_new)`；按营服/包区/产品展开时可使用 `branch_id`、`branch_name`、`area_id`、`area_name`、`region_type`、`prod_id`、`prod_name`、`due_type`。

## 技术口径（SQL）

```sql
SELECT sum(fee_fm_new) AS sh,par_month_id
FROM zone_gz.view_分局缩写（th,lw,py....）_ads_srhx_serv_list_mon
WHERE par_month_id = 202501 --统计月份
GROUP BY par_month_id
;
```

## 参数化建议

- 将固定月份参数化（如 `par_month_id`、`month_id`、`day_id`）。
- 若涉及日期范围，建议统一为 `${start_day}` / `${end_day}`。

## 依赖说明

- 相关表请通过 `../../METRIC_INDEX.md` 定位 A 层表文档；技术口径仍以本文件 SQL 为准。
