---
name: sql-case-sedimentation
description: Use when the user wants to沉淀,迭代,审计, or升级 CDAP/write-query SQL business cases,工单脚本,案例文件夹, or案例矩阵 into reusable write-query knowledge.
---

# SQL Case Sedimentation

把 CDAP SQL 工单案例逐条拆成可复用的 `write-query` 技能知识。核心原则：**案例是证据，不是知识本身**；进入技能的是稳定的找表、补表、口径和审计规则。

总规则：**先判断现有 `write-query` 技能能否实现该案例**。如果现有路由、表文档、补表、口径、审计规则、场景或验证案例组合起来已经能稳定写出正确 SQL，则该案例默认判为 `已覆盖不写入`，不要沉淀案例本身。只有当案例揭示了现有技能缺少的稳定路由、缺字段补表、业务口径或审计规则时，才建议沉淀最小规则。

默认工作方式：**逐案确认**。先分析一个案例，输出可沉淀内容和风险，等待用户确认；确认前不要改 `write-query` 文件。

分析偏好：**优先抽象通用匹配规则，不沉淀过细案例链路**。先找案例里的“输入键 → 稳定表字段 → 中间对象 → 后续可接方向”，例如“身份证号 → 069.social_id → serv_id/acc_nbr/cust_id → 再接销售品/地址/设备/收入”。案例下游业务只作证据，不要把一次案例写成唯一场景规则。

## When Triggered

Use this skill when the user asks to:

- 从 SQL 案例、工单脚本、案例文件夹中“沉淀/迭代/升级 write-query 技能”。
- 一个案例一个案例分析，先确认再写入技能。
- 总结“啥场景找啥表”、补表规则、SQL 审计规则。
- 判断案例里的 SQL、表、字段、口径哪些能进入技能，哪些不能进入技能。

Also use it when the user says类似“案例沉淀”“把案例迭代进技能”“先跟我确认再沉淀”。

## Case Extraction Pipeline

For each target case, follow this pipeline before proposing any edit:

1. **读案例源文件**：定位用户原始需求、SQL 主体、附件/临时表、输出表、关键注释和异常写法。
2. **还原用户会怎么问**：把工单 SQL 翻译成 1-3 条自然语言需求，不沿用脚本变量名或一次性项目名。
3. **拆 SQL 事实**：提取业务对象、主事实表、补表、字段、JOIN、过滤、时间口径、分组粒度、去重方式、自检或核数逻辑。
4. **抽通用匹配路径**：把案例细节上卷为可复用链路：输入键（号码/身份证/客户编码/serv_id/地址/机构等）→ 稳定表字段 → 中间对象（serv_id/acc_nbr/cust_id/cust_nbr/org_id 等）→ 后续可接方向。不要默认把案例下游业务固化为场景。
5. **查现有知识覆盖**：按需读取 `write-query` 资料，判断现有路由、表文档、补表、规则、场景或验证案例是否已经能处理。
6. **做技能可实现性判断**：如果现有 `write-query` 能组合出正确 SQL，优先标记 `已覆盖不写入`，只说明实现路径、参数和旧 SQL 中不能照抄的写法。
7. **判断沉淀价值**：仅对现有技能缺失的稳定匹配规则、找表规则、补表入口、业务口径或审计规则，区分“直接沉淀 / 待核对 / 不沉淀 / 已覆盖不写入”。
8. **输出待确认方案**：只给可复用知识和风险，不把完整工单 SQL 当作技能内容。

## Grounding

Before asking the user anything:

1. Read the target SQL case, case folder index, or existing case matrix.
2. Read only the needed `write-query` references:
   - `ROUTING.md` for user language, scene-to-table routing, and “do not choose” traps.
   - `TABLE_INDEX.md` and matching `tables/*.md` for candidate table names, partitions, grain, and field availability.
   - `METRIC_INDEX.md` and matching `metrics/*.md` when the case expresses a stable standard metric.
   - `FIELD_BACKFILL.md` for missing-field joins, keys, filters, and row-count risks.
   - `RULES.md` for SQL generation/review rules, attachment handling, de-duplication, time windows, pivoting, and masking.
   - `scenarios/INDEX.md` only when the case looks like a reusable complex scenario.
   - `verified-cases/INDEX.md` only when a concrete reusable SQL flow may warrant or match a verified case.
