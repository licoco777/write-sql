---
metric_id: "M-BASIC-BB-003"
metric_name: "主宽到达数"
domain: "基本面"
category: "宽带"
period: "日/月/年"
cdap_flow: "日生产"
owners:
  business: "谢蕴秀"
  technical: "陈浩南"
source_file: "宽带.md"
---

# [M-BASIC-BB-003] 主宽到达数

## 指标属性

| 字段 | 值 |
|------|-----|
| 业务板块 | 基本面 |
| 业务分类 | 宽带 |
| 统计周期 | 日/月/年 |
| 业务口径责任人 | 谢蕴秀 |
| 技术口径责任人 | 陈浩南 |
| CDAP生产流程 | 日生产 |

## 业务口径

主宽到达数从 069 全业务资料表取数，按账期状态统计当月出账且未拆机的普通宽带。

过滤口径：

- `par_month_id = ${month_id}`
- `is_cancel_user = 0`
- `prod_type = 40`
- `kd_desc = '普通宽带'`
- `is_cz = 1`

## 技术口径（SQL）

```sql
SELECT COUNT(DISTINCT serv_id) AS main_broadband_arrive_cnt
FROM dwm_yz_tb_comm_cm_all_final
WHERE par_month_id = ${month_id}
  AND is_cancel_user = 0
  AND prod_type = 40
  AND kd_desc = '普通宽带'
  AND is_cz = 1
;
```

## 参数化建议

- 将固定月份参数化（如 `par_month_id`、`month_id`、`day_id`）。
- 若涉及日期范围，建议统一为 `${start_day}` / `${end_day}`。

## 依赖说明

- 相关主表：`../../tables/069_全业务资料表.md`。
- 来源沉淀：`CDAP自助分析常用统计语句分享.docx` 的“统计主宽到达数”脚本。
