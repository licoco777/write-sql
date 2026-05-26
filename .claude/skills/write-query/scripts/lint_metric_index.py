"""
@file lint_metric_index.py
@description 校验 METRIC_INDEX.md 中每行的 `metric_file` 和 `table_files`
             链接的真实存在性。输出 JSON 报告，发现缺失时退出码非零。

依赖：Python 3.8+，仅标准库。
用法：
    python lint_metric_index.py [--index .claude/skills/write-query/references/METRIC_INDEX.md]
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any


HEADER_PATTERN = re.compile(r"^\|\s*metric_id\s*\|", re.MULTILINE)


def parse_metric_index(text: str) -> list[dict[str, str]]:
    """解析 METRIC_INDEX.md 中的指标行。

    返回每行的字段 dict（含 metric_id, metric_name, ..., table_files, metric_file）。
    """
    lines = text.splitlines()
    header_idx = None
    for idx, line in enumerate(lines):
        if line.strip().startswith("| metric_id"):
            header_idx = idx
            break
    if header_idx is None:
        return []

    header_cols = [c.strip() for c in lines[header_idx].strip("|").split("|")]
    rows: list[dict[str, str]] = []
    for line in lines[header_idx + 2 :]:
        stripped = line.strip()
        if not stripped.startswith("|") or not stripped.endswith("|"):
            break
        cols = [c.strip() for c in stripped.strip("|").split("|")]
        if len(cols) != len(header_cols):
            continue
        rows.append(dict(zip(header_cols, cols)))
    return rows


def check_path(base: Path, relative: str) -> bool:
    """检查 base 路径下的相对路径是否存在。"""
    relative = relative.strip()
    if not relative:
        return False
    relative = relative.replace("\\", "/").lstrip("./")
    return (base / relative).exists()


def split_table_files(cell: str) -> list[str]:
    """table_files 单元格可能含多个路径（顿号/逗号/空白分隔）。

    特殊值「以单指标技术口径 SQL 的 FROM 为准」表示无明确表文档，跳过校验。
    """
    if not cell:
        return []
    if "FROM 为准" in cell or "口径" in cell and "为准" in cell:
        return []
    parts = re.split(r"[、，,;\s]+", cell)
    return [p for p in parts if p]


def lint(index_path: Path) -> dict[str, Any]:
    text = index_path.read_text(encoding="utf-8")
    base_dir = index_path.parent
    rows = parse_metric_index(text)

    findings: list[dict[str, Any]] = []
    metric_missing = 0
    table_missing = 0

    for row in rows:
        mid = row.get("metric_id", "")
        metric_file = row.get("metric_file", "").strip()
        table_files = split_table_files(row.get("table_files", ""))

        if metric_file:
            if not check_path(base_dir, metric_file):
                findings.append(
                    {
                        "metric_id": mid,
                        "kind": "metric_file_missing",
                        "path": metric_file,
                        "severity": "risk",
                    }
                )
                metric_missing += 1
        else:
            findings.append(
                {
                    "metric_id": mid,
                    "kind": "metric_file_empty",
                    "path": "",
                    "severity": "risk",
                }
            )
            metric_missing += 1

        for tf in table_files:
            if not check_path(base_dir, tf):
                findings.append(
                    {
                        "metric_id": mid,
                        "kind": "table_file_missing",
                        "path": tf,
                        "severity": "warn",
                    }
                )
                table_missing += 1

    summary = {
        "total_rows": len(rows),
        "metric_file_missing": metric_missing,
        "table_file_missing": table_missing,
        "passed": metric_missing == 0,
    }
    return {"summary": summary, "findings": findings}


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="校验 METRIC_INDEX.md 引用路径")
    parser.add_argument(
        "--index",
        default=".claude/skills/write-query/references/METRIC_INDEX.md",
        help="METRIC_INDEX.md 路径",
    )
    parser.add_argument("--out", default=None, help="JSON 报告输出（缺省 stdout）")
    args = parser.parse_args(argv)

    index_path = Path(args.index)
    if not index_path.exists():
        print(f"找不到 METRIC_INDEX: {index_path}", file=sys.stderr)
        return 2

    report = lint(index_path)
    report["source"] = str(index_path)
    payload = json.dumps(report, ensure_ascii=False, indent=2)

    if args.out:
        Path(args.out).write_text(payload, encoding="utf-8")
    print(payload)

    return 0 if report["summary"]["passed"] else 1


if __name__ == "__main__":
    sys.exit(main())
