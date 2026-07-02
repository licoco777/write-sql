---
layer: D
title: "rh_tc_value 套餐价值档次 分段字典"
field_name: "rh_tc_value"
applicable_tables: ["ads_yz_xsb_tjsr_skj_list_db", "dwm_yz_tb_comm_cm_all_final"]
---

# rh_tc_value 套餐价值档次 分段字典

> **字段含义**：套餐积分/融合套餐价值加分。用于按价值档次分段统计收入、入网等指标。
>
> **字段类型**：`decimal(12,2)`（069/101 均有）。
>
> **来源**：业务主表自带，无需补表。

## 分段规则

> 用户说"套餐价值档次"时，按以下 CASE WHEN 对 `rh_tc_value` 分段。

```sql
case
    when rh_tc_value < 0   then '(-∞,0)'
    when rh_tc_value >= 0  and rh_tc_value < 59  then '[0,59)'
    when rh_tc_value >= 59 and rh_tc_value < 79  then '[59,79)'
    when rh_tc_value >= 79 and rh_tc_value < 129 then '[79,129)'
    when rh_tc_value >= 129 and rh_tc_value < 199 then '[129,199)'
    when rh_tc_value >= 199 and rh_tc_value < 299 then '[199,299)'
    when rh_tc_value >= 299 and rh_tc_value < 399 then '[299,399)'
    when rh_tc_value >= 399 and rh_tc_value < 499 then '[399,499)'
    when rh_tc_value >= 499 and rh_tc_value < 599 then '[499,599)'
    when rh_tc_value >= 599 and rh_tc_value < 699 then '[599,699)'
    when rh_tc_value >= 699 then '[699,+∞)'
    else '其他'
end as rh_value_type
```

## 档次清单

| 档次 | 区间 | 说明 |
|------|------|------|
| (-∞,0) | `rh_tc_value < 0` | 负值（异常/退费） |
| [0,59) | `0 ≤ rh_tc_value < 59` | 低价值 |
| [59,79) | `59 ≤ rh_tc_value < 79` | |
| [79,129) | `79 ≤ rh_tc_value < 129` | |
| [129,199) | `129 ≤ rh_tc_value < 199` | 129+ 入门 |
| [199,299) | `199 ≤ rh_tc_value < 299` | |
| [299,399) | `299 ≤ rh_tc_value < 399` | |
| [399,499) | `399 ≤ rh_tc_value < 499` | |
| [499,599) | `499 ≤ rh_tc_value < 599` | |
| [599,699) | `599 ≤ rh_tc_value < 699` | |
| [699,+∞) | `rh_tc_value ≥ 699` | 高价值 |
| 其他 | `rh_tc_value IS NULL` | 未知 |

## 使用模板

```sql
-- 在 SELECT 和 GROUP BY 中同时使用（Hive 不支持 GROUP BY 别名）
select
    ...
    case
        when rh_tc_value < 0   then '(-∞,0)'
        ...
        else '其他'
    end as rh_value_type,
    sum(fee_all) as total_fee
from ads_yz_xsb_tjsr_skj_list_db
where ...
group by
    ...,
    case
        when rh_tc_value < 0   then '(-∞,0)'
        ...
        else '其他'
    end;
```