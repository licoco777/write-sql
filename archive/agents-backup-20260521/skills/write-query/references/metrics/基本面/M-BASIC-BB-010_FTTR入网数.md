---
metric_id: "M-BASIC-BB-010"
metric_name: "FTTR入网数"
domain: "基本面"
category: "宽带"
period: "日/月/年"
cdap_flow: "FTTR报表"
owners:
  business: "谢钊铭"
  technical: "陈浩南"
source_file: "宽带.md"
---

# [M-BASIC-BB-010] FTTR入网数

## 指标属性

| 字段 | 值 |
|------|-----|
| 业务板块 | 基本面 |
| 业务分类 | 宽带 |
| 统计周期 | 日/月/年 |
| 业务口径责任人 | 谢钊铭 |
| 技术口径责任人 | 陈浩南 |
| CDAP生产流程 | FTTR报表 |

## 业务口径

FTTR 入网数从 FTTR 清单取数，按统计月份和创建日期限定，常用统计对象为设备序列号 `eqpt_sn`。

过滤口径：

- `par_month_id = ${month_id}`
- `create_date between ${start_day} and ${end_day}`，或 `substr(create_date,1,6)=par_month_id`
- 分局/县分按 `subst_name` 过滤

## 技术口径（SQL）

```sql
SELECT COUNT(DISTINCT eqpt_sn) AS fttr_new_cnt
FROM dwm_fttr_list
WHERE par_month_id = ${month_id}
  AND create_date >= '${start_day}'
  AND create_date <= '${end_day}'
;
```

## 参数化建议

- 将固定月份参数化（如 `par_month_id`、`month_id`、`day_id`）。
- 若涉及日期范围，建议统一为 `${start_day}` / `${end_day}`。

## 依赖说明

- 相关主表：`../../tables/002_fttr清单.md`。
- 来源沉淀：`CDAP自助分析常用统计语句分享.docx` 的 FTTR 揽装脚本。
