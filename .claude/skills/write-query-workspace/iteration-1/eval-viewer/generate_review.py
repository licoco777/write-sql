"""
@file generate_review.py
@description 读取 benchmark.json + 各 eval 的 SQL 输出，生成静态 HTML 评测报告。

依赖：Python 3.8+，仅标准库。
用法：
    python generate_review.py \
        --workspace .claude/skills/write-query-workspace/iteration-1 \
        --previous-workspace .claude/skills/write-query-workspace/iteration-0  # 可选
"""
from __future__ import annotations

import argparse
import html
import json
import sys
from pathlib import Path
from typing import Any


def load_json(path: Path) -> dict[str, Any] | None:
    if not path.exists():
        return None
    with path.open("r", encoding="utf-8") as fp:
        return json.load(fp)


def read_sql(workspace: Path, eval_id: str, group: str) -> str:
    path = workspace / eval_id / group / "outputs" / "answer.sql"
    if path.exists():
        return path.read_text(encoding="utf-8")
    return "(无输出)"


def render_assertion_row(assertion: dict[str, Any]) -> str:
    status = "PASS" if assertion["passed"] else ("FAIL-MUST" if assertion["must"] else "FAIL-SOFT")
    cls = "pass" if assertion["passed"] else ("fail-must" if assertion["must"] else "fail-soft")
    return (
        f'<tr class="{cls}">'
        f'<td>{html.escape(assertion["id"])}</td>'
        f'<td>{html.escape(assertion["desc"])}</td>'
        f'<td>{"必过" if assertion["must"] else "软规则"}</td>'
        f'<td><span class="badge {cls}">{status}</span></td>'
        f'<td>{html.escape(assertion["note"])}</td>'
        f"</tr>"
    )


def render_eval_block(workspace: Path, item: dict[str, Any]) -> str:
    eval_id = item["eval_id"]
    title = item["title"]
    tier = item["tier"]

    blocks: list[str] = [
        f'<section class="eval" id="{html.escape(eval_id)}">',
        f'<h2>{html.escape(eval_id)} · {html.escape(title)} <small class="tier">{html.escape(tier)}</small></h2>',
    ]

    for group_name, group_label in (("with_skill", "With Skill"), ("without_skill", "Without Skill")):
        stats = item["groups"].get(group_name, {})
        score = stats.get("score", 0.0)
        passed = stats.get("passed_count", 0)
        total = stats.get("total", 0)
        must_failed = stats.get("must_failed", 0)
        status = stats.get("status", "missing")
        sql = read_sql(workspace, eval_id, group_name)

        cls = "ok" if status == "pass" else ("missing" if status == "missing" else "bad")
        score_pct = f"{int(round(score * 100))}%"

        rows = ""
        for assertion in stats.get("assertion_results", []):
            rows += render_assertion_row(assertion)

        blocks.append(
            f"""
            <div class="group">
              <div class="group-header">
                <h3>{group_label}</h3>
                <span class="score {cls}">得分 {score_pct} · 通过 {passed}/{total} · 必过失败 {must_failed} · 状态 {status}</span>
              </div>
              <details>
                <summary>查看断言明细</summary>
                <table class="assertions">
                  <thead><tr><th>ID</th><th>描述</th><th>等级</th><th>结果</th><th>备注</th></tr></thead>
                  <tbody>{rows or '<tr><td colspan="5">无断言记录</td></tr>'}</tbody>
                </table>
              </details>
              <details>
                <summary>查看生成的 SQL（{len(sql)} 字符）</summary>
                <pre><code>{html.escape(sql)}</code></pre>
              </details>
            </div>
            """
        )

    blocks.append("</section>")
    return "\n".join(blocks)


def render_summary_table(summary: dict[str, Any]) -> str:
    rows = []
    for group, stats in summary.items():
        rows.append(
            f"<tr><td>{group}</td><td>{stats['passed']}</td><td>{stats['failed']}</td>"
            f"<td>{stats['missing']}</td><td>{stats['avg_score']:.2%}</td></tr>"
        )
    return f"""
    <table class="summary">
      <thead><tr><th>分组</th><th>通过</th><th>失败</th><th>缺失</th><th>平均得分</th></tr></thead>
      <tbody>{''.join(rows)}</tbody>
    </table>
    """


def render_diff_summary(curr: dict[str, Any], prev: dict[str, Any] | None) -> str:
    if not prev:
        return ""
    rows = []
    for group, stats in curr.items():
        old = prev.get(group, {})
        delta = stats["avg_score"] - old.get("avg_score", 0.0)
        sign = "+" if delta > 0 else ""
        rows.append(
            f"<tr><td>{group}</td>"
            f"<td>{old.get('avg_score', 0):.2%}</td>"
            f"<td>{stats['avg_score']:.2%}</td>"
            f"<td class='{ 'pass' if delta >= 0 else 'fail-must' }'>{sign}{delta:.2%}</td></tr>"
        )
    return f"""
    <h3>与上一轮对比</h3>
    <table class="summary">
      <thead><tr><th>分组</th><th>上一轮 avg</th><th>本轮 avg</th><th>变化</th></tr></thead>
      <tbody>{''.join(rows)}</tbody>
    </table>
    """


def build_html(workspace: Path, benchmark: dict[str, Any], previous_benchmark: dict[str, Any] | None) -> str:
    summary_html = render_summary_table(benchmark["summary"])
    diff_html = render_diff_summary(benchmark["summary"], previous_benchmark["summary"] if previous_benchmark else None)
    eval_blocks = "\n".join(render_eval_block(workspace, item) for item in benchmark["results"])

    return f"""<!doctype html>
<html lang="zh-CN">
<head>
<meta charset="utf-8" />
<title>write-query evals · {html.escape(benchmark.get('workspace', ''))}</title>
<style>
:root {{
  --pass: #1f883d; --fail: #cf222e; --warn: #bf8700; --bg: #f6f8fa; --fg: #1f2328;
}}
body {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; margin: 0; padding: 24px; background: var(--bg); color: var(--fg); }}
header {{ background: #fff; padding: 16px 24px; border: 1px solid #d0d7de; border-radius: 8px; margin-bottom: 24px; }}
header h1 {{ margin: 0 0 8px; font-size: 22px; }}
table {{ border-collapse: collapse; width: 100%; background: #fff; margin: 12px 0; border: 1px solid #d0d7de; border-radius: 8px; overflow: hidden; }}
th, td {{ padding: 8px 12px; border-bottom: 1px solid #d0d7de; text-align: left; vertical-align: top; font-size: 14px; }}
th {{ background: #f0f3f6; font-weight: 600; }}
section.eval {{ background: #fff; padding: 16px 24px; border: 1px solid #d0d7de; border-radius: 8px; margin-bottom: 16px; }}
section.eval h2 {{ margin-top: 0; font-size: 18px; }}
section.eval h2 .tier {{ background: #ddf4ff; color: #0969da; padding: 2px 8px; border-radius: 8px; font-size: 12px; margin-left: 8px; }}
.group {{ margin: 12px 0; border-top: 1px solid #eaeef2; padding-top: 12px; }}
.group-header {{ display: flex; justify-content: space-between; align-items: center; }}
.group-header h3 {{ margin: 0; font-size: 16px; }}
.score.ok {{ color: var(--pass); }}
.score.bad {{ color: var(--fail); }}
.score.missing {{ color: var(--warn); }}
details {{ margin: 8px 0; }}
summary {{ cursor: pointer; padding: 4px 0; color: #0969da; }}
.badge {{ padding: 2px 8px; border-radius: 6px; font-size: 12px; }}
.badge.pass {{ background: #dafbe1; color: var(--pass); }}
.badge.fail-must {{ background: #ffebe9; color: var(--fail); }}
.badge.fail-soft {{ background: #fff8c5; color: var(--warn); }}
tr.pass td {{ background: #f6fff7; }}
tr.fail-must td {{ background: #fff5f5; }}
tr.fail-soft td {{ background: #fffaef; }}
pre {{ background: #0d1117; color: #d1d7e0; padding: 16px; border-radius: 8px; overflow: auto; max-height: 480px; }}
code {{ font-family: 'SFMono-Regular', Menlo, Consolas, monospace; font-size: 13px; }}
</style>
</head>
<body>
<header>
  <h1>write-query evals · {html.escape(benchmark.get('workspace', ''))}</h1>
  <div>skill: <code>{html.escape(benchmark.get('skill_path', ''))}</code></div>
</header>

<h2>汇总</h2>
{summary_html}

{diff_html}

<h2>逐 eval 明细</h2>
{eval_blocks}

</body>
</html>
"""


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="write-query evals viewer")
    parser.add_argument(
        "--workspace",
        default=".claude/skills/write-query-workspace/iteration-1",
        help="evals 工作区路径（包含 benchmark.json）",
    )
    parser.add_argument(
        "--previous-workspace",
        default=None,
        help="上一轮 workspace（可选），用于 diff 对比",
    )
    parser.add_argument(
        "--out",
        default=None,
        help="HTML 输出文件（默认 workspace/eval-viewer/index.html）",
    )
    args = parser.parse_args(argv)

    workspace = Path(args.workspace).resolve()
    benchmark = load_json(workspace / "benchmark.json")
    if benchmark is None:
        print(f"[viewer] 缺少 benchmark.json，请先运行 grader.py", file=sys.stderr)
        return 1

    previous = None
    if args.previous_workspace:
        previous_workspace = Path(args.previous_workspace).resolve()
        previous = load_json(previous_workspace / "benchmark.json")

    html_str = build_html(workspace, benchmark, previous)
    out_path = Path(args.out) if args.out else (workspace / "eval-viewer" / "index.html")
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(html_str, encoding="utf-8")
    print(f"[viewer] HTML 报告已写出: {out_path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
