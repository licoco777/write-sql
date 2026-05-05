---
metric_id: "M-BASIC-BB-001"
metric_name: "主宽入网数"
domain: "基本面"
category: "宽带"
period: "日/月/年"
cdap_flow: "全业务资料表"
owners:
  business: "谢蕴秀"
  technical: "陈浩南"
source_file: "宽带.md"
---

# [M-BASIC-BB-001] 主宽入网数

## 指标属性

| 字段 | 值 |
|------|-----|
| 业务板块 | 基本面 |
| 业务分类 | 宽带 |
| 统计周期 | 日/月/年 |
| 业务口径责任人 | 谢蕴秀 |
| 技术口径责任人 | 陈浩南 |
| CDAP生产流程 | 全业务资料表 |

## 业务口径

主宽入网数从 069 全业务资料表取数。

过滤口径：

- `par_month_id = ${month_id}`
- `kd_desc = '普通宽带'`
- `is_new_user = 1`
- `date_format(open_date, 'yyyyMM') = ${month_id}`
- `prod_type = 30`

## 技术口径（SQL）

```sql
SELECT COUNT(serv_id) AS main_broadband_new_user_cnt
FROM dwm_yz_tb_comm_cm_all_final
WHERE par_month_id = ${month_id}
  AND kd_desc = '普通宽带'
  AND is_new_user = 1
  AND date_format(open_date, 'yyyyMM') = '${month_id}'
  AND prod_type = 30
;
```

## 参数化建议

- 将固定月份参数化（如 `par_month_id`、`month_id`、`day_id`）。
- 若涉及日期范围，建议统一为 `${start_day}` / `${end_day}`。

## 依赖说明

- 相关主表：`../../tables/069_全业务资料表.md`。
- 旧口径 `view_ads_yz_kd_new_list` 不再使用。