3. Check whether the knowledge already exists. Do not duplicate an existing rule under a new name.
4. Check whether `write-query` can already implement the case end to end. "Can implement" means the current references can identify the business scene, choose the main table, map required fields, plan joins/backfills, apply filters/time口径, and audit the SQL without adding new stable knowledge.
5. If existing general `write-query` routing, table docs, field backfill, scenarios, verified cases, and audit rules already cover the case, do not propose new sedimentation; explain the existing reusable path and any remaining case-specific parameters.
6. If the existing skill can implement the case but the source SQL contains old or risky patterns, treat those patterns as review evidence, not new knowledge. Point to the existing rule that would correct them.

Do not read or edit archived runtime-disabled files unless the user explicitly asks for historical traceability.

## Sedimentation Decision

Classify each extracted item before deciding where it belongs.

| Level | Meaning | Action |
|---|---|---|
| 直接沉淀 | Stable across cases; table/field/logic is already verified or clearly reusable | Propose exact target file and concise rule text |
| 待核对后沉淀 | New table, code value, product/parameter code, external zone table, or field meaning is plausible but not stable | Ask the minimum confirmation question; do not write as a hard rule yet |
| 不沉淀 | One-off attachment, temp/result table, single customer/project/list, broken SQL syntax, or unverified hard-coded enum | List under “不应沉淀” with reason |
| 已覆盖不写入 | Existing `write-query` knowledge can already implement the case end to end | Explain the existing route and parameters; do not propose file edits |

Directly sediment only stable, reusable knowledge:

- 通用匹配规则：输入键 → 表字段 → 可获得的中间对象 → 后续可接方向。
- 主表路由：用户语言 / 业务场景 → primary fact table / “do not choose” trap.
- 字段补表：missing field → 补表 → JOIN keys → required filters → row-count risk.
- 业务口径：stable metric/action/status/time definition.
- SQL 审计：cross-case generation/review rules and anti-patterns.
- 专项流程：repeated multi-step CTAS or attachment-driven flows.

Do not sediment merely because a case has a common user phrasing, a useful example SQL, or requires combining several existing rules. Combination cost alone is not a sedimentation reason. Sediment only the missing stable rule that would change future correctness or routing confidence.

When a case contains a concrete chain such as `身份证 + 客户名 → 069 → 销售品在档`, first test whether the reusable part is only the upstream match (`身份证 → 069.social_id → 服务对象`). If yes, sediment that general entry point only; leave the downstream sales product, project, school, customer, attr_id, or offer code as case evidence or parameters.

## Target File Decision Tree

Use this tree when proposing edits:

| Extracted knowledge | Write to | Do not write to |
|---|---|---|
| 用户说法、业务场景、主表选择、不应误选表 | `ROUTING.md` | `TABLE_INDEX.md` as long routing prose |
| 新稳定表、Hive 名、粒度、分区、字段 | `TABLE_INDEX.md` + `tables/*.md` | `ROUTING.md` as table metadata |
| 标准指标名、同义词、技术口径 SQL | `METRIC_INDEX.md` + `metrics/*.md` | `ROUTING.md` or `RULES.md` as long formulas |
| 主表缺字段的通用 JOIN | `FIELD_BACKFILL.md` | `ROUTING.md` as detailed join steps |
| 通用 SQL 审计、反模式、附件核数、去重、打横、脱敏 | `RULES.md` | `verified-cases/` as generic rules |
| 复杂多步专项流程、固定 CTAS 编排、自检 | `scenarios/SC-*.md` + `scenarios/INDEX.md` | `ROUTING.md` / `RULES.md` as long flow |
| 已验证完整 SQL 实例 | `verified-cases/VC-*.md` + `verified-cases/INDEX.md` | Generic rule files |
| 已被现有知识覆盖 | No file change | Duplicate rule under a new name |

The most important capability is **finding the right table by business scene**, not accumulating scripts.

## One-Case Confirmation Protocol

Process **one SQL case at a time**. Do not update skill files before the user confirms that case.

For each case, respond in this exact shape:

