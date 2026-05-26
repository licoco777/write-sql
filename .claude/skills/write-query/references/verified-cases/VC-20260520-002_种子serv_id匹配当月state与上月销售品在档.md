# 种子 serv_id 匹配当月 state 与上月销售品在档

来源：write-query 交互验证（拆机手续费种子表 + 双账期状态/套餐）

## 适用

- 用户提供 **`serv_id` 种子清单表**，要对每个服务打标。
- 查 **当月服务状态**（`state`，输出中文名）。
- 查 **上月某销售品是否在档**（`prod_offer_code`），并带出 **销售品名称**。
- 当月与上月 **`par_month_id` 不同**（如 202605 / 202604）。

## 不适用

- 销售品 **订购/互换动作** → 041 优惠订单表。
- 仅统计在网/出账规模（`is_cancel_user`、`is_cz` 等口径标签）且用户未提「状态」→ 按指标口径，不默认替换为 `state`。
- 同一账期内同时查状态 + 销售品在档且仅写一个月份 → 需拆成两个 `par_month_id` 或确认口径。

## 主表与口径

- **驱动表**：用户种子表（如 `ads_zqzw_chaiji_sxf_20260517`），键 `serv_id`。
- **当月状态**：069 全业务资料表 `dwm_yz_tb_comm_cm_all_final`，`par_month_id = 当月`，字段 **`state`**（码值）。
- **状态中文名**：字典 `dws_crm_cfguse.dws_attr_value`，`attr_id = '4000000201'`，`attr_value = state`，取 **`attr_value_name`**。
- **上月销售品在档**：014 优惠资料表 `ads_yz_rpt_comm_cm_msdisc_final`，`par_month_id = 上月`，`prod_offer_code = 指定编码`。
- **有没有套餐**：014 在档（非 041 动作）；输出 `has_offer` 0/1 标记列。
- **套餐名称**：014.`prod_offer_name`（与编码同行；无匹配套餐时为 NULL）。

## 字段映射

| 需求字段 | 来源 |
|----------|------|
| serv_id | 种子表 |
| 状态码 | 069.`state`（当月 `par_month_id`） |
| 状态中文 | 字典.`attr_value_name`（`attr_id='4000000201'`） |
| 上月是否有指定销售品 | `CASE WHEN 014 命中 THEN 1 ELSE 0 END` |
| 销售品名称 | 014.`prod_offer_name` |

## 补表

| 缺口 | 补表 | JOIN 键 |
|------|------|---------|
| state 中文 | `dws_crm_cfguse.dws_attr_value` | `attr_id='4000000201'` AND `attr_value = cast(state as string)` |
| 上月销售品 + 名称 | 014 优惠资料表 | `serv_id` + `par_month_id=上月` + `prod_offer_code`；先 `GROUP BY serv_id` 防放大 |

## SQL 编排

```sql
WITH last_month_offer AS (
    SELECT serv_id, max(prod_offer_name) AS prod_offer_name
    FROM ads_yz_rpt_comm_cm_msdisc_final
    WHERE par_month_id = 202604
      AND prod_offer_code = 'YD0202-556'
    GROUP BY serv_id
)
SELECT
    s.serv_id,
    cm.state AS state_code,
    av.attr_value_name AS state_name,
    CASE WHEN o.serv_id IS NOT NULL THEN 1 ELSE 0 END AS has_offer_last_month,
    o.prod_offer_name
FROM ads_zqzw_chaiji_sxf_20260517 s
LEFT JOIN dwm_yz_tb_comm_cm_all_final cm
    ON s.serv_id = cm.serv_id AND cm.par_month_id = 202605
LEFT JOIN dws_crm_cfguse.dws_attr_value av
    ON av.attr_id = '4000000201'
   AND av.attr_value = cast(cm.state AS string)
LEFT JOIN last_month_offer o ON s.serv_id = o.serv_id;
```

### 注意

- **过程表可追溯**：若需求方要改中间结果（如上月销售品范围），将 `WITH last_month_offer` 改为 `drop/create tmp_*` CTAS 再 JOIN，见 `VC-20260520-001` 与 `RULES.md`「SQL 编排模式」。
- 种子表驱动用 **LEFT JOIN**，保证清单内每个 `serv_id` 都有一行。
- 014 一对多：务必子查询聚合后再 JOIN。
- `serv_id` 类型不一致时对 JOIN 做 `cast`。
