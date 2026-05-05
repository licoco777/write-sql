#!/bin/bash
SCRIPT="/Users/bozi/.claude/skills/excel-to-markdown/scripts/excel_to_markdown_general.py"
INPUT_DIR="CDAP清单拆分"
OUTPUT_DIR="CDAP清单拆分_md"

mkdir -p "$OUTPUT_DIR"

count=0
for f in "$INPUT_DIR"/*.xlsx; do
  filename=$(basename "$f")

  # 排除 069 序号
  if [[ "$filename" == 069_* ]]; then
    echo "跳过: $filename"
    continue
  fi

  md_name="${filename%.xlsx}.md"
  echo "转换: $filename -> $md_name"
  uv run --with openpyxl python "$SCRIPT" "$f" -o "$OUTPUT_DIR/$md_name"
  count=$((count + 1))
done

echo ""
echo "完成，共转换 $count 个文件"
echo "输出目录: $OUTPUT_DIR"