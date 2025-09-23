#!/usr/bin/env bash
# List files and line numbers that exceed MAX_COL (default 80).
# Useful before fixing code/config manually in Vim.
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"
MAX_COL="${MAX_COL:-80}"

is_binary() {
  file -b --mime "$1" 2>/dev/null | grep -q 'charset=binary'
}

count=0
while read -r f; do
  [[ -f "$f" ]] || continue
  if is_binary "$f"; then continue; fi
  # Print top 3 longest lines per file
  awk -v max="$MAX_COL" '
    length($0) > max { printf("%s:L%05d (%d): %s\n", FILENAME, NR, length($0), $0) }
  ' "$f" | head -n 3
done < <(git ls-files)

echo "Hint: open offenders with: vim +{line} {file}"
