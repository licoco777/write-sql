---
title: "Join Planning / 字段缺口补表"
runtime: true
---

# Join Planning / 字段缺口补表

用于主表已确认、字段盘点完成后。原则：主表字段够用就不补表；只有缺字段、只有 ID/编码无名称、或用户明确要求其它事实字段时才补表。

## 补表决策树

```text
需求字段在主表中语义明确？
  是 -> 直接取主表字段，不补表
  否 -> 主表是否有候选字段但语义不确定？
      是 -> 输出候选字段，让用户确认
      否 -> 主表是否只有 ID/编码、缺名称？
          是 -> 补维表
          否 -> 是否缺订单/协销/受理等事实字段？
              是 -> 补辅助事实表，先说明行数风险
              否 -> 标注“未找到稳定补表路径”，请用户确认
```

## 使用顺序

1. 先读主表 `tables/*.md`，确认字段是否存在。
2. 主表有可直接输出的字段时，不补表。
3. 主表只有 ID、编码或缺名称时，补维表。
4. 主表缺业务事实字段时，补辅助事实表或明细表。
5. 补表后检查 JOIN 键、粒度、必要过滤、是否会放大行数。

## 不补表边界

- 任意产品入网量、新装量、到达量的主表默认保持 069 全业务资料表；不要因为“宽带/移动/固话/视联网”等产品词切到专项清单。
- 只需要状态、动作、原因等码值含义且**仅用于 WHERE 过滤**时，优先读字典 md 写码值，可不 JOIN 字典表。
- **069.`state` 作为输出字段时**：默认交付 **码值 + 中文名**；补 `dws_crm_cfguse.dws_attr_value`（`attr_id='4000000201'`，`attr_value = state` → `attr_value_name`）。
- 只需要销售品、产品、机构、销售员等名称补全时，补维表；不要因此改写主表。
- 需求出现“主体编码 / 主体名称”时，默认指网点经营主体，直接补 112 网点维表；不要全库搜索。
- 只需要订单状态、受理时间、协销人等订单事实字段时，补订单/协销事实表；不要反向把订单表改成主表。
- 主表已有中文名称字段且语义明确时，不补维表。

## 补表规则

| 字段需求 | 主表常见字段 | 何时补表 | 补表 | JOIN / 过滤规则 | 风险 |
|----------|--------------|----------|------|-----------------|------|
| 产品入网量 / 到达量条件 | `prod_type`、`kd_desc`、`is_new_user`、`open_date`、`par_month_id` | 069 字段满足时不补表 | - | 直接在 069 写过滤条件 | 不要按产品词切专项清单 |
| 直销客户编码 / 客户编码 | `ccust_id`、`cust_code`、`cust_id`、`cust_nbr` | 主表候选字段语义无法确认时先不补表 | - | 先列候选字段请用户确认 | 最容易混用直销客户和产权客户 |
| 产权客户编码 | 附件 `cust_name` | 客户实体映射/维护场景中，附件无产权客户编码，需按产权客户名称回填编码 | 108 产权客户全量表 `dws_crm_cust.dws_customer` | `附件.cust_name = 108.cust_name` → `cust_number` | 客户名可能重名或多命中；只作为无编码兜底，必须保留附件行标识；号码/服务明细要客户字段时优先用事实主表自带字段 |
| 直销客户编码 / 直销客户名称 | 产权客户编码 `cust_nbr` | 用户明确要签订/维护直销客户，或通过产权客户找直销客户 | 109 直销客户表 `zone_gz_yz.dws_yz_tb_mo_custgrp_cust_final` | `附件或主表.cust_nbr = 109.cust_nbr` → `ccust_code/ccust_name` | 同一产权客户可能多条直销客户记录；回填前后核对行数；号码/服务明细要直销客户名时优先用 069 或当前事实主表自带字段 |
| 销售品编码 / 名称 | `prod_offer_id`、`kd_prod_offer_id` | 主表只有销售品 ID | 020 销售品维表 | `主表.prod_offer_id = offer.offer_id`；`offer.city_id=200` | 不加城市会错配 |
| 折扣 / 赠金 / 统付金额 / 销售品参数值 | 014 `prod_offer_id`、`serv_id` | 014 能确认在档销售品和到期时间，但缺具体参数值 | 107 销售品参数表 `summary_ods_day_city.rpt_comm_cm_msparam` | `serv_id + prod_offer_id + param_code`；固定 `par_corp_id='200'`；必要时按 `limit_date` 过滤有效期 | `param_code` 必须来自用户、产品口径或已验证案例；不要猜参数编码；不要用参数表判断销售品是否在档 |
| SR科目名称 / SR科目路径 / 收入来源 / 计费收入科目 / 账目项 / 税后收入明细 | 069 `serv_id`、`acc_nbr`、客户/产品属性 | 先按项目、客户名、产品分类、号码清单等条件圈定对象，再要科目级收入明细 | 048 全量科目级收入 `dwm_srhx_src_income_list_mon`；最新月可用 `dwm_srhx_src_income_list` | `069.serv_id = 048.serv_id` 且账期一致；048 账期字段用 `month_id`；取 `due_income_name/due_type/data_src_name/col_income_name/acct_item_type_name/fee_all` | 048 是科目/账目项明细，一户一月可能多行；输出明细不随意去重，汇总时按输出维度 `sum(fee_all)` |
| 产品名称 | `prod_id` | 主表只有产品 ID | 017 产品维表 | `主表.prod_id = product.prod_id` | 先确认产品维表字段名 |
| 主体编码 / 主体名称 | `channel_nbr`、`channel_id`、`channel_name` | 需求要网点归属经营主体 | 112 网点维表 | 优先 `主表.channel_nbr = 112.channel_nbr`；无 `channel_nbr` 再用 `channel_id`；历史账期用 `_mon_final + par_month_id` | 网点维表日表唯一；历史月按账期对齐，避免拿当前网点覆盖历史 |
| 机构名称 / 分局 / 营服名称 | 各业务表中的机构 ID，如 `subst_id`、`branch_id`、`branch_org`、`manage_org` | 主表只有机构 ID 无名称 | 018 机构维表 | `业务表机构ID = 018.org_id`；是否限制 `levs` 看需求和来源 ID 语义 | 018 只负责机构 ID 翻译；不要脱离来源字段语义断定是直销客户、产权客户或号码归属 |
| 落地县分 / 营服名称 | `std_subst_id`、`std_branch_id`、`std_subst_name`、`std_branch_name` | 主表只有 ID 无名称 | 018 机构维表 | `org_id` 关联；按层级限制 | 落地局向不同于划小局向 |
| 订单编码 / 订单状态 / 受理时间 | `subs_id`、`subs_code`、`subs_stat_date`、`act_date` | 主表缺订单事实字段 | 040 全业务号码订单表 | 优先 `subs_id`；无 `subs_id` 再看 `serv_id` | 订单表可能一对多，需去重 |
| 协销人 | 主表通常缺 | 主表无协销字段 | 040；不足再 042/043 协销表 | 按订单键或 `serv_id` 关联，必要时先去重 | 容易放大明细行 |
| 揽装人 / 销售员 | `sales_id`、`sales_code`、`sales_name`、`sales_man_name`、`staff_id` | 主表缺姓名或工号不完整 | 111 揽装人维表；有效网点下有效揽装人用 113 揽装所属表 | 优先用 `staff_id` 关联；历史账期用 `_mon_final + par_month_id` | 先确认是揽装人、受理人还是协销人；`sales_code` 不唯一 |
| 客户经理 CRM 编码 / 11 开头 CRM 工号 | 069 `sales_code` | 用户按号码清单要求补客户经理 CRM 编码、人员账号、人员标识 | 115 员工信息表 `dws_crm_cfguse.dws_staff` | 先按附件号码 + `par_month_id` 在 069 取当前 `serv_id/sales_code`；再 `069.sales_code = staff.staff_code`，`staff.city_id='200'`，`staff.staff_account like '11%'`；员工表按 `status_date desc, update_ts desc` 去重取最新 | 115 可能有历史多版本；必须先去重再 JOIN。这里用 `sales_code` 匹配员工表 `staff_code` 补 CRM 工号，不等同于用 `sales_code` 唯一关联 111 揽装人维表 |
| 合同网点下有效揽装人 / 实际工号数量 | 110 `channel_id`、`billing_cycle_id` | 用户按市场化承包合同、合同编码、合同网点查有效销售人员或实际工号数量 | 113 揽装所属月表 `zone_gz_yz.dwd_yz_sales_man_outlers_mon_final` | `110.channel_id = 113.channel_id` AND `substr(110.billing_cycle_id,1,6)=113.par_month_id`；110 通常加 `shard='200'` 和用户合同清单 | 一个合同账期可能对应多个有效揽装人；实际工号数量用 `count(distinct staff_id)`，不要用 `sales_code` 去重 |
| 网点有效性 | 用户网点清单 `channel_nbr/channel_id` | 诊断网点为什么无号码/收入，或确认网点是否有效 | 112 网点月表 `zone_gz_yz.dwd_yz_sale_outlers_mon_final` | 按 `par_month_id` + `channel_nbr/channel_id` 查；`status_cd='S0X'` 为无效 | 网点无效不会出现在 113 有效对应表里；不要只看 113 缺失就断言网点不存在 |
| 揽装人有效性 | 113 或 111 `staff_id` | 诊断有效网点下是否无有效揽装人，或揽装人是否无效 | 111 揽装人月表 `zone_gz_yz.dwd_yz_sales_man_mon_final` | 用 `staff_id` 关联；`status_cd='S0X'` 为无效；历史账期按 `par_month_id` 对齐 | `sales_code` 不唯一，禁止作为揽装人唯一 JOIN 键 |
| 国际漫游开通权限 / 国漫开通时间 / IMSI | 069 `acc_nbr` | 用户要判断号码是否开通国际漫游权限，或输出开通国漫权限时间、G/L IMSI | 114 国际漫游数据表 `dws_ctg.dws_mktag_download_share_guoman_label` | `069.acc_nbr = 114.msisdn`；按用户指定统计日过滤 `114.yyyymmdd`；`reserv2` 为开通国漫权限时间 | `yyyymmdd` 是日分区/统计日，不是 069 账期；同一号码多日可能多行，未指定日期时需确认取最新还是取区间 |
| 7 级地址 ID / 7 级地址名称 | 069 `serv_addr_id` | 用户给号码/宽带/接入号清单，要回填标准装机地址所属 7 级地址 | 079 地址维表 `zone_gz_yz.dwd_yz_addr_final` | 先按 `附件.acc_nbr = 069.acc_nbr` 且 `069.par_month_id=${month_id}` 取 `serv_id/serv_addr_id`；再 `069.serv_addr_id = cast(addr.id as string)` 取 `addr.addr_id_7`；最后 `cast(addr.addr_id_7 as string)=cast(addr7.id as string)` 且 `addr7.grade=7` 取 `addr7.addr` | `serv_addr_id` 是字符型，地址维表 `id/addr_id_7` 是 decimal；禁止默认 `cast(serv_addr_id as decimal(24,0))`，长地址 ID 可能转换失败或漏数；附件驱动需核对输入/命中/输出行数 |
| 揽装机构 | `salestaff_subst_id`、`salestaff_branch_id` | 主表只有机构 ID | 018 机构维表 | 分局 `salestaff_subst_id = org_id AND levs=3`；营服 `salestaff_branch_id = org_id AND levs=4` | 多次 JOIN 要检查别名 |
| 双线速率 | 069 `speed_value`；033 `speed_value` | 主路径已在 069 时不补表；已补 033 或用户指定双线清单口径时可取 033 | 033 双线全量清单（可选） | 若补 033，按 `acc_nbr + par_month_id` 关联 | 不要只为速率强行补 033；两边均可取时跟随主路径 |
| 双线月租 | 033 `yz_cs` | 069 不提供双线月租或用户明确要月租 | 033 双线全量清单 | `主表.acc_nbr = 033.acc_nbr` 且 `主表.par_month_id = 033.par_month_id` | 033 同号码同月可能多行，必要时按 `load_date` 去重 |
| 客户名称 | `cust_name`、`cust_name_tm`、`cust_id` | 主表脱敏/不脱敏不满足时 | 客户表或 069 | 主表自带优先；跨表时按 `serv_id/cust_id` 谨慎关联 | 069 `cust_name_tm` 是脱敏名 |
| 状态 / 动作含义 | `subs_stat`、`action_id`、`subs_stat_reason` | 需要解释或过滤码值 | `D_experience/dictionaries/{field}.md` | 不 JOIN，直接查码值后写 WHERE | WHERE 禁止中文状态 |
| **服务状态 `state`（069）** | **`state`**（码值） | **输出状态字段或用户说「状态/号码状态」** | **`dws_crm_cfguse.dws_attr_value`**（`tables/015_字典表视图.md`） | `attr_id='4000000201'` AND `attr_value = cast(state as string)` → **`attr_value_name`** | **默认同时输出 `state` 码值与中文名**；勿用 `is_cancel_user` 等代替，除非用户明确要规模口径 |
| **产品规格属性 / 特性值** | 主表通常无 | 用户要主产品 `attr_id` 特性码值；历史/拆机前某月 | **105 特性资料表**（`tables/105_特性资料表.md`） | 月表 `iodata_ods_month_city.tb_pre_cm_attr_all_mon`：`serv_id` + `par_month_id` + `par_corp_id='200'` + `attr_id` | 历史必须用月表；日表 `tb_pre_cm_attr_all` 只在网 |
| **IMSI / 号码 IMSI** | 069 `acc_nbr` | 用户给号码清单，要导出号码对应 IMSI | **105 特性资料表**（`tables/105_特性资料表.md`） | 先按 `069.acc_nbr + 069.par_month_id` 定位 `serv_id`；再 `069.serv_id = 105.serv_id`，过滤 `105.attr_id='200000103'`，输出 `105.attr_value1` | 未给账期需确认号码在网月；历史月用 105 月表并按 `par_month_id` 对齐；不要用 `dws_crm_cust.dws_prod_inst_attr` 或 114 国漫表替代 |
| **附属产品属性 / 附属产品特性值** | 主表通常无 | 用户要附属产品 `attr_id` 特性码值；历史/拆机前某月 | **106 附属产品资料表**（`tables/106_附属产品资料表.md`） | 月表 `iodata_ods_month_city.rpt_comm_cm_subserv_mon`：`serv_id` + `par_month_id` + `par_corp_id='200'` + `attr_id` | 勿与 105 混用；历史必须用月表 |
| **特性值中文名** | `attr_value1`（码值） | 输出产品规格或附属产品属性且要中文 | **`dws_crm_cfguse.dws_attr_value`** | `a.attr_id=b.attr_id` AND `a.attr_value1=b.attr_inner_value` AND `b.city_id='200'` → **`attr_value_name`** | 用 **`attr_inner_value`**，不是 `state` 的 `attr_value`；105/106 通用 |

## 补表确认输出模板

| 缺口字段 | 补表 | JOIN 键 | 补表粒度 | 必要过滤 | 行数风险 |
|----------|------|----------|----------|----------|----------|
|  |  |  |  |  |  |

## JOIN 风险判断

| 风险 | 判断方式 | 处理 |
|------|----------|------|
| 一对一 | 补表 JOIN 键唯一 | 可直接 JOIN |
| 一对多 | 补表同一键可能多行 | 先聚合/去重，或提醒用户会放大明细 |
| 多对多 | 主表和补表键都不唯一 | 不直接 JOIN；先确定粒度或拆成两段 SQL |
| 键不稳定 | 只能用 `serv_id`、模糊日期或名称 | 输出风险，让用户确认 |

## 常见场景

### 069 新装 / 到达 / 拆机场景要协销人

- 主表保持 069。
- 先盘 069 是否已有订单、受理、销售员字段。
- 缺协销人时补 040；040 不足再看 042/043。
- 不因一个协销字段反向重选主表。

### 销售品发展量明细要销售品名称和揽装机构

- 主表 041。
- 销售品名称补 020，必须 `city_id=200`。
- 揽装机构补 018，分局 `levs=3`、营服 `levs=4`。
- 主表已有 `sales_code/sales_man_name` 时不补销售员表。

