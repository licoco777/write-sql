---
title: "D 层老文件归档"
status: archived
runtime: false
---

# D_experience/_archive

> **运行时禁读**。本目录是历史 D 层经验文件的归档，仅供历史溯源使用。模型在执行 SKILL 流程时不要加载本目录。

## 归档原因

D 层（D_experience）原本作为「经验回填层」与 A 层（tables/）、B 层（metrics/）、C 层（verified-cases/）并列。但随着 ROUTING.md / FIELD_BACKFILL.md / RULES.md 三个运行时索引建立，D 层的「业务术语 / 路由 / 全局硬规则 / 反 pattern / 字段补表」逐渐与新层重叠并出现漂移。

为了避免「同一规则两份、版本不一致」的运行时困惑，2026-05-21 决定：

- 单源化：以 `references/ROUTING.md`、`references/FIELD_BACKFILL.md`、`references/RULES.md` 为运行时唯一权威。
- D 层经验类老文件搬入本 `_archive/`，只读不改，作为历史日志。
- 仍在 SKILL 第 6 步生效的 `D_experience/dictionaries/{field}.md` 码值字典与 `D_experience/lessons_learned.md` 复盘日志保留在原位置。

## 归档清单

| 老文件 | 取代它的新层 | 漂移要点（如有） |
|--------|-------------|------------------|
| `business_glossary.md` | `references/ROUTING.md`「术语映射 / 时间字段语义 / 客群范围 / 术语→字段反查」 | 已合并 |
| `table_routing.md` | `references/ROUTING.md`「主表路由表」 | 老文件仍保留「选错代价」列；新层未保留该列，但「不要选」「风险/备注」列已覆盖核心 |
| `cdap_global_rules.md` | `references/RULES.md`「选表与字段 / 口径与时间 / 维表与 JOIN / 码值 / SQL 形态」 | 老文件 R001–R010 全部已并入新 RULES |
| `anti_patterns.md` | `references/RULES.md`「专项审计项」「常见风险」 + `references/verified-cases/` 案例 | 新 RULES 不展开列出 AP-NNN；编号仅保留在归档 |
| `field_backfill.md` | `references/FIELD_BACKFILL.md` | 已合并；旧表号（097 / 089 等）漂移在新层未带入 |

## 历史表号漂移说明

老 `table_routing.md` 和 `business_glossary.md` 中存在以下旧表号引用，已在新层修正：

- 098 燃气卫士 / 092 视联网 / 097 基本面月清单 / 089 全量科目级收入 等 → 新层以 `references/tables/{序号}_{表名}.md` 的实际序号为准（如 048、050、057、068 等）。
- 详见 `references/TABLE_INDEX.md`。

## 如何回溯

```bash
git log --follow .claude/skills/write-query/references/D_experience/_archive/anti_patterns.md
git log --follow .claude/skills/write-query/references/D_experience/_archive/cdap_global_rules.md
```

仍可通过 `git show <commit>:<path>` 看到老文件原貌。
