#!/usr/bin/env bash
# Purpose: One-off cleanup — replace any lingering "Bhagavad Gita" references
# with: "Śrīmad-Bhāgavatam (Uddhava Gītā, Canto 11)" across text-like files.
# Dry-run by default; set APPLY=1 to write changes.
#
# Usage:
#   bash scripts/purge-bhagavad-gita.sh           # dry-run (report only)
#   APPLY=1 bash scripts/purge-bhagavad-gita.sh   # apply replacements
#   APPLY=1 EXTS="md,mdx,txt,yml" bash scripts/purge-bhagavad-gita.sh
#
# Notes:
# - This script is intentionally separate from CI (no new guard job).
# - It only targets explicit "Bhagavad Gita" variants — it will NOT touch
#   "Uddhava Gita" or generic "Gita" by itself.
# - Review the diff before committing.
# - IMPORTANT: After running and committing, please DELETE this script
#   (`scripts/purge-bhagavad-gita.sh`) since it is only a temporary tool.

set -euo pipefail

APPLY="${APPLY:-0}"
EXTS="${EXTS:-md,mdx,txt}"
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

red=$(printf '\033[31m'); green=$(printf '\033[32m'); yellow=$(printf '\033[33m'); reset=$(printf '\033[0m')

declare -a PATTERNS=(
  'Bhagavad[ -]?Gita'
  'BHAGAVAD[ -]?GITA'
  'Bhagavadgita'
  'BHAGAVADGITA'
)
REPLACEMENT='Śrīmad-Bhāgavatam (Uddhava Gītā, Canto 11)'

IFS=',' read -r -a exts_arr <<< "$EXTS"
find_expr=()
for e in "${exts_arr[@]}"; do
  find_expr+=( -name "*.${e}" -o )
done
unset 'find_expr[${#find_expr[@]}-1]' || true

cd "$ROOT"
echo "Scanning under: $ROOT"
echo "Extensions: $EXTS"
echo "Dry-run: $([[ "$APPLY" = "1" ]] && echo 'NO (will write)' || echo 'YES (report only)')"
echo

mapfile -t files < <(find . \( "${find_expr[@]}" \) -type f \
  -not -path "./.git/*" -not -path "./node_modules/*" -not -path "./dist/*" -not -path "./build/*")

if [[ ${#files[@]} -eq 0 ]]; then
  echo "${yellow}No candidate files found for extensions: $EXTS${reset}"
  exit 0
fi

matches=0
for f in "${files[@]}"; do
  if LC_ALL=C grep -Eiq "$(IFS='|'; echo "${PATTERNS[*]}")" "$f"; then
    ((matches++))
    echo "→ $f"
    if [[ "$APPLY" = "1" ]]; then
      tmp="${f}.tmp.__purge_gita"
      cp "$f" "$tmp"
      for pat in "${PATTERNS[@]}"; do
        # GNU sed: replace case-insensitively with canonical target
        sed -E -i"" "s/${pat}/${REPLACEMENT}/gi" "$tmp"
      done
      if ! cmp -s "$f" "$tmp"; then
        mv "$tmp" "$f"
        echo "   ${green}✔ replaced${reset}"
      else
        rm -f "$tmp"
        echo "   (no change after replace pass)"
      fi
    else
      LC_ALL=C grep -Ein --color=always "$(IFS='|'; echo "${PATTERNS[*]}")" "$f" | sed 's/^/   /'
    fi
  fi
done

echo
if [[ "$APPLY" = "1" ]]; then
  if [[ $matches -gt 0 ]]; then
    echo "${green}✅ Replacement applied in $matches file(s).${reset}"
    echo "Review with: git diff -- . ':(exclude).git' ':(exclude)node_modules'"
  else
    echo "${yellow}No lingering references found.${reset}"
  fi
else
  echo "${yellow}Dry-run complete.${reset} To apply changes, run:"
  echo "  APPLY=1 bash scripts/purge-bhagavad-gita.sh"
fi