### 主宽 / 宽带到达按县分营服

- 主表 069。
- 069 已有 `par_month_id`、`subst_name`、`branch_name` 时不补机构维表。

### 号码清单补 7 级地址 ID 和名称

- 主表保持 069，按附件号码和 `par_month_id` 取 `serv_id`、`serv_addr_id`。
- 地址层级补 079 地址维表：`069.serv_addr_id = cast(addr.id as string)`，再用 `addr.addr_id_7` 二次关联 079，`addr7.grade=7` 取 `addr7.addr`。
- 地址 ID 关联统一转字符；不要把 `069.serv_addr_id` 强转为 `decimal(24,0)`。
- 附件驱动时保留附件号码/序号，并核对附件行数、命中行数、输出行数。

### 双线速率和月租

- 双线定义优先在 069 判断：`prod_type2 IN (60,70,71)`，其中 60=互联网专线，70/71=组网专线。
- 双线速率 069 和 033 都可以取。主路径已在 069 时直接取 069 `speed_value`；如果已经补 033 取月租，或用户明确要双线清单口径，也可取 033 `speed_value`。
- 双线月租按需补 033 双线全量清单 `ads_yz_sx_qlyz_list.yz_cs`。
- 补 033 时优先按 `acc_nbr + par_month_id` 关联，并对同号码同月用 `ROW_NUMBER` 去重。

