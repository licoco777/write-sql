---
layer: D
title: "字段缺口补表规则"
---

# 字段缺口补表规则

> 用途：主表已经选定后，用于判断用户要求字段是否需要补维表或辅助表。原则是主表字段够用就直接取，只有主表缺字段或只有 ID 没有名称时才补表。

## 使用顺序

1. 先读主表 `tables/*.md`，确认字段是否已存在。
2. 主表有可直接输出的字段时，不补表。
3. 主表只有 ID、编码或缺名称时，按下表补维表。
4. 主表完全缺失该业务字段时，再补辅助事实表或明细表。
5. 补表后检查 JOIN 键、维表过滤、是否会放大行数。

## 通用补表规则

| 字段需求 | 主表常见字段 | 何时补表 | 补表 | JOIN/过滤规则 | 注意事项 |
|----------|--------------|----------|------|---------------|----------|
| 直销客户编码 / 客户编码类字段 | `ccust_id`、`cust_code`、`cust_id`、`cust_nbr` | 用户术语和主表字段语义未对齐时，不要急着补表 | - | 先回主表字段盘点，列出候选字段后再定 | 最容易把直销客户编码、直销客户标识、产权客户编码混用；不要先猜字段名 |
| 销售品编码/名称 | `prod_offer_id`、`kd_prod_offer_id` | 主表只有销售品 ID，缺编码/名称 | 销售品维表 `dws_crm_cfguse.dws_offer` | `主表.prod_offer_id = offer.offer_id` 或按宽带套餐字段关联；`offer.city_id=200` | 全省维表必须加 `city_id=200` |
| 产品名称 | `prod_id` | 主表只有产品 ID，缺产品名称 | 产品维表 `dws_product` | `主表.prod_id = product.prod_id`，必要时加城市过滤 | 先确认产品维表字段名 |
| 划小县分/营服名称 | `subst_id`、`branch_id`、`subst_name`、`branch_name` | 主表已有 `subst_name/branch_name` 时不补；只有 ID 时补 | 机构维表 `dwd_yz_dim_org` | 用 `org_id` 关联；县分/分局 `levs=3`，营服 `levs=4` | 不要用维表里的 `subst_id/branch_id` 当机构自身 ID |
| 落地县分/营服名称 | `std_subst_id`、`std_branch_id`、`std_subst_name`、`std_branch_name` | 主表已有名称时不补；只有 ID 时补 | 机构维表 `dwd_yz_dim_org` | 用 `org_id` 关联；按层级限制 | 落地局向不同于划小局向 |
| 订单编码 / 订单状态 / 受理时间 / 协销人 | 069 常见字段 `subs_id`、`subs_code`、`subs_stat_date`、`act_date`、`staff_id`；协销字段常缺 | 主表没有订单事实字段，或协销字段缺失时补 | 040 全业务号码订单表；协销专表 042 / 043 | 优先按 `subs_id` 关联 040；主表无 `subs_id` 时再看 `serv_id`；协销按 `serv_id` 或订单键关联，必要时先去重 | 主表能取的字段先取，不要为一个协销字段把整单都改走订单表 |
| 揽装人/销售员姓名 | `sales_id`、`sales_code`、`sales_name`、`sales_man_name`、`staff_id` | 主表没有姓名或工号不完整时补 | 揽装网点/销售员表 `dwd_yz_sales_man_outlers_final` 或表文档指定销售员维表 | 按主表字段语义选择 `sales_id/staff_id/sales_code` 等键 | 先确认是揽装人、受理人还是协销人 |
| 揽装机构 | `salestaff_subst_id`、`salestaff_branch_id`、`salestaff_org_id` | 主表只有机构 ID，缺名称时补 | 机构维表 `dwd_yz_dim_org` | `salestaff_subst_id = org_id AND levs=3`；`salestaff_branch_id = org_id AND levs=4` | 多次 JOIN 时检查每个 ON 使用本次 JOIN 别名 |
| 客户名称 | `cust_name`、`cust_name_tm`、`cust_id` | 主表有可用客户名时不补；脱敏/不脱敏不满足时再补 | 客户表或全业务资料表，按业务场景定 | 优先用主表自带客户名；需要跨表时按 `serv_id/cust_id` 谨慎关联 | 069 的 `cust_name_tm` 是脱敏客户名 |
| 状态/动作含义 | `subs_stat`、`action_id`、`subs_stat_reason` | 需要中文解释或过滤码值时 | 字典文件 `dictionaries/{field}.md` | 不 JOIN，直接查字典后写码值 | SQL WHERE 不写中文状态 |
| **服务状态 `state`（069）** | **`state`** | 用户说「状态/号码状态」，或输出状态列 | **`dws_crm_cfguse.dws_attr_value`** | `attr_id='4000000201'`，`attr_value=state` → `attr_value_name` | **默认输出码值+中文名**；勿用 `is_cancel_user` 等代替 |

## 场景例子

### 主宽/宽带到达按县分营服

- 主表：069 全业务资料表。
- 用户字段：月份、县分、营服。
- 字段盘点：069 已有 `par_month_id`、`subst_name`、`branch_name`。
- 结论：不补机构维表。

### 销售品发展量明细要销售品名称和揽装机构

- 主表：041 优惠订单表。
- 销售品名称：主表有 `prod_offer_id` 时补销售品维表，且 `city_id=200`。
- 揽装机构：主表有 `salestaff_subst_id/salestaff_branch_id` 时补机构维表。
- 揽装人：主表已有 `sales_code/sales_man_name` 时直接取；缺失时再补销售员表。

### 069 新装/到达/拆机场景要协销人

- 主表：069 全业务资料表。
- 先盘字段：确认 `cust_code/cust_nbr/acc_nbr/open_date/sales_name/staff_id` 等主表字段是否已满足。
- 协销人：069 没有时，优先补 040 全业务号码订单表；若 040 不足，再看 042 号码协销表或 043 订单协销表。
- 结论：先保住 069 主表不变，只为缺口字段补表，不反过来重选主表。

## 回填格式

新增规则时补一行到“通用补表规则”，并尽量写清：

- 用户要的字段。
- 主表常见字段。
- 什么时候不补表。
- 补哪张表。
- JOIN 键和必要过滤。
- 最容易踩的坑。
