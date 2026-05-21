---
layer: D
title: "已知陷阱（追加日志）"
---

# 已知陷阱（按时间累积）

> **格式**：每次踩坑追加一段（最新在最上面），五段式：场景 / 错处 / 正确 / 反向更新 / 关联规则。
>
> **回填规则**：每次任务完成必填一段（即便没踩坑也可记"这次差点错的点"）。

---

## 2026-05-07: 069 全业务资料表日/月表选择

**场景**：用户补充 069 全业务资料表存在日表和月表，且两张表按账期保留范围不同；需要后续写 SQL 时自动选择正确生产表。

**错处**：
1. 只记录了 069 生产名 `dwm_yz_tb_comm_cm_all_final`，没有区分日表/月表。
2. 跨历史账期查询时可能错误地只查日表，导致超出最近半年窗口的数据缺失。
3. 上月等重叠账期在日表/月表都存在时，未定义默认优先级。

**正确做法**：069 日表为 `dwm_yz_tb_comm_cm_all_final`，只保留最近半年账期；069 月表为 `dwm_yz_tb_comm_cm_all_mon_final`，包含当前月上月及以前账期。重叠账期默认优先日表；跨近半年和历史账期时，近半年月份查日表，更早历史月份查月表，并用 `UNION ALL` 合并。

**反向更新**：
- `ROUTING.md`：覆盖规则补 069 日/月表选择
- `RULES.md`：时间/分区审计补日/月表拆分检查
- `tables/069_全业务资料表.md`：补日表、月表、近半年和历史账期说明
- `TABLE_INDEX.md`：069 行补生产日表/月表
- `business_glossary.md`：全业务口径补日/月表路由
- `table_routing.md`：高优先级覆盖规则补日/月表经验

**关联规则**：运行时 `ROUTING.md`、`RULES.md`、A 层 `069_全业务资料表.md`

---

## 2026-05-07: 双线定义与速率/月租取数

**场景**：用户按号码和入网时间匹配揽装机构、非双线出账收入、双线速率和双线月租；初版把双线速率固定从 033 双线全量清单取，用户补充双线定义和速率取数规则。

**错处**：
1. 未优先用 069 全业务资料表 `prod_type2` 识别双线范围。
2. 把双线速率路径写得过死，忽略 069 和 033 都可取 `speed_value`。
3. 没有明确双线月租才需要补 033 `yz_cs`。

**正确做法**：双线定义优先看 069 全业务资料表 `prod_type2 IN (60,70,71)`，其中 60=互联网专线，70/71=组网专线。双线速率可取 069 或 033 的 `speed_value`：主路径在 069 时直接取 069；已补 033 取月租或用户指定双线清单口径时，可取 033。双线月租按需补 033 双线全量清单 `yz_cs`。

**反向更新**：
- `ROUTING.md`：新增双线术语和主表路由规则
- `FIELD_BACKFILL.md`：新增双线速率/月租补表边界
- `business_glossary.md`：新增双线 / 互联网专线 / 组网专线术语映射
- `table_routing.md`：新增双线数据路由
- `tables/069_全业务资料表.md`：补双线条件和速率说明
- `tables/033_双线全量清单.md`：补月租/速率使用说明

**关联规则**：A 层 `069_全业务资料表.md`、A 层 `033_双线全量清单.md`、运行时 `ROUTING.md`、`FIELD_BACKFILL.md`

---

## 2026-05-07: 装机地址默认取数路径

**场景**：用户根据号码和月份补充出账金额、欠费金额、归属局向、接入号装机地址、揽装人；初版把装机地址字段直接从现成清单字段取，用户纠正为标准地址路径。

**错处**：
1. 没有先识别“装机地址”是标准地址维度补字段场景。
2. 未使用 069 全业务资料表的 `serv_addr_id` 作为地址关联键。
3. 未加载地址维表结构，导致没有生成 `grade=10` 和脱敏地址模板。

**正确做法**：涉及装机地址 / 接入号装机地址 / 地址信息时，主业务表优先取 `serv_addr_id`；关联 079 地址维表 `zone_gz_yz.dwd_yz_addr_final`，条件为 `CAST(serv_addr_id AS DECIMAL(24,0)) = id`，装机地址中文名默认锁定 `grade=10` 后取 `addr`；需要脱敏时按 `tm_addr_name` 模板输出。

