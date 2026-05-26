"""
@file audit_sql.py
@description CDAP write-query SQL 静态审计脚本。
             把 RULES.md 「审计清单」中的硬规则抽成可机检的正则规则，
             对给定 SQL 文件输出 JSON 报告，返回非零退出码表示有 risk 项。

依赖：Python 3.8+，仅标准库。
用法：
    python audit_sql.py <sql_file> [--out <report.json>] [--format json|text]
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Callable, Iterable


@dataclass
class Finding:
    rule_id: str
    severity: str
    message: str
    line: int | None = None
    snippet: str = ""


@dataclass
class Rule:
    rule_id: str
    severity: str
    desc: str
    check: Callable[[str], list[Finding]]


def _line_of(sql: str, pos: int) -> int:
    return sql.count("\n", 0, pos) + 1


def _snippet_around(sql: str, pos: int, width: int = 80) -> str:
    start = max(0, pos - width // 2)
    end = min(len(sql), pos + width // 2)
    return sql[start:end].replace("\n", " ").strip()


_LINE_COMMENT_RE = re.compile(r"--[^\n]*")
_BLOCK_COMMENT_RE = re.compile(r"/\*[\s\S]*?\*/")


def strip_sql_comments_for_audit(sql: str) -> str:
    """剥离 SQL 注释，用空格占位以保持行/列位置不变。

    用于审计：所有规则的正则匹配都基于剥离注释的 SQL 主体；
    保留空格占位是为了 `_line_of` 仍能返回正确行号。
    """
    def _to_space(match: re.Match[str]) -> str:
        return re.sub(r"[^\n]", " ", match.group(0))

    sql = _BLOCK_COMMENT_RE.sub(_to_space, sql)
    sql = _LINE_COMMENT_RE.sub(_to_space, sql)
    return sql


def rule_chinese_placeholder(sql: str) -> list[Finding]:
    """中文/占位符 SQL 字面量识别（仅看 SQL 主体，不看注释）。

    仅匹配真正的"占位"形式，**不**误伤合法中文 SQL 字面量
    （例如 `kd_desc='普通宽带'`、`CASE ... THEN '互联网专线'`）。

    命中条件之一：
    - `'<XX>'`：尖括号包中文（明显占位）
    - `'中文+数字'`：典型占位（如 '销售品编码1'）
    - `<待填>`/`<请补充>`/`<占位>`/`<TBD>`/`<TODO>` 等尖括号关键字
    - 单独的 ``TBD``/``TODO``/``FIXME`` 关键字（带 word 边界）
    """
    findings: list[Finding] = []
    placeholder_patterns = [
        re.compile(r"'\s*<[一-龥A-Za-z]+>\s*'"),
        re.compile(r"'[一-龥]+\d+'"),
        re.compile(r"<\s*(?:待填|请补充|占位符|占位|TBD|TODO|FIXME)\s*>", re.IGNORECASE),
        re.compile(r"(?<![\w])(?:TBD|TODO|FIXME)(?![\w])", re.IGNORECASE),
    ]
    for pat in placeholder_patterns:
        for m in pat.finditer(sql):
            findings.append(
                Finding(
                    rule_id="R001",
                    severity="risk",
                    message=f"疑似占位符 SQL 字面量: {m.group(0).strip()}",
                    line=_line_of(sql, m.start()),
                    snippet=_snippet_around(sql, m.start()),
                )
            )
    return findings


def rule_select_star(sql: str) -> list[Finding]:
    """禁止裸 SELECT *。

    允许：
    - 带别名的 ``SELECT a.*``（join 时常见）
    - 临时表整表合并 ``SELECT * FROM tmp_xxx`` / ``stg_xxx``（CTAS 流水线
      union 同结构临时表是 VC-20260520-001 模板的合法写法）
    """
    findings: list[Finding] = []
    pattern = re.compile(
        r"(?im)(?<![\w])select\s+\*(?![\w])(?:\s+from\s+(?P<from>[\w\.]+))?"
    )
    for m in pattern.finditer(sql):
        from_table = (m.group("from") or "").lower()
        if from_table:
            # 整表导入临时表/staging 表允许
            short = from_table.split(".")[-1]
            if short.startswith(("tmp_", "stg_", "stage_")):
                continue
        findings.append(
            Finding(
                rule_id="R002",
                severity="risk",
                message="使用 SELECT * — 应明列字段（SELECT a.* / 整表导入 tmp_* / stg_* 允许）",
                line=_line_of(sql, m.start()),
                snippet=_snippet_around(sql, m.start()),
            )
        )
    return findings


def rule_offer_dim_city_id(sql: str) -> list[Finding]:
    """销售品维表 dws_offer / 产品维表 dws_product JOIN 后未跟 city_id=200。"""
    findings: list[Finding] = []
    pattern = re.compile(r"(?is)\bjoin\b[^;]{0,400}\b(dws_offer|dws_product)\b([^;]{0,400})")
    for m in pattern.finditer(sql):
        tail = m.group(0)
        if not re.search(r"city_id\s*=\s*200\b", tail):
            findings.append(
                Finding(
                    rule_id="R003",
                    severity="risk",
                    message=f"维表 {m.group(1)} JOIN 后未限定 city_id=200，跨城重号风险",
                    line=_line_of(sql, m.start()),
                    snippet=_snippet_around(sql, m.start(), 160),
                )
            )
    return findings


def rule_zh_status_literal(sql: str) -> list[Finding]:
    """状态/动作 WHERE 使用中文术语（subs_stat / action_type 等）。"""
    findings: list[Finding] = []
    pattern = re.compile(
        r"(?i)\b(subs_stat|action_type|action_name|stat_name)\s*(?:=|IN)\s*\(?\s*'\s*[一-龥]+\s*'"
    )
    for m in pattern.finditer(sql):
        findings.append(
            Finding(
                rule_id="R004",
                severity="risk",
                message=f"{m.group(1)} 字段比较使用了中文术语，应改为码值或字典 JOIN",
                line=_line_of(sql, m.start()),
                snippet=_snippet_around(sql, m.start()),
            )
        )
    return findings


def rule_069_old_prefix(sql: str) -> list[Finding]:
    """069 老前缀 ads_yz_tb_comm_cm_all_final / ads_yz_tb_comm_cm_all_mon_final。"""
    findings: list[Finding] = []
    pattern = re.compile(r"(?i)\bads_yz_tb_comm_cm_all_(?:mon_)?final\b")
    for m in pattern.finditer(sql):
        findings.append(
            Finding(
                rule_id="R005",
                severity="risk",
                message=(
                    f"069 表名 {m.group(0)} 为旧前缀，生产应使用 "
                    "dwm_yz_tb_comm_cm_all_final（日表）或 dwm_yz_tb_comm_cm_all_mon_final（月表）"
                ),
                line=_line_of(sql, m.start()),
                snippet=_snippet_around(sql, m.start()),
            )
        )
    return findings


def rule_ctas_missing_drop_purge(sql: str) -> list[Finding]:
    """CTAS（create table ... as select ...）漏 drop table if exists ... purge。

    简单启发：每个 `create table <name> ... as select` 之前必须能找到针对同名表的
    `drop table if exists <name> purge`。
    """
    findings: list[Finding] = []
    ctas_pattern = re.compile(
        r"(?is)create\s+table\s+(?P<name>[\w\.]+)[\s\S]*?\bas\s+select\b"
    )
    for m in ctas_pattern.finditer(sql):
        name = m.group("name")
        start = m.start()
        head = sql[:start]
        drop_pattern = re.compile(
            r"(?i)drop\s+table\s+if\s+exists\s+" + re.escape(name) + r"\s+purge\s*;"
        )
        if not drop_pattern.search(head):
            findings.append(
                Finding(
                    rule_id="R006",
                    severity="risk",
                    message=f"CTAS 目标表 {name} 在 CREATE 前缺少 `drop table if exists {name} purge;`",
                    line=_line_of(sql, m.start()),
                    snippet=_snippet_around(sql, m.start(), 120),
                )
            )
    return findings


def rule_subs_stat_reason_filter(sql: str) -> list[Finding]:
    """动作类统计常忘记排除撤单作废 subs_stat_reason IN ('1200','1300')。

    启发：SQL 含 action_id IN (...) 或 action_id = ... 且引用了销售品/订单类表，
    但未出现 subs_stat_reason NOT IN ('1200','1300') 模式 → 给 warn。
    """
    findings: list[Finding] = []
    if re.search(r"(?i)\baction_id\s*(?:=|IN)\b", sql):
        if not re.search(
            r"(?i)subs_stat_reason[\s\S]{0,40}NOT\s+IN\s*\(\s*['\"](?:1200|1300)['\"]",
            sql,
        ):
            findings.append(
                Finding(
                    rule_id="R007",
                    severity="warn",
                    message="存在 action_id 过滤但未见 subs_stat_reason NOT IN ('1200','1300') 撤单作废排除",
                    line=None,
                    snippet="",
                )
            )
    return findings


def rule_select_star_excl_alias_dot(sql: str) -> list[Finding]:
    """裸 SELECT *（但允许 SELECT a.*）— 已被 rule_select_star 覆盖，此处不重复。

    保留接口以便未来扩展。
    """
    return []


def build_rules() -> list[Rule]:
    return [
        Rule("R001", "risk", "禁止中文/占位符字面量", rule_chinese_placeholder),
        Rule("R002", "risk", "禁止裸 SELECT *", rule_select_star),
        Rule("R003", "risk", "销售品/产品维表必须 city_id=200", rule_offer_dim_city_id),
        Rule("R004", "risk", "状态/动作字段不得与中文术语比较", rule_zh_status_literal),
        Rule("R005", "risk", "069 表必须用 dwm_* 前缀", rule_069_old_prefix),
        Rule("R006", "risk", "CTAS 必须前置 drop table if exists ... purge", rule_ctas_missing_drop_purge),
        Rule("R007", "warn", "动作类统计应排除撤单作废", rule_subs_stat_reason_filter),
    ]


def audit_sql(sql: str, rules: Iterable[Rule]) -> dict:
    # 所有规则统一基于"剥离注释后的 SQL 主体"做匹配，避免注释里
    # 的解释性文字被误判（保留空格占位以维持行号）。
    sql_body = strip_sql_comments_for_audit(sql)
    findings: list[Finding] = []
    for rule in rules:
        findings.extend(rule.check(sql_body))

    risk_count = sum(1 for f in findings if f.severity == "risk")
    warn_count = sum(1 for f in findings if f.severity == "warn")

    return {
        "summary": {
            "total": len(findings),
            "risk": risk_count,
            "warn": warn_count,
            "passed": risk_count == 0,
        },
        "findings": [
            {
                "rule_id": f.rule_id,
                "severity": f.severity,
                "message": f.message,
                "line": f.line,
                "snippet": f.snippet,
            }
            for f in findings
        ],
        "rules_checked": [
            {"rule_id": r.rule_id, "severity": r.severity, "desc": r.desc} for r in rules
        ],
    }


def format_text(report: dict) -> str:
    lines: list[str] = []
    s = report["summary"]
    lines.append(f"== audit_sql 报告 == 总计 {s['total']} 条 / risk={s['risk']} warn={s['warn']} passed={s['passed']}")
    for f in report["findings"]:
        prefix = "RISK" if f["severity"] == "risk" else "WARN"
        loc = f"line {f['line']}" if f["line"] else "-"
        lines.append(f"[{prefix}] {f['rule_id']} @ {loc} | {f['message']}")
        if f["snippet"]:
            lines.append(f"    > {f['snippet']}")
    return "\n".join(lines)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="CDAP write-query SQL 静态审计")
    parser.add_argument("sql_file", help="待审计的 SQL 文件路径")
    parser.add_argument("--out", default=None, help="JSON 报告输出路径（缺省打印到 stdout）")
    parser.add_argument(
        "--format",
        choices=["json", "text"],
        default="text",
        help="stdout 输出格式（json 报告同时也会按 --out 落盘）",
    )
    args = parser.parse_args(argv)

    path = Path(args.sql_file)
    if not path.exists():
        print(f"找不到 SQL 文件: {path}", file=sys.stderr)
        return 2

    sql = path.read_text(encoding="utf-8")
    rules = build_rules()
    report = audit_sql(sql, rules)
    report["source_file"] = str(path)

    if args.out:
        Path(args.out).write_text(
            json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8"
        )

    if args.format == "json":
        print(json.dumps(report, ensure_ascii=False, indent=2))
    else:
        print(format_text(report))

    return 0 if report["summary"]["risk"] == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
