---
layer: D
title: "due_income_code SR科目编码 字典"
field_name: "due_income_code"
applicable_tables: ["dwm_srhx_src_income_list_mon", "ads_yz_xsb_tjsr_skj_list_db"]
---

# due_income_code SR科目编码 字典

> **字段含义**：SR 科目编码，用于科目级收入分类。关联 048 全量科目级收入表、101 台阶收入清单。
>
> **字段类型**：`string`。
>
> **来源**：业务主表自带，无需补表。

## 已知科目编码

### 互联网专线

| 编码前缀 | 含义 | 过滤写法 |
|----------|------|----------|
| `SR012202%` | 互联网专线（一类） | `due_income_code like 'SR012202%'` |
| `SR022202%` | 互联网专线（二类） | `due_income_code like 'SR022202%'` |
| `SR032202%` | 互联网专线（三类） | `due_income_code like 'SR032202%'` |

> 用户说"互联网专线科目收入"时，三个前缀 OR 合并。

## 使用模板

```sql
-- 互联网专线科目收入
select month_id, sum(fee_all) as hlwzx_fee
from dwm_srhx_src_income_list_mon
where month_id between ${start_month} and ${end_month}
    and branch_name = '${branch_name}'
    and (due_income_code like 'SR012202%'
        or due_income_code like 'SR022202%'
        or due_income_code like 'SR032202%')
group by month_id;
```

## 注意

- 048 全量科目级收入表分区字段是 `month_id`，不是 `par_month_id`。
- 101 台阶收入清单分区字段是 `par_month_id`。
- 未收录的科目编码 → 问用户或查生产表 `SELECT DISTINCT due_income_code, due_income_name FROM dwm_srhx_src_income_list_mon WHERE month_id = ${latest_month}`。