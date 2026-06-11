# 种子 serv_id 拆机前月属性宽表

## 适用

- 用户提供 **`serv_id` 种子清单**（可有 `acc_nbr`，可无拆机月），要对每个服务打标。
- 取 **拆机前一个月** 的 **产品规格属性**（105）和/或 **附属产品属性**（106）（`attr_id` → `attr_value1` + 中文名）。
- 多个 `attr_id` 默认输出 **宽表**：
  - 产品规格：`attr_{id}_val` / `attr_{id}_name`
  - 附属产品：`subattr_{id}_val` / `subattr_{id}_name`（前缀区分，避免 attr_id 碰撞）
- 拆机口径未特说明时，默认 **逻辑拆机**。
- **仅附属产品属性**（不要产品规格）时：可跳过 105 长表步骤，只跑 106 长表 + 宽表 pivot。

## 不适用

- 用户明确 **物理拆机** 且有拆机订单事实 → 改 `is_wl_cancel_user=1` + `wl_cancel_subs_stat_date`。
- 取 **当前在网** 特性 → 特性/附属**日表**（`tb_pre_cm_attr_all` / `rpt_comm_cm_subserv`）。
- 销售品在档 / 订购动作 → 014 / 041，不是特性/附属产品资料表。
- 固定账期打标（种子已带拆机月且不需反查）→ 可简化拆机月定位，但仍用对应月表。

## 主表与补表

| 角色 | 表 | 用途 |
|---|---|---|
| 驱动表 | 用户种子表 | 键 `serv_id`；保留原始序号 |
| 拆机月定位 | 069 **月表** `dwm_yz_tb_comm_cm_all_mon_final` | 逻辑拆机 `is_cancel_user=1`；`cancel_month_id = par_month_id` |
| 产品规格快照 | 105 特性月表 `tb_pre_cm_attr_all_mon` | `par_month_id=attr_month_id` + `par_corp_id='200'` + `attr_id` |
| 附属产品快照 | 106 附属产品月表 `rpt_comm_cm_subserv_mon` | 同上分区与 JOIN 键 |
| 特性中文 | 015 字典表 `dws_attr_value` | `attr_value1 = attr_inner_value` + `city_id='200'` |

## 关键规则

- **属性月**：`attr_month_id = cancel_month_id - 1`。
- 多次拆机默认取最近 `hist_create_date`（`row_number` 按 `hist_create_date desc, par_month_id desc`）。
- **105 vs 106**：用户说「属性/attr_id/特性值」且上下文有 **附属产品 / `sub_prod_id`** → 106；否则默认 105。
- 历史/拆机前月快照 **禁止** 069 日表 + 特性/附属月表混配；069 与 105/106 均走月表。
- 可同时取 105 与 106：Step2 分别 LEFT JOIN 长表，Step3 宽表 pivot 合并。
- 多个 `attr_id` 默认宽表；全程 LEFT JOIN 保种子行。
- 复杂编排默认 **CTAS 流水线**（见 `RULES.md`）；已验证实例见 `verified-cases/VC-20260522-001`。

## 输出字段建议

| 需求字段 | 来源 |
|---|---|
| acc_nbr, serv_id | 种子表 |
| hist_create_date, cancel_month_id, attr_month_id | 069 月表 + 计算 |
| attr_{id}_val / attr_{id}_name | 105 特性月表 + 字典 |
| subattr_{id}_val / subattr_{id}_name | 106 附属产品月表 + 字典 |
| sub_prod_id | 106（可选带出） |

## 风险审计

- 069 日表配属性月表 → 已拆机历史漏数。
- 105/106 混用或日表查历史 → 特性值错误。
- 字典关联用 `attr_value` 而非 `attr_inner_value` → 中文名错误。
- 种子行被 INNER JOIN 过滤掉 → 必须全程 LEFT JOIN。

## 自检

- Step1 后：`select count(*) from 拆机月基表` 应 ≥ 种子 `count(distinct serv_id)` 的命中比例合理。
- 105/106 长表：`select attr_id, count(*) ... group by attr_id` 核对各 attr_id 覆盖。
- 宽表结果：`select count(*), count(distinct serv_id) from 结果`；应与种子行数一致（LEFT JOIN 保行）。
- 样例 `limit 10` 检查 `attr_*_name` / `subattr_*_name` 非空率是否符合预期。

## 错误路径

- 不要用 069 日表 `dwm_yz_tb_comm_cm_all_final` 做拆机月回溯。
- 不要用特性/附属日表查已拆机历史。
- 不要把 105 与 106 混为同一张属性表。
- 不要用 014/041 替代特性/附属产品属性。