```text
案例 X：{short title}

源文件：
{path}

一、用户会怎么问
- ...

二、证据摘取
- 主 SQL / 过程表：
- 主表 / 补表 / 外部表：
- 字段：
- JOIN：
- 时间口径：
- 过滤 / 码值：
- 粒度 / 去重：
- 审计 / 自检：

三、应识别的业务场景
- 场景标签：
- 业务事实在：
- 应找：
- 不应找：

四、已有知识覆盖检查
- ROUTING.md：
- TABLE_INDEX.md / tables/*.md：
- METRIC_INDEX.md / metrics/*.md：
- FIELD_BACKFILL.md：
- RULES.md：
- scenarios / verified-cases：
- 结论：已覆盖 / 部分覆盖 / 未覆盖

五、沉淀等级
- 通用匹配规则：
- 直接沉淀：
- 待核对后沉淀：
- 不沉淀：
- 已覆盖不写入：

六、建议补丁位置
- ROUTING.md：
- TABLE_INDEX.md / tables/*.md：
- METRIC_INDEX.md / metrics/*.md：
- FIELD_BACKFILL.md：
- RULES.md：
- scenarios：
- verified-cases：

七、不应沉淀
- 一次性附件表：
- 临时 / 结果表：
- 单客户 / 单项目 / 单批枚举：
- 不稳定码值 / 产品参数：
- 破损 SQL 写法：

八、需要你确认
- ...
```

Confirmation questions must be few and material. Ask only when the answer changes write location,口径稳定性, table stability, or whether a rule is safe to generalize.

If the case is fully covered by existing general rules, still use the shape above but set:

- `四、已有知识覆盖检查` conclusion to `已覆盖`.
- `五、沉淀等级` to `已覆盖不写入`.
- `六、建议补丁位置` to `不建议修改技能文件`.

When a case is implementable by current `write-query` but not exactly matched by one single route, still prefer `已覆盖不写入`. In `四、已有知识覆盖检查`, explicitly list the existing implementation path, for example: `ROUTING -> 069; FIELD_BACKFILL -> 017/079; RULES -> 地址转字符/脱敏`.

## What Not To Sediment

Do not write these into runtime knowledge as stable rules:

- One-off attachment table names such as `zone_gz_yz_*`; abstract them as “用户附件种子表”.
- Personal temp tables, result tables, or scheduling target tables.
- Single customer names, phone numbers, project names, contract lists,网点 lists, sales product lists, or one-time parameter lists.
- Broken SQL syntax copied from a case.
- A parameter code, product code, status code, attr_id, or label field unless the user confirms it is reusable or it is verified elsewhere.
- Full scripts inside `RULES.md`; use concise rules or a scenario / verified case only when needed.
- Cases that can already be implemented by existing general rules.
- Cases that only make an existing path more convenient or provide another example, without adding a missing stable route,补表,口径, or审计 rule.

## Editing Workflow After Confirmation

After the user confirms a case:

1. Edit `.agents/skills/write-query` first.
2. Keep changes scoped to the confirmed case.
3. Add a table document only when the user confirmed the table is stable enough for `TABLE_INDEX.md`.
4. If adding or changing a standard metric, update both `METRIC_INDEX.md` and the matching `metrics/*.md`.
5. Sync `.agents` to `.claude` with:

```bash
bash scripts/sync_skills.sh sync agents --force
```

6. Verify:

```bash
bash scripts/sync_skills.sh check
python3 .agents/skills/write-query/scripts/lint_metric_index.py --index .agents/skills/write-query/references/METRIC_INDEX.md
```

7. Report exactly what changed and what remains uncommitted. Do not include unrelated files.

If the confirmed case does not touch metrics, the metric index lint is optional but preferred when available.

## Multi-Case Runs

For a folder of cases:

1. Create or update a review matrix first if none exists.
2. Then proceed case by case using the confirmation protocol.
3. Do not batch-write multiple cases unless the user explicitly changes from “逐案确认” to “分批确认”.

Useful matrix columns:

```text
案例 -> 用户会怎么问 -> 场景标签 -> 证据摘取 -> 已有知识覆盖 -> 沉淀等级 -> 写入位置 -> 不应沉淀 -> 待确认
```

## Default Next-Case Behavior

When the next SQL case arrives:

1. Analyze only the provided case unless the user asks for a folder-level matrix.
2. Produce the one-case confirmation card.
3. Recommend no file changes when existing `write-query` knowledge already covers the case.
4. Wait for explicit user confirmation before editing any `write-query` file.
5. Keep `.agents` as the edit source of truth and sync to `.claude` after confirmed edits.