### 任意产品入网量 / 到达量要补产品或销售品名称

- 主表仍保持 069。
- 宽带入网常见口径可直接用 069：`par_month_id`、`kd_desc`、`is_new_user`、`open_date`、`prod_type`。
- 如果只缺产品名称，先看 069 是否已有产品/销售品名称字段；没有再补 017 产品维表或 020 销售品维表。
- 如果补 020 销售品维表，必须加 `city_id=200`。

### 069 入网 / 到达按网点要主体编码、主体名称

- 主表保持 069。
- 主体编码、主体名称固定补 112 网点维表，不全库搜索。
- 优先用 `069.channel_nbr = 112.channel_nbr`；没有 `channel_nbr` 时再考虑 `channel_id`。
- 历史账期补 112 月表时，必须按 `par_month_id` 对齐；当前口径可用日表。

### 市场化承包合同下查有效揽装人 / 实际工号

- 合同、结算账期、网点事实来自 110 结算账单表 `dws_tpss_jszx.dws_settle_bill`，不是 069、订单表或积分表。
- 110 常用字段：`contractno`、`contract_name`、`billing_cycle_id`、`channel_id`、`channel_code`、`channel_name`；广州常用 `shard='200'`。
- 历史账期补有效揽装人时，优先补 113 揽装所属月表 `dwd_yz_sales_man_outlers_mon_final`。
- JOIN：`settle.channel_id = smo.channel_id` AND `substr(settle.billing_cycle_id,1,6)=smo.par_month_id`。
- 明细输出可保留多名有效揽装人；若用户问实际工号数量，优先 `count(distinct smo.staff_id)`。
- `sales_code` 不唯一，不能作为揽装人唯一 JOIN 或去重键。

### 无号码收入网点诊断

