---
title: "Join Planning / 字段缺口补表"
runtime: true
---

# Join Planning / 字段缺口补表

用于主表已确认、字段盘点完成后的**通用**补表决策。原则：主表字段够用就不补表。专项场景完整补表步骤见 `scenarios/SC-*.md`，本文件不重复展开。

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
5. 命中附件驱动、跨表编排或专项诊断时，先读 `scenarios/INDEX.md` 并只打开命中的场景文件。
6. 补表后检查 JOIN 键、粒度、必要过滤、是否会放大行数。

## 不补表边界

- 任意产品入网量、新装量、到达量的主表默认保持 069 全业务资料表；不要因为“宽带/移动/固话/视联网”等产品词切到专项清单。
- 只需要状态、动作、原因等码值含义且**仅用于 WHERE 过滤**时，优先读字典 md 写码值，可不 JOIN 字典表。
- **069.`state` 作为输出字段时**：默认交付 **码值 + 中文名**；补 `dws_crm_cfguse.dws_attr_value`（`attr_id='4000000201'`，`attr_value = state` → `attr_value_name`）。
- 只需要销售品、产品、机构、销售员等名称补全时，补维表；不要因此改写主表。
- 需求出现“主体编码 / 主体名称”时，默认指网点经营主体；**主表为 069 时固定补 113 揽装所属表**（见 `069_全业务资料表.md` 与下文 §069 主体）；其它主表补 112 网点维表；不要全库搜索。
- 只需要订单状态、受理时间、协销人等订单事实字段时，补订单/协销事实表；不要反向把订单表改成主表。
- 主表已有中文名称字段且语义明确时，不补维表。

## 补表规则

| 字段需求 | 主表常见字段 | 何时补表 | 补表 | JOIN / 过滤规则 | 风险 |
|----------|--------------|----------|------|-----------------|------|
| 产品入网量 / 到达量条件 | `prod_type`、`kd_desc`、`is_new_user`、`open_date`、`par_month_id` | 069 字段满足时不补表 | - | 直接在 069 写过滤条件 | 不要按产品词切专项清单 |
| 直销客户编码 / 客户编码 | `ccust_id`、`cust_code`、`cust_id`、`cust_nbr` | 主表候选字段语义无法确认时先不补表 | - | 先列候选字段请用户确认 | 最容易混用直销客户和产权客户 |
| 产权客户编码 | 附件 `cust_name` | 客户实体映射/维护场景中，附件无产权客户编码，需按产权客户名称回填编码 | 108 产权客户全量表 `dws_crm_cust.dws_customer` | `附件.cust_name = 108.cust_name` → `cust_number` | 客户名可能重名或多命中；只作为无编码兜底，必须保留附件行标识；号码/服务明细要客户字段时优先用事实主表自带字段 |
| 直销客户编码 / 直销客户名称 | 产权客户编码 `cust_nbr` | 用户明确要签订/维护直销客户，或通过产权客户找直销客户 | 109 直销客户表 `zone_gz_yz.dws_yz_tb_mo_custgrp_cust_final` | `附件或主表.cust_nbr = 109.cust_nbr` → `ccust_code/ccust_name` | 同一产权客户可能多条直销客户记录；回填前后核对行数；号码/服务明细要直销客户名时优先用 069 或当前事实主表自带字段 |
| 身份证号 / 证件号反查服务对象 | 附件证件号、身份证号 | 需求提供证件信息，需要匹配客户名下号码、服务、宽带、状态等业务对象 | 069 全业务资料表 `dwm_yz_tb_comm_cm_all_final` | `附件.证件号 = 069.social_id`；身份证场景加 `069.social_id_type = 1`；匹配后取 `serv_id/acc_nbr/cust_id/cust_nbr/prod_type/state/is_cancel_user` 等，再按需求接后续表 | 一个证件可能对应多个服务；是否加客户名、客户编码、号码等辅助键由需求决定，不强制双键 |
| 销售品编码 / 名称 | `prod_offer_id`、`kd_prod_offer_id` | 主表只有销售品 ID | 020 销售品维表 | `主表.prod_offer_id = offer.offer_id`；`offer.city_id=200` | 不加城市会错配 |
| 同套餐实例下的其他号码 | 附件号码、`serv_id`、需求方给的销售品编码 | 通过一个号码定位其所在套餐，再取同套餐实例下其他号码、服务或产品类型 | 014 优惠资料表 `ads_yz_rpt_comm_cm_msdisc_final`；必要时回 069 全业务资料表 | 附件号码先用 069 补 `serv_id`；若入口是销售品编码，先用 020 取 `offer_id` 再在 014 锁入口 `serv_id + prod_offer_id`；取入口行 `msobjgrp_id` 后，用同 `msobjgrp_id` 在 014 找其他 `serv_id/acc_nbr`；需要号码类型、状态、产品分类时再回 069 | `msobjgrp_id` 表示套餐实例，不要把一次案例写成固定 WiFi/IPTV；同套餐可能多号码，默认保留明细，若要一号一行需确认聚合方式 |
| 折扣 / 赠金 / 统付金额 / 销售品参数值 | 014 `prod_offer_id`、`serv_id` | 需具体 `param_value` 且 014 已锁在档销售品 | 107 销售品参数表 | 见下文 **§销售品参数值（107）** | 不要用 107 判断在档；`param_code` 不可猜 |
| 设备名称 / 设备类型 / 购买方式 / 机身号 / 数量 | `serv_id` | 主表或附件只有号码 / 服务，缺设备资源字段 | 119 设备资源关系表 `ads_yz_prod_res_inst_rel_final` | `主表或附件.serv_id = 119.serv_id`；输出 `mkt_res_name/res_type/property_type_name/eqpt_sn/mkt_res_num` | 同一 `serv_id` 可能多设备；默认保留明细多行，若要一号一行需确认聚合方式 |
| SR科目名称 / SR科目路径 / 收入来源 / 计费收入科目 / 账目项 / 税后收入明细 | 069 `serv_id`、`acc_nbr`、客户/产品属性 | 先按项目、客户名、产品分类、号码清单等条件圈定对象，再要科目级收入明细 | 048 全量科目级收入 `dwm_srhx_src_income_list_mon`；最新月可用 `dwm_srhx_src_income_list` | `069.serv_id = 048.serv_id` 且账期一致；048 账期字段用 `month_id`；取 `due_income_name/due_type/data_src_name/col_income_name/acct_item_type_name/fee_all` | 048 是科目/账目项明细，一户一月可能多行；输出明细不随意去重，汇总时按输出维度 `sum(fee_all)` |
| 产品名称 | `prod_id` | 主表只有产品 ID | 017 产品维表 | `主表.prod_id = product.prod_id` | 先确认产品维表字段名 |
| 主体编码 / 主体名称 | `channel_nbr`、`channel_id`、`channel_name` | 需求要网点归属经营主体 | **069 主表**：113 揽装所属表；**其它主表**：112 网点维表 | 069：优先 `069.channel_nbr = 113.channel_nbr`，见 §069 主体；其它：`主表.channel_nbr = 112.channel_nbr`，无 `channel_nbr` 再用 `channel_id`；历史账期用 `_mon_final + par_month_id` | 113 一网点多揽装人须去重；112 网点日表唯一；历史月按账期对齐 |
| 机构名称 / 分局 / 营服名称 | 各业务表中的机构 ID，如 `subst_id`、`branch_id`、`branch_org`、`manage_org` | 主表只有机构 ID 无名称 | 018 机构维表 | `业务表机构ID = 018.org_id`；是否限制 `levs` 看需求和来源 ID 语义 | 018 只负责机构 ID 翻译；不要脱离来源字段语义断定是直销客户、产权客户或号码归属 |
| 落地县分 / 营服名称 | `std_subst_id`、`std_branch_id`、`std_subst_name`、`std_branch_name` | 主表只有 ID 无名称 | 018 机构维表 | `org_id` 关联；按层级限制 | 落地局向不同于划小局向 |
| 订单编码 / 订单状态 / 受理时间 | `subs_id`、`subs_code`、`subs_stat_date`、`act_date` | 主表缺订单事实字段 | 040 全业务号码订单表 | 优先 `subs_id`；无 `subs_id` 再看 `serv_id` | 订单表可能一对多，需去重 |
| 协销人 | 主表通常缺 | 主表无协销字段 | 040；不足再 042/043 协销表 | 按订单键或 `serv_id` 关联，必要时先去重 | 容易放大明细行 |
| 揽装人 / 销售员 | `sales_id`、`sales_code`、`sales_name`、`sales_man_name`、`staff_id` | 主表缺姓名或工号不完整 | 111 揽装人维表；有效网点下有效揽装人用 113 揽装所属表 | 优先用 `staff_id` 关联；历史账期用 `_mon_final + par_month_id` | 先确认是揽装人、受理人还是协销人；`sales_code` 不唯一 |
| 客户经理 CRM 编码 / 11 开头 CRM 工号 | 069 `sales_code` | 号码清单补 CRM 工号 | 115 员工信息表 | → `SC-001` | 员工表历史多版本须去重 |
| 合同网点下有效揽装人 / 实际工号数量 | 110 `channel_id` | 合同下有效揽装人 | 113 揽装所属月表 | → `SC-007` | 工号数量按 `staff_id` 去重 |
| 网点有效性 / 揽装人有效性 | 网点/揽装人清单 | 无号码收入网点诊断 | 112、113、111 月表 | → `SC-007` | 113 缺记录须回查 112/111 |
| 国际漫游开通权限 / 国漫时间 / G-L IMSI | 069 `acc_nbr` | 国漫权限开通 | 114 国际漫游数据表 | → `SC-002` | `yyyymmdd` ≠ 069 账期 |
| 移动投诉号码对应套内宽带号 | 附件投诉号码 | 移机订单匹配前转宽带 | 069 月表 | → `SC-004` | 生成 `gl_acc` 再关联 118 |
| 主卡号码 | 附件副卡 `acc_nbr` | 副卡查主卡 | 069（不额外补表） | 069 `zk_acc_nbr` | 不默认 `is_vice_card=1` |
| 指定层级地址 ID/名称 | 069 `serv_addr_id` | 号码清单补地址层级 | 079 地址维表 | → `SC-006` | 目标层级由用户给出；地址 ID 统一转字符 |
| 揽装机构 | `salestaff_subst_id`、`salestaff_branch_id` | 主表只有机构 ID | 018 机构维表 | 分局 `salestaff_subst_id = org_id AND levs=3`；营服 `salestaff_branch_id = org_id AND levs=4` | 多次 JOIN 要检查别名 |
| 双线速率 | 069 `speed_value`；033 `speed_value` | 主路径已在 069 时不补表；已补 033 或用户指定双线清单口径时可取 033 | 033 双线全量清单（可选） | 若补 033，按 `acc_nbr + par_month_id` 关联 | 不要只为速率强行补 033；两边均可取时跟随主路径 |
| 双线月租 | 033 `yz_cs` | 069 不提供双线月租或用户明确要月租 | 033 双线全量清单 | `主表.acc_nbr = 033.acc_nbr` 且 `主表.par_month_id = 033.par_month_id` | 033 同号码同月可能多行，必要时按 `load_date` 去重 |
| 客户名称 | `cust_name`、`cust_name_tm`、`cust_id` | 主表脱敏/不脱敏不满足时 | 客户表或 069 | 主表自带优先；跨表时按 `serv_id/cust_id` 谨慎关联 | 069 `cust_name_tm` 是脱敏名 |
| 状态 / 动作含义 | `subs_stat`、`action_id`、`subs_stat_reason` | 需要解释或过滤码值 | `D_experience/dictionaries/{field}.md` | 不 JOIN，直接查码值后写 WHERE | WHERE 禁止中文状态 |
| **服务状态 `state`（069）** | **`state`**（码值） | **输出状态字段或用户说「状态/号码状态」** | **`dws_crm_cfguse.dws_attr_value`**（`tables/015_字典表视图.md`） | `attr_id='4000000201'` AND `attr_value = cast(state as string)` → **`attr_value_name`** | **默认同时输出 `state` 码值与中文名**；勿用 `is_cancel_user` 等代替，除非用户明确要规模口径 |
| **产品规格属性 / 特性值** | 主表通常无 | 用户要主产品 `attr_id` 特性码值；历史/拆机前某月 | **105 特性资料表**（`tables/105_特性资料表.md`） | 月表 `iodata_ods_month_city.tb_pre_cm_attr_all_mon`：`serv_id` + `par_month_id` + `par_corp_id='200'` + `attr_id` | 历史必须用月表；日表 `tb_pre_cm_attr_all` 只在网 |
| **IMSI / 号码 IMSI** | 069 `acc_nbr` | 号码清单导 IMSI | **105 特性资料表** | → `SC-005` | 勿走 114 国漫表 |
| **附属产品属性 / 附属产品特性值** | 主表通常无 | 用户要附属产品 `attr_id` 特性码值；历史/拆机前某月 | **106 附属产品资料表**（`tables/106_附属产品资料表.md`） | 月表 `iodata_ods_month_city.rpt_comm_cm_subserv_mon`：`serv_id` + `par_month_id` + `par_corp_id='200'` + `attr_id` | 勿与 105 混用；历史必须用月表 |
| **特性值中文名** | `attr_value1`（码值） | 输出产品规格或附属产品属性且要中文 | **`dws_crm_cfguse.dws_attr_value`** | `a.attr_id=b.attr_id` AND `a.attr_value1=b.attr_inner_value` AND `b.city_id='200'` → **`attr_value_name`** | 用 **`attr_inner_value`**，不是 `state` 的 `attr_value`；105/106 通用 |

## 销售品参数值（107）补表链路

**单一事实源**：折扣、赠金、统付金额、销售品参数值等需求的补表步骤以本节为准；`ROUTING.md` 只保留主表判断（存量在档 → 014），`tables/107_销售品参数表.md` 只保留字段与示例 SQL。

### 何时走本链路

- 用户要的是 **参数值** `param_value`（折扣率、赠金金额、统付金额等），不是「有没有办理 / 是否在档 / 到期时间」。
- 「是否在档 / 到期」→ **014 优惠资料表**（主表或补表），**不要用 107**。
- 销售品 **订购 / 发展量动作** → **041**，不是本链路。

### 主表与三步补表

| 步骤 | 表 | 作用 |
|------|-----|------|
| 0（可选） | 069 全业务资料表 | 附件仅给 `acc_nbr` 时补 `serv_id`；锁 `par_month_id` |
| 1 | 014 优惠资料表 `ads_yz_rpt_comm_cm_msdisc_final` | 锁账期在档销售品：`serv_id` + `par_month_id` + `prod_offer_id`；可取 `limit_date` |
| 2 | 107 销售品参数表 `summary_ods_day_city.rpt_comm_cm_msparam` | 补 `param_value` |

**ROUTING 主表判断**：销售品参数类需求的事实主路径为 **014（先锁在档）**；107 仅作补表，**禁止**把 107 当主表。041 是动作表，不用于查在档参数。

