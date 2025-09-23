#!/usr/bin/env bash
# Fail if any non-binary tracked file has lines > 80 chars.
# Skips code fences? No — we are checking raw width. Use wrapper to format.
# Allows explicit ignores via env var:
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
    | grep -Ev '\.(png|jpg|jpeg|gif|svg|pdf|zip|gz|tgz|ico|mp3|mp4|webm|wav)$'
}

while read -r f; do
  [[ -f "$f" ]] || continue
  if [[ -n "$LENGTH_IGNORE" ]] && echo "$f" | grep -Eq "$LENGTH_IGNORE"; then
    continue
  fi
  # Scan file for long lines
  # Print offending lines with number and length
  if awk -v max="$MAX_COL" 'length($0) > max {print NR ":" length($0) ":" $0 }' "$f" | head -n 1 | grep -q ':'; then
    echo "${red}LINE-LENGTH > ${MAX_COL}${reset} in ${f}"
    awk -v max="$MAX_COL" 'length($0) > max {printf("  L%05d (%d): %s\n", NR, length($0), $0)}' "$f" | head -n 5
    echo "---- tail of $f ----"
    tail -n "$TAIL_LINES" "$f" || true
    echo "---------------------"
    viol=1
  fi
done < <(list_tracked)

if [[ $viol -ne 0 ]]; then
  echo
  echo "${yellow}Hint:${reset} To auto-wrap Markdown safely, run:"
  echo "  APPLY=1 python3 scripts/wrap-markdown.py"
  echo "or"
  echo "  make wrap-md"
  exit 1
fi

echo "✅ All checked files respect <= ${MAX_COL} columns."