- 先用 112 网点月表按 `par_month_id + channel_nbr/channel_id` 判断网点有效性；`status_cd='S0X'` 为无效网点。
- 有效网点若在 113 揽装所属月表同账期无记录，判定为有效网点但无有效揽装人关系。
- 需要细分揽装人无效时，用 111 揽装人月表按 `staff_id` 回查；`status_cd='S0X'` 为无效揽装人。
- 业务解释：无效网点、有效网点但无揽装人、有效网点但揽装人无效，均不会发展号码和收入，因为网点号码和收入归属通过有效揽装人打标。

### 号码清单补客户经理 CRM 编码

- 驱动表：用户附件号码清单，保留原始序号和号码。
- 先补 069 全业务资料表：`附件号码 = 069.acc_nbr`，并按用户指定 `par_month_id` 锁号码快照，取当前 `serv_id/sales_code`。
- 再补 115 员工信息表：`069.sales_code = staff.staff_code`，固定 `staff.city_id='200'`、`staff.staff_account like '11%'`。
- 员工表 `dws_crm_cfguse.dws_staff` 可能有历史记录，必须先用 `row_number() over(partition by staff_code order by status_date desc, update_ts desc)` 取最新，再回填 `staff_name/staff_id/staff_account`。
- 如果附件号码在 069 未命中 `serv_id`，单独输出核查清单，可能是拆机、账期不在网或号码不一致。

### 国际漫游开通权限补字段

- 基础号码、客户名、产品类型、局向等属性仍优先从 069 全业务资料表圈定。
- 已开通国际漫游权限事实补 114 国际漫游数据表 `dws_ctg.dws_mktag_download_share_guoman_label`。
- JOIN：`069.acc_nbr = guoman.msisdn`。
- 必须按用户给定统计日过滤 `guoman.yyyymmdd`；若用户未指定统计日，先确认取最新分区还是取一段时间内曾开通。
- 输出开通国漫权限时间用 `reserv2`；用户开户时间是 `reserv1`，G/L IMSI 分别是 `reserv3/reserv4`。

### 号码清单导 IMSI

- 驱动表：用户附件号码清单，保留原始序号和号码。
- 先补 069 全业务资料表：`附件号码 = 069.acc_nbr`，并按用户指定 `par_month_id` 锁号码在网快照，取 `serv_id`。
- 再补 105 特性资料表：`069.serv_id = attr.serv_id`，`attr.attr_id='200000103'`，输出 `attr.attr_value1` 为 IMSI。
- 当前在网可用 105 日表；历史账期必须用 105 月表 `iodata_ods_month_city.tb_pre_cm_attr_all_mon`，并按 `par_month_id` 与 069 账期对齐。
- 不使用 `dws_crm_cust.dws_prod_inst_attr`；该表在本知识库中不作为独立补表路径沉淀。

### 种子 serv_id + 拆机前一月产品规格/附属产品属性

- 驱动表：用户种子表（含 `serv_id`；可无拆机月）。
- 拆机月：069 **月表** `dwm_yz_tb_comm_cm_all_mon_final`，默认 **逻辑拆机** `is_cancel_user=1`；`cancel_month_id = par_month_id`；多次拆机默认取最近 `hist_create_date`。
- 属性月：`attr_month_id = cancel_month_id - 1`。
- **产品规格属性**：105 特性资料**月表** `tb_pre_cm_attr_all_mon`；`par_month_id=attr_month_id` + `par_corp_id='200'` + `attr_id IN (...)`；宽表列前缀 `attr_{id}_*`。
- **附属产品属性**：106 附属产品**月表** `rpt_comm_cm_subserv_mon`；同上分区与 JOIN 键；宽表列前缀 `subattr_{id}_*`（与规格属性区分，避免 attr_id 碰撞）。
- **可同时取**：Step2 分别 LEFT JOIN 105 与 106 长表，Step3 宽表 pivot 合并。
- 中文名：字典 `attr_value1 = attr_inner_value` + `city_id='200'`（105/106 通用）。
- 多个 `attr_id` 默认 **宽表**；全程 LEFT JOIN 保种子行。
- 详见 `verified-cases/VC-20260522-001`。

维护来源：精简自 `D_experience/field_backfill.md`。