### JOIN 键与过滤

```sql
-- 014 已得 serv_id、prod_offer_id 后
left join summary_ods_day_city.rpt_comm_cm_msparam p
  on msdisc.serv_id = p.serv_id
 and msdisc.prod_offer_id = p.prod_offer_id
 and p.param_code = ${param_code}   -- 必须来自用户/口径/案例，禁止猜测
 and p.par_corp_id = '200'
```

- 广州固定 `par_corp_id = '200'`。
- 需「仍有效」参数时，按需求过滤 `limit_date`（如 `limit_date >= 账期月底`）。
- 同一 `serv_id + prod_offer_id` 可能多 `param_code`：明细保留多行，或按参数编码打宽表。

### 风险与自检

- `param_code` 未确认 → 先问用户，不要猜编码。
- 用 107 判断销售品是否在档 → 错误，应查 014。
- 用 041 查参数值 → 错误，041 是订单动作。
- 自检：补 107 前后行数；多 `param_code` 时说明是否一对多膨胀。

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

复杂场景的完整流程放在 `scenarios/`。本节只保留通用补表提醒；命中下列需求时优先读对应 `SC-*.md`，不要在本文件里展开完整步骤。

| 场景 | 读取 |
|---|---|
| 客户经理 CRM 编码 / 11 开头工号 | `scenarios/SC-001_客户经理CRM编码.md` |
| 国际漫游开通权限 | `scenarios/SC-002_国际漫游开通权限.md` |
| 固话使用记录 | `scenarios/SC-003_固话使用记录.md` |
| 投诉号码匹配移机订单 | `scenarios/SC-004_投诉号码匹配移机订单.md` |
| 号码清单导 IMSI | `scenarios/SC-005_号码清单导IMSI.md` |
| 号码清单补指定地址层级 | `scenarios/SC-006_号码清单补地址层级.md` |
| 市场化合同有效揽装人 / 无号码收入网点诊断 | `scenarios/SC-007_市场化合同有效揽装人.md` |
| 117 实收 / 047 客户基本面·产数（附件·圈定·直查） | `scenarios/SC-009_047117收入实收查询.md` |
| 种子 serv_id + 拆机前月产品规格/附属产品属性宽表 | `scenarios/SC-008_种子serv_id拆机前月属性宽表.md` |

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
- 主体编码、主体名称**固定补 113 揽装所属表**（与 `069_全业务资料表.md` 一致），不全库搜索，**不要**默认改补 112。
- 优先 `069.channel_nbr = 113.channel_nbr`；一网点多揽装人时按 `channel_nbr` 去重，避免行数放大（详见 `113_揽装所属表.md`）。
- 113 无记录时再回查 112 网点维表判断网点有效性，不要直接判定主体缺失。
- 历史账期补 113 月表时，必须按 `par_month_id` 对齐；当前口径可用日表。

### 副卡号码补主卡号码

- 驱动表：用户附件副卡号码清单，保留原始序号和副卡号码。
- 主表保持 069 全业务资料表：`附件号码 = 069.acc_nbr`，并按用户指定 `par_month_id` 锁号码快照。
- 移动号码建议加 `069.prod_type=30`，直接输出 `069.zk_acc_nbr` 作为主卡号码。
- 不默认加 `is_vice_card=1`；该字段可用于理解副卡状态，但不是本场景的默认过滤条件。
- 输出后核对附件输入行数和结果行数；未命中的号码单独列出。

### 种子 serv_id + 拆机前一月产品规格/附属产品属性

- 完整流程见 `scenarios/SC-008_种子serv_id拆机前月属性宽表.md`；已验证 CTAS 实例见 `verified-cases/VC-20260522-001`。

维护来源：精简自 `D_experience/field_backfill.md`。
