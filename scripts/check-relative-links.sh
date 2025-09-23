#!/usr/bin/env bash
set -euo pipefail

# Relative-link audit for Markdown files.
# Fails on:
#  1) Leading-slash absolute Markdown links: ](/something.md)
#  2) Double-upwards (or more) relative links: ](../../something.md)
#
# Usage:
#   bash scripts/check-relative-links.sh
# Optional:
#   export LINK_AUDIT_IGNORE="path/to/file.md|docs/legacy/.*"
#
# Exit codes:
#   0 = clean
#   1 = violations found

shopt -s globstar

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo ".")"
cd "$ROOT"

ignore_re="${LINK_AUDIT_IGNORE:-^$}"  # default matches nothing

red=$'\e[31m'; green=$'\e[32m'; yellow=$'\e[33m'; reset=$'\e[0m'

echo "🔎 Scanning Markdown links for absolute and over-up links..."

violations=0

check_file () {
  local file="$1"

  # Skip ignored files
  if [[ "$file" =~ $ignore_re ]]; then
    return 0
  fi

  # Pattern A: leading-slash absolute path in Markdown link
  # e.g. [text](/foo/bar.md)
  if grep -nE '\]\(/[^) ]+\)' "$file" >/dev/null; then
    echo "${red}ABSOLUTE PATHS FOUND${reset} in $file:"
    grep -nE '\]\(/[^) ]+\)' "$file" | sed 's/^/  /'
    echo
    violations=1
  fi

  # Pattern B: double-upwards or more relative paths
  # e.g. [text](../../foo.md)  or ../../../
  if grep -nE '\]\(\.\./\.\./' "$file" >/dev/null; then
    echo "${yellow}OVER-UP RELATIVE PATHS FOUND${reset} in $file:"
    grep -nE '\]\(\.\./\.\./' "$file" | sed 's/^/  /'
    echo
    violations=1
  fi
}

for f in **/*.md; do
  case "$f" in
    .git/*) continue ;;
  esac
  [[ -f "$f" ]] || continue
  check_file "$f"
done

if [[ $violations -eq 0 ]]; then
  echo "${green}✅ Link audit clean. All Markdown links are branch-agnostic.${reset}"
else
  echo "${red}❌ Link audit found issues. See above for locations.${reset}"
  echo "Tip: From a child directory, use '../' to reach files in the parent; avoid '/absolute' and '../../'."
  exit 1
fi
