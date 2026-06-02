"""
@file grader.py
@description 静态断言评分器：根据 evals.json 中的硬规则，
             对每个 eval 的 with_skill/without_skill 输出 SQL 文件做正则匹配判分，
             聚合输出 benchmark.json。

依赖：Python 3.8+，仅标准库。
用法：
    python grader.py --workspace .claude/skills/write-query-workspace/iteration-1
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any


def load_evals(workspace: Path) -> dict[str, Any]:
    """读取 evals.json 配置。"""
    evals_path = workspace / "evals.json"
    if not evals_path.exists():
        raise FileNotFoundError(f"未找到 evals 配置: {evals_path}")
    with evals_path.open("r", encoding="utf-8") as fp:
        return json.load(fp)


def read_output_sql(workspace: Path, eval_id: str, group: str) -> str | None:
    """读取某 eval 在 with_skill/without_skill 组下的 SQL 输出。

    约定文件路径：<workspace>/<eval_id>/<group>/outputs/answer.sql
    若没找到则返回 None。
    """
    primary = workspace / eval_id / group / "outputs" / "answer.sql"
    if primary.exists():
        return primary.read_text(encoding="utf-8")
    return None


_LINE_COMMENT = re.compile(r"--[^\n]*")
_BLOCK_COMMENT = re.compile(r"/\*[\s\S]*?\*/")


def strip_sql_comments(sql: str) -> str:
    """剥离 SQL 注释（-- 行注释、/* */ 块注释），仅保留可执行 SQL 主体。

    用于「不应出现 X」类负向断言：避免把 SQL 注释里"特意说明不用 X"误判为违反。
    """
    sql = _BLOCK_COMMENT.sub("", sql)
    sql = _LINE_COMMENT.sub("", sql)
    return sql


def evaluate_assertion(sql: str, assertion: dict[str, Any]) -> tuple[bool, str]:
    """对单条断言做评估，返回 (是否通过, 备注)。

    `regex_not_match` 类断言会先剥离 SQL 注释再匹配，避免注释里"说明性提及"被误判。
    """
    kind = assertion["kind"]
    pattern = assertion.get("pattern", "")
    try:
        regex = re.compile(pattern, re.MULTILINE)
    except re.error as exc:
        return False, f"正则编译失败: {exc}"

    if kind == "regex_not_match":
        body = strip_sql_comments(sql)
        matches = list(regex.finditer(body))
        passed = not matches
        return passed, "未命中（符合预期）" if passed else f"SQL 主体出现 {len(matches)} 次（违反）"

    matches = list(regex.finditer(sql))

    if kind == "regex_match":
        passed = bool(matches)
        return passed, f"命中 {len(matches)} 处" if passed else "未命中"
    if kind == "regex_count_gte":
        threshold = int(assertion.get("min", 1))
        passed = len(matches) >= threshold
        return passed, f"命中 {len(matches)} 次（要求 >= {threshold}）"
    return False, f"未知 kind: {kind}"


def grade_eval(workspace: Path, eval_def: dict[str, Any]) -> dict[str, Any]:
    """对单个 eval 在 with_skill / without_skill 两组分别打分。"""
    eval_id = eval_def["id"]
    result: dict[str, Any] = {
        "eval_id": eval_id,
        "title": eval_def.get("title", ""),
        "tier": eval_def.get("tier", ""),
        "groups": {},
    }

    for group in ("with_skill", "without_skill"):
        sql = read_output_sql(workspace, eval_id, group)
        if sql is None:
            result["groups"][group] = {
                "status": "missing",
                "score": 0.0,
                "passed_count": 0,
                "total": len(eval_def["assertions"]),
                "must_failed": 0,
                "assertion_results": [],
                "note": "缺少 outputs/answer.sql",
            }
            continue

        assertion_results = []
        passed_count = 0
        must_failed = 0
        for assertion in eval_def["assertions"]:
            passed, note = evaluate_assertion(sql, assertion)
            assertion_results.append(
                {
                    "id": assertion["id"],
                    "desc": assertion.get("desc", ""),
                    "must": assertion.get("must", False),
                    "passed": passed,
                    "note": note,
                }
            )
            if passed:
                passed_count += 1
            elif assertion.get("must", False):
                must_failed += 1

        total = len(eval_def["assertions"])
        score = passed_count / total if total else 0.0
        status = "pass" if must_failed == 0 and score >= 0.7 else "fail"

        result["groups"][group] = {
            "status": status,
            "score": round(score, 4),
            "passed_count": passed_count,
            "total": total,
            "must_failed": must_failed,
            "assertion_results": assertion_results,
            "sql_chars": len(sql),
        }

    return result


def aggregate(report: list[dict[str, Any]]) -> dict[str, Any]:
    """聚合所有 eval 的得分。"""
    summary = {
        "with_skill": {"passed": 0, "failed": 0, "missing": 0, "avg_score": 0.0},
        "without_skill": {"passed": 0, "failed": 0, "missing": 0, "avg_score": 0.0},
    }
    score_sum = {"with_skill": 0.0, "without_skill": 0.0}
    counted = {"with_skill": 0, "without_skill": 0}

    for item in report:
        for group, stats in item["groups"].items():
            if stats["status"] == "missing":
                summary[group]["missing"] += 1
                continue
            if stats["status"] == "pass":
                summary[group]["passed"] += 1
            else:
                summary[group]["failed"] += 1
            score_sum[group] += stats["score"]
            counted[group] += 1

    for group in ("with_skill", "without_skill"):
        if counted[group]:
            summary[group]["avg_score"] = round(score_sum[group] / counted[group], 4)

    return summary


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="write-query evals grader")
    parser.add_argument(
        "--workspace",
        default=".claude/skills/write-query-workspace/iteration-1",
        help="evals 工作区路径",
    )
    parser.add_argument(
        "--out",
        default=None,
        help="benchmark.json 输出路径（默认 workspace/benchmark.json）",
    )
    args = parser.parse_args(argv)

    workspace = Path(args.workspace).resolve()
    config = load_evals(workspace)

    report = [grade_eval(workspace, eval_def) for eval_def in config["evals"]]
    summary = aggregate(report)

    benchmark = {
        "workspace": config.get("workspace"),
        "skill": config.get("skill"),
        "skill_path": config.get("skill_path"),
        "summary": summary,
        "results": report,
    }

    out_path = Path(args.out) if args.out else (workspace / "benchmark.json")
    out_path.write_text(json.dumps(benchmark, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"[grader] benchmark.json 已写出: {out_path}")
    print(json.dumps(summary, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
