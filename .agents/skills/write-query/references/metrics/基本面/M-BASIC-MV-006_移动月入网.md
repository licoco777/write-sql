---
metric_id: "M-BASIC-MV-006"
metric_name: "移动月入网"
domain: "基本面"
category: "移动"
period: "月"
cdap_flow: "日生产"
owners:
  business: "陈昕博"
  technical: "吉敏"
source_file: "移动.md"
---

# [M-BASIC-MV-006] 移动月入网

## 指标属性

| 字段 | 值 |
|------|-----|
| 业务板块 | 基本面 |
| 业务分类 | 移动 |
| 统计周期 | 月 |
| 业务口径责任人 | 陈昕博 |
| 技术口径责任人 | 吉敏 |
| CDAP生产流程 | 日生产 |

## 业务口径

移动月入网从 069 全业务资料表取数，按分区月和 `open_date` 业务月双重限定。

过滤口径：

- `par_month_id = ${month_id}`
- `is_new_user = 1`
- `date_format(open_date,'yyyyMM') = ${month_id}`
- `prod_type = 30`

## 技术口径（SQL）

```sql
SELECT count(serv_id) 
FROM dwm_yz_tb_comm_cm_all_final 
WHERE par_month_id = ${month_id}
  AND is_new_user = 1
  AND date_format(open_date,'yyyyMM') = '${month_id}'
  AND prod_type = 30
;
```

## 参数化建议

- 将固定月份参数化（如 `par_month_id`、`month_id`、`day_id`）。
- 若涉及日期范围，建议统一为 `${start_day}` / `${end_day}`。

## 依赖说明

- 相关主表：`../../tables/069_全业务资料表.md`。
- 来源沉淀：`CDAP自助分析常用统计语句分享.docx` 的移动入网汇总脚本。
