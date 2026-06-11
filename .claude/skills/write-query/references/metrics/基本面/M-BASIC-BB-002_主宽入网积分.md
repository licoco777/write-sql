---
metric_id: "M-BASIC-BB-002"
metric_name: "主宽入网积分"
domain: "基本面"
category: "宽带"
period: "日/月/年"
cdap_flow: "全业务资料表"
owners:
  business: "谢蕴秀"
  technical: "陈浩南"
source_file: "宽带.md"
---

# [M-BASIC-BB-002] 主宽入网积分

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

主宽入网积分从 069 全业务资料表（生产日表 `dwm_yz_tb_comm_cm_all_final`）取数，度量为 `SUM(jz_points)`。

过滤口径：

- `par_month_id = ${month_id}`
- `kd_desc = '普通宽带'`
- `is_new_user = 1`
- `date_format(open_date, 'yyyyMM') = ${month_id}`
- `prod_type = 40`

与 [M-BASIC-BB-001 主宽入网数](M-BASIC-BB-001_主宽入网数.md) 的对象筛选一致（含 `prod_type = 40`）；时间口径同 BB-001：口语「竣工」→ **`open_date`**。本指标度量为 **`SUM(jz_points)`**，勿与 BB-001 的 `COUNT(serv_id)` 混用。

## 技术口径（SQL）

```sql
SELECT SUM(jz_points) AS main_broadband_new_user_jz_points_sum
FROM dwm_yz_tb_comm_cm_all_final
WHERE par_month_id = ${month_id}
  AND kd_desc = '普通宽带'
  AND is_new_user = 1
  AND date_format(open_date, 'yyyyMM') = '${month_id}'
  AND prod_type = 40
;
```

## 参数化建议

- 将固定月份参数化（如 `par_month_id`、`month_id`、`day_id`）。
- 若涉及日期范围，建议统一为 `${start_day}` / `${end_day}`。
- 历史账期需月表时，按 `069_全业务资料表.md` 日/月表选择规则替换 `FROM` 表名。

## 依赖说明

- 相关主表：`../../tables/069_全业务资料表.md`。
- 积分字段：`jz_points`（当月价值积分，号码自身价值积分分摊后）。
- 旧口径 `view_ads_yz_kd_new_list` / `ads_yz_kd_new_list`（006 宽带新装清单）不再使用。
