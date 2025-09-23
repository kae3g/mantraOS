#!/usr/bin/env bash
# Global 80-column enforcer (strict).
# Checks ALL tracked files that are not binary.
# Special-case for Markdown: allow code-fence & table-line exemptions only.
# Everything else (including blockquotes) must be <= 80 columns.
# Optional ignores:
#   LENGTH_IGNORE='^docs/legacy/|^assets/.*\.svg$'
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

TAIL_LINES="${TAIL_LINES:-20}"
MAX_COL="${MAX_COL:-80}"
LENGTH_IGNORE="${LENGTH_IGNORE:-}"

red=$(printf '\033[31m'); yellow=$(printf '\033[33m'); reset=$(printf '\033[0m')

viol=0

list_tracked() {
  git ls-files \
    | grep -Ev '^\.(git|github)/' \
    | grep -Ev '(^|/)(node_modules|dist|build|out)/' \
    | grep -Ev '\.(png|jpg|jpeg|gif|svg|pdf|zip|gz|tgz|bz2|xz|ico|mp3|mp4|webm|wav|mov)$'
}

while read -r f; do
  [[ -f "$f" ]] || continue
  if [[ -n "$LENGTH_IGNORE" ]] && echo "$f" | grep -Eq "$LENGTH_IGNORE"; then
    continue
  fi
  case "$f" in
    *.md|*.mdx)
      # Markdown: skip code blocks & tables; everything else must wrap.
      if awk -v max="$MAX_COL" '
        BEGIN{in_code=0}
        {
          line=$0
          if (match(line,/^```/)) { in_code = !in_code; next }
          if (in_code) next
          if (index(line,"|")>0) next
          if (length(line) > max) { print NR ":" length(line) ":" line }
        }
      ' "$f" | head -n 1 | grep -q ':'; then
        echo "${red}LINE-LENGTH > ${MAX_COL}${reset} in ${f}"
        awk -v max="$MAX_COL" '
          BEGIN{in_code=0}
          {
            line=$0
            if (match(line,/^```/)) { in_code = !in_code; next }
            if (in_code) next
            if (index(line,"|")>0) next
            if (length(line) > max) { printf("  L%05d (%d): %s\n", NR, length(line), line) }
          }
        ' "$f" | head -n 10
        echo "---- tail of $f ----"
        tail -n "$TAIL_LINES" "$f" || true
        echo "---------------------"
        viol=1
      fi
      ;;
    *)
      # Non-Markdown: check raw lines (no exemptions)
      if awk -v max="$MAX_COL" 'length($0) > max {print NR ":" length($0) ":" $0 }' "$f" | head -n 1 | grep -q ':'; then
        echo "${red}LINE-LENGTH > ${MAX_COL}${reset} in ${f}"
        awk -v max="$MAX_COL" 'length($0) > max {printf("  L%05d (%d): %s\n", NR, length($0), $0)}' "$f" | head -n 10
        echo "---- tail of $f ----"
        tail -n "$TAIL_LINES" "$f" || true
        echo "---------------------"
        viol=1
      fi
      ;;
  esac
done < <(list_tracked)

if [[ $viol -ne 0 ]]; then
  echo
  echo "${yellow}Hint:${reset} To auto-wrap Markdown safely, run:"
  echo "  APPLY=1 python3 scripts/wrap-markdown.py"
  echo "or"
  echo "  make wrap-md"
  exit 1
fi

echo "✅ All checked files respect <= ${MAX_COL} columns (MD code/table rows exempt)."