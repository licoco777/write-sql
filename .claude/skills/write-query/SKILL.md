---
name: write-query
description: 为 CDAP 电信业务数据分析平台编写、改写和审计 Hive SQL。Use when the user asks for CDAP 取数、指标口径、销售品/订单/收入/积分/续约/新装等业务查询、表路由、字段补全、码值过滤、Hive SQL 编写、SQL 优化或 SQL 口径审计。DO NOT use for 非 CDAP 的 PostgreSQL/MySQL 通用查询、纯库表元数据查询（DESC/SHOW）、Excel 报表加工、数据可视化、ETL 任务调度配置。
---

# write-query

把自然语言数据需求收口成可执行的 CDAP Hive SQL。`SKILL.md` 是唯一运行时流程权威；其它 md 只作为按需加载的资料。

核心原则：先澄清会影响 SQL 结果的关键缺口，再选相关 schema、确认业务口径、做字段映射和补表，最后生成完整 SQL 并审计。用户入口保持轻量；主表、字段、补表和审计细节只在低置信度、有歧义或最终交付时展开。

## 启动策略

启动后只读本文件。不要自动读取全量表结构、全量指标或案例。

按阶段读取资料（**默认最小加载**，条件追加）：

| 阶段 | 默认读取 | 条件追加 |
|------|----------|----------|
| Schema Linking / 主表选择 | `references/ROUTING.md` | 用户给生产表名/Hive 名 → `TABLE_INDEX.md`；命中标准指标名 → `METRIC_INDEX.md` |
| Business Semantics / 口径确认 | 已锁主表 `references/tables/*.md` | 标准指标 → `METRIC_INDEX.md` + 单指标文件；复杂编排 → `verified-cases/INDEX.md` |
| Column Linking / 字段映射 | 已锁主表 `references/tables/*.md` | — |
| Join Planning / 缺口补表 | `references/FIELD_BACKFILL.md`、补表 `tables/*.md` | 命中专项 → `scenarios/SC-*.md`（完整补表步骤以 SC 为准） |
| SQL Generation + Review | `references/RULES.md`、相关 `dictionaries/{field}.md` | 命中专项 → `scenarios/SC-*.md` 风险审计/自检；复杂 CTAS → `verified-cases/VC-20260520-001` |
| Complex Scenario / 专项场景 | `references/scenarios/INDEX.md` → 命中 `SC-*.md` | 专项硬规则**只读 SC**，不回读 ROUTING/RULES/FIELD_BACKFILL 中的重复展开 |

## 运行时禁读

下列文件**不要在运行时加载**，仅历史溯源用：

- `references/D_experience/_archive/*`：已归档的老经验层（`business_glossary`、`table_routing`、`cdap_global_rules`、`anti_patterns`、`field_backfill`）。内容已并入 `ROUTING.md` / `FIELD_BACKFILL.md` / `RULES.md`。
- `references/D_experience/lessons_learned.md`：仅复盘日志，不参与运行时决策。
- `references/MAINTENANCE.md`：知识库维护准则（维护者查阅），不参与运行时决策。
- `references/verified-cases/*.md`（除 `INDEX.md` 外）：仅当用户需求与 `INDEX.md` 中某案例「适用」列高度匹配时再打开命中案例，不要批量预读。
- `references/scenarios/*.md`（除 `INDEX.md` 外）：仅当用户需求与 `INDEX.md` 中某场景「适用」列高度匹配时再打开命中场景，不要批量预读。
- 任何 `*-workspace/`：评测/迭代工作区，不属于运行时资产。

## 路径选择（先判定）

收到用户需求后，先做「需求拆解与澄清」，再按缺口大小选择路径。不要因为信息略有缺失就自动进入完整 6 步；先问会改变 SQL 的关键问题。

| 触发条件 | 路径 | 处理 |
|----------|------|------|
| 信息足够，主表/口径/输出无明显歧义 | **直接方案确认** | 用 5 行以内说明主表、口径、输出、过滤、是否补表；用户确认后写 SQL |
| 只缺少少量关键条件 | **轻量澄清** | 只问 1-3 个会改变 SQL 的问题；用户回答后进入方案确认 |
| 主表、口径、字段语义或补表路径有明显歧义 | **标准确认** | 分阶段确认主表、口径、字段、补表；每阶段只展开必要信息 |
| 多主表 / 外部维表 / 按年或按段编排 / 种子驱动 / 含 UNION / 需求方可能改中间结果 | **复杂 CTAS 流程** | 先确认编排方案，再按过程表流水线生成 SQL 和血缘 |
| 用户明确说「直接给 SQL」「不要分步」且需求清楚 | **直接生成** | 直接写 SQL；SQL 头部注释标注主表、口径来源和默认假设 |

所有路径都必须保留 SQL 生成后的审计；轻量澄清不是省略审计。

## 分步确认协议

确认输出按风险裁剪：用户入口短，内部检查完整。用户修正前置结论时，回到对应步骤重做，不要把旧假设带入 SQL。

| 阶段 | 输出块 | 何时展开 | 必须包含 |
|------|--------|----------|----------|
| 1 需求拆解与澄清 | `需求澄清` | 每次需求第一步 | 查什么、查谁、时间、结果形式、业务限制；缺口最多追问 3 个 |
| 2 方案确认 | `方案确认` | 信息足够或轻量澄清完成后 | 主表、口径、输出、过滤、是否补表、关键默认假设 |
| 3 主表选择 | `主表确认` | 主表低置信度或多表都合理时 | 拟用主表、生产表名、表文档、选表理由、必要备选表 |
| 4 口径确认 | `业务口径确认` | 标准指标/动作状态/时间口径会改变结果时 | 口径名称、技术条件、时间字段、码值、来源、待确认项 |
| 5 字段与补表确认 | `字段/补表确认` | 字段语义不明、主表缺字段或 JOIN 有风险时 | 需求字段、候选字段、补表、JOIN 键、粒度、行数风险 |
| 6 SQL 审计 | `SQL + 审计确认` | 最终交付 | SQL、字段来源、口径来源、审计通过项、风险项、**自检 SQL**；复杂场景另附过程表血缘 |

第一轮禁止输出完整主表确认表、字段映射表、补表表格或 SQL。只有低置信度、有歧义或用户要求展开时，才展示备选表、不选择的表、字段血缘和 JOIN 风险。

## 六步流程

### 1. 需求拆解与澄清

第一步必做，但只做轻量澄清。先用业务口语理解用户需求，再内部映射到 SQL 要素；不要要求用户提供表名、JOIN 键或字段名，除非用户已经用技术语言描述。

业务澄清 5 问：

- 查什么：数量、金额、积分、比例，还是明细。
- 查谁：宽带、移动、销售品、订单、收入、积分、某批号码 / `serv_id`。
- 按什么时间算：受理、竣工、开通、出账、拆机，还是账期快照。
- 怎么出结果：全量汇总、按维度分组，还是明细字段。
- 有什么限制：产品、客户、状态、区域、是否排除撤单作废、指定主表 / 口径。

第一轮只追问会改变 SQL 结果的缺口，最多 3 个问题；能按 CDAP 经验合理默认的内容，先写为“默认假设”，不要拿来追问。信息足够时，不追问，直接进入“方案确认”。

输出格式：

```text
我先按这个理解：
- 查什么：
- 查谁：
- 时间：
- 结果：
- 默认假设：

还差这几个会影响 SQL 的点：
1. ...
2. ...
```

内部 SQL 要素检查（不作为第一轮用户问题）：落 SQL 前确认 `SELECT`、`WHERE`、聚合 / `GROUP BY`、`JOIN` / 补表、输出控制是否齐全；只有缺口会改变结果时再问用户。

### 2. Schema Linking / 主表选择

优先级：用户确认 > 标准指标 > `ROUTING.md` > `TABLE_INDEX.md`（仅查 Hive 名/file_path）> 表文档。

规则：主表由业务事实决定；用户已指定主表则跳过泛化路由；生产表名漂移须让用户校对。低置信度时输出「主表确认」块（见分步确认协议 §3），含拟用主表、最多 2 张备选表及不选表原因。

### 3. Business Semantics / 口径确认

命中以下词时必须先确认口径：新装、入网、发展量、订购、互换、竣工、到达、在网、出账、有效、活跃、拆机、销户、续约、降档、收入、积分、怎么算、匹配规则。

检索顺序：标准指标（`METRIC_INDEX` + 单指标文件）→ 主表附注 → `ROUTING.md` → verified case → 标注「未找到稳定口径」请用户确认。需展开时输出「业务口径确认」块（见分步确认协议 §4）。

### 4. Column Linking / 字段映射

只加载已确认主表的表文档。逐个输出：

`需求字段 -> 主表候选字段 -> 是否满足 -> 来源说明`

规则：

- 主表已有且语义明确：直接取。
- 主表有多个候选字段：列候选，让用户确认。
- 主表只有 ID 没有名称：进入补表。
- 表 md 未列字段但业务上可能存在：提示需用户或生产 `DESC` 核对。
- 不要先猜“直销客户编码”“客户编码”“受理人”“协销人”对应哪个字段。

需展开时输出「字段映射确认」块（见分步确认协议 §5）。

### 5. Join Planning / 缺口补表

只有主表缺字段或只有 ID/编码缺名称时才补表。读取 `FIELD_BACKFILL.md` 和必要的补表文档。

补表方案必须说明：

- 缺口字段。
- 补哪张表。
- JOIN 键。
- 补表粒度。
- 是否可能放大行数。
- 必要过滤，例如销售品维表 `city_id=200`、机构维表 `org_id + levs`。
- 命中专项场景时，`FIELD_BACKFILL.md` 仅作路由指针，完整步骤读 `SC-*.md`。

需展开时输出「补表确认」块（见分步确认协议 §5）。

### 6. SQL Generation + Review

用户确认方案或关键歧义已消除后再写 SQL。生成前读取 `references/RULES.md`，按其中「SQL 编排模式」选择单 SELECT、CTAS 流水线或 WITH 例外；SQL 写法、过程表血缘、审计清单和自检 SQL 均以 `RULES.md` 为唯一规则权威。

执行要求：

- 简单需求直接写 SQL；复杂需求先按 `RULES.md` 判定是否需要 CTAS 流水线。
- 若需求命中专项场景，按 `references/scenarios/INDEX.md` 只打开命中 `SC-*.md`，把场景自检并入最终审计。
- 最终必须输出完整 SQL、字段来源、口径来源、审计结果、风险项和自检 SQL。
- 复杂 CTAS 交付必须附过程表血缘；WITH 例外必须说明「无过程表，不可分段改」。
- 自检结果异常时，回到对应阶段修正口径、字段或补表，不要带病交付。

## 输出格式

每个确认阶段使用短表格或短清单，最后交付包含：

1. 完整 SQL（复杂场景为 CTAS 流水线多段脚本，非单条 `WITH`）。
2. 主表、补表和关键字段说明。
3. 需求字段与来源字段对照。
4. 核心过滤和业务口径说明。
5. 来源标注：指标文件、表文档、路由、字典、verified case 或假设。
6. 性能说明：分区、JOIN 风险、数据量风险。
7. 自检 SQL：按 `RULES.md`「自检 SQL」裁剪，至少覆盖样例、量级、空分区、JOIN 炸行、关键字段质量中适用项。
8. **复杂场景**：过程表血缘表（步骤、表名、用途、上游、过滤、验收 SQL）。
9. 待确认项：只列真正会影响结果的事项。

## 冲突优先级

1. 用户确认过的生产表名、字段和口径。
2. 单指标文件中的技术口径 SQL。
3. 表文档 frontmatter、字段说明和条件速查。
4. `ROUTING.md`、`FIELD_BACKFILL.md`、`RULES.md`。
5. `verified-cases/`。
6. 自由推理，必须标注为假设。

## 回填原则

维护者完整落点表见 `references/MAINTENANCE.md`（运行时禁读）。任务结束后只回填会复用、会影响正确性的经验：

- 新业务术语或选表经验：补 `references/ROUTING.md`（术语映射 / 主表路由表 / 术语→字段反查）。
- 新字段补表规则：补 `references/FIELD_BACKFILL.md`。
- 新硬规则或反模式：补 `references/RULES.md`（通用审计清单）；**专项链路只回填 `scenarios/`，不在 ROUTING/RULES/FIELD_BACKFILL 写长规则**。
- 新码值：补对应 `references/D_experience/dictionaries/{field}.md`。
- 新复杂专项链路、附件驱动流程或跨表诊断：优先补 `references/scenarios/SC-*.md`，并在 `references/scenarios/INDEX.md` 加一行；核心文件只保留短入口。
- 新案例模板：在 `references/verified-cases/` 加 `VC-YYYYMMDD-NNN_<语义>.md`，并在 `verified-cases/INDEX.md` 加一行（注明「适用 / 不适用」）。
- 只作为复盘的内容放 `references/D_experience/lessons_learned.md`，不要运行时加载。
- **不要**回填到 `references/D_experience/_archive/`：那是已归档的老 D 层，不参与运行时。