**反向更新**：
- `business_glossary.md`：新增装机地址术语映射
- `table_routing.md`：维表区新增地址 / 装机地址路由
- `TABLE_INDEX.md`：新增 079 地址维表
- `tables/079_地址维表.md`：新增地址维表字段、常用条件、关联模板和脱敏模板

**关联规则**：A 层 `079_地址维表.md`、D 层 `table_routing.md`

---

## 2026-04-28: 销售品发展量陷阱（首批种子）

**场景**：用户要按给定销售品编码看 202509/202510 月发展量，输出号码、客户名、揽装人、竣工时间、划小局向、揽装局向等明细字段。

**错处**：
1. **选错主表**：因 `prod_offer_code/prod_offer_name` 字段名匹配，选了"燃气卫士到达清单"专项表（实际应走 041 优惠订单表）。
2. **A 层 md 名漂移**：069 md 写 `ads_yz_tb_comm_cm_all_final`，生产实际是 `dwm_yz_tb_comm_cm_all_final`；041 md 写 `zone_gz_yz.dwm_yz_rpt_comm_ba_msdisc_final`，生产实际无 schema 前缀。
3. **字段虚构**：直接写了 `prod_offer_code/prod_offer_name/channel_subst_name/channel_branch_name`，没核对所选表是否真有这些字段。
4. **状态码值用术语**：写 `subs_stat IN ('竣工','正常')`，实际生产用 `subs_stat='301200'` + `subs_stat_reason NOT IN ('1200','1300')`。
5. **动作过滤错**：用了 `action_type='新订购'`，实际生产用 `action_id IN (1292,6200)`（订购+销售品互换）。
6. **是否竣工当过滤**：把 is_jg 当 WHERE 条件，实际用户希望保留为标记列。
7. **维表漏 city_id=200**：销售品维表 `dws_offer` 跨城重号，必须按地市过滤。
8. **机构维表 JOIN 字段错位**：用 `salestaff_subst_id` 关联 `subst_id`，应该用 `org_id` + `levs=3/4`。
9. **明细行混汇总**：在明细列里塞 `COUNT(1) OVER (PARTITION BY par_month_id)`。
10. **占位符 SQL 当成完成品**：在 IN 里写 `'销售品编码1','销售品编码2'`。

**正确做法**：041 优惠订单表为主，按 `subs_stat_date` 落 202509/202510，`action_id IN (1292,6200)`，`subs_stat_reason NOT IN ('1200','1300')`；JOIN `dws_offer city_id=200` 取销售品名；JOIN 资料表 `dwm_yz_tb_comm_cm_all_final` 按 serv_id 取划小局向名；JOIN `dwd_yz_dim_org` 两次按 levs=3/4 取揽装局向名；is_jg 作为标记列保留。

**反向更新**：
- `business_glossary.md`：销售品/揽装/竣工/撤单 等 5 行
- `table_routing.md`：销售品类整段（4 行）
- `anti_patterns.md`：AP-001 ~ AP-014 共 14 条
- `cdap_global_rules.md`：R-001 ~ R-010 共 10 条
- `dictionaries/subs_stat.md`：301200=竣工
- `dictionaries/action_id.md`：1292=订购，6200=销售品互换
- `dictionaries/subs_stat_reason.md`：1200=撤单，1300=作废
- `tables/041_优惠订单表.md`：补 `cust_name`、`subs_stat_reason` 字段，标注生产表名
- `tables/069_全业务资料表.md`：frontmatter 标注生产表名漂移

**关联规则**：[AP-001](anti_patterns.md) ~ [AP-014](anti_patterns.md)、[R-001](cdap_global_rules.md) ~ [R-010](cdap_global_rules.md)

---

## 模板（复制下面这块来追加新条目）

```markdown
## YYYY-MM-DD: 简短标题

**场景**：用户的需求是什么

**错处**：
1. 错误 1
2. 错误 2

**正确做法**：怎么做对

**反向更新**：
- `xxx.md`：加了什么
- `yyy.md`：改了什么

**关联规则**：[AP-NNN](anti_patterns.md)、[R-NNN](cdap_global_rules.md)
```
