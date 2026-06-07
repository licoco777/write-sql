---
name: sql-case-sedimentation
description: Use when the user wants to沉淀 CDAP/write-query SQL business cases into the write-query skill, especially from docs SQL案例 folders. Guides one-case-at-a-time analysis, user confirmation, and careful updates to ROUTING, TABLE_INDEX, FIELD_BACKFILL, RULES, or verified-cases without blindly copying工单 SQL.
---

# SQL Case Sedimentation

把 CDAP SQL 工单案例逐条拆成可复用的 `write-query` 技能知识。核心原则：**案例是证据，不是知识本身**；进入技能的是稳定的找表、补表、口径和审计规则。

## When Triggered

Use this skill when the user asks to:

- 从 SQL 案例、工单脚本、案例文件夹中“沉淀/迭代/升级 write-query 技能”。
- 一个案例一个案例分析，先确认再写入技能。
- 总结“啥场景找啥表”、补表规则、SQL 审计规则。

Also use it when the user says类似“案例沉淀”“把案例迭代进技能”“先跟我确认再沉淀”。

## Grounding

Before asking the user anything:

1. Read the target SQL case or case folder index.
2. Read only the needed `write-query` references:
   - `ROUTING.md` for scene-to-table routing.
   - `TABLE_INDEX.md` and matching `tables/*.md` for candidate tables.
   - `FIELD_BACKFILL.md` for missing-field joins.
   - `RULES.md` for SQL audit rules.
   - `verified-cases/INDEX.md` only when a complex reusable flow may warrant a case.
3. Check whether the knowledge already exists. Do not duplicate an existing rule under a new name.

## One-Case Confirmation Protocol

Process **one SQL case at a time**. Do not update skill files before the user confirms that case.

For each case, respond in this exact shape:

```text
案例 X：{short title}

源文件：
{path}

我准备沉淀的内容：

1. 用户会怎么问
- ...

2. 应识别的业务场景
- ...

3. 主表路由
- 场景事实在：...
- 应找：...
- 不应找：...

4. 补表规则
- 缺口字段：...
- 补表：...
- JOIN：...
- 必要过滤：...
- 行数风险：...

5. 关键口径 / 过滤 / 审计
- ...

6. 我建议写入
- ROUTING.md：...
- TABLE_INDEX.md / tables/*.md：...
- FIELD_BACKFILL.md：...
- RULES.md：...
- verified-cases：...

7. 不应沉淀
- 一次性附件表：...
- 单客户 / 单项目 / 单批编码：...
- 不稳定 SQL 写法：...

需要你确认：
- ...
```

Wait for user confirmation. If the user corrects a rule, update the proposed sedimentation before editing files.

## What To Sediment

Prefer stable, reusable knowledge:

- **ROUTING.md**: user language → business scene → primary fact table.
- **TABLE_INDEX.md + tables/*.md**: stable tables that should be discoverable by future agents.
- **FIELD_BACKFILL.md**: missing-field join paths, keys, required filters, row-count risks.
- **RULES.md**: generation/review rules such as attachment handling, de-duplication, time windows, month pivoting, sensitive-field masking.
- **verified-cases/**: only complex, high-reuse flows where a rule row is insufficient.

The most important capability is **finding the right table by business scene**, not accumulating scripts.

## What Not To Sediment

Do not write these into runtime knowledge as stable rules:

- One-off attachment table names such as `zone_gz_yz_*`.
- Single customer names, phone numbers, project names, one-time网点/销售品/参数 lists.
- Broken SQL syntax copied from a case.
- A parameter code, product code, or status code unless the user confirms it is a reusable business口径 or it is already verified elsewhere.
- Full scripts inside `RULES.md`; use concise rules or a `verified-case` only when needed.

## Editing Workflow After Confirmation

After the user confirms a case:

1. Edit `.agents/skills/write-query` first.
2. Keep changes scoped to the confirmed case.
3. Add a table document only when the user confirmed the table is stable enough for `TABLE_INDEX.md`.
4. Sync `.agents` to `.claude` with:

```bash
bash scripts/sync_skills.sh sync agents --force
```

5. Verify:

```bash
bash scripts/sync_skills.sh check
python3 .agents/skills/write-query/scripts/lint_metric_index.py --index .agents/skills/write-query/references/METRIC_INDEX.md
```

6. Report exactly what changed and what remains uncommitted. Do not include unrelated files.

## Multi-Case Runs

For a folder of cases:

1. Create or update a review matrix first if none exists.
2. Then proceed case by case using the confirmation protocol.
3. Do not batch-write multiple cases unless the user explicitly changes from “逐案确认” to “分批确认”.

Useful matrix columns:

```text
案例 -> 用户会怎么问 -> 场景标签 -> 主表路由 -> 补表规则 -> 关键过滤 -> 写入位置 -> 不应沉淀 -> 待确认
```

