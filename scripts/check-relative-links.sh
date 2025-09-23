#!/usr/bin/env bash
set -euo pipefail

# Relative-link audit for Markdown files.
# Fails on:
#  1) Leading-slash absolute Markdown links: ](/something.md)
#  2) Double-upwards (or more) relative links: ](../../something.md)
#  3) Missing nav ribbons in curriculum scrolls (001-sadhana.md + 030-edu/*.md)
#  4) Missing Quick Links in all stage scrolls (Stages 1–10)
#
# Usage:
#   bash scripts/check-relative-links.sh
#   TAIL_LINES=40 bash scripts/check-relative-links.sh
#
# Configurable variables:
#   TAIL_LINES  - number of context lines to show when violations found (default: 20)
# Optional:
#   export LINK_AUDIT_IGNORE="path/to/file.md|docs/legacy/.*"
#
# Exit codes:
#   0 = clean
#   1 = violations found

# Enable globstar if available (bash 4+)
if [[ "${BASH_VERSION%%.*}" -ge 4 ]]; then
  shopt -s globstar
fi

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo ".")"
cd "$ROOT"

ignore_re="${LINK_AUDIT_IGNORE:-^$}"  # default matches nothing

red=$'\e[31m'; green=$'\e[32m'; yellow=$'\e[33m'; reset=$'\e[0m'

echo "🔎 Scanning Markdown links for absolute and over-up links..."

violations=0

TAIL_LINES="${TAIL_LINES:-20}"

check_file () {
  local file="$1"

  # Skip ignored files
  if [[ "$file" =~ $ignore_re ]]; then
    return 0
  fi

  # Skip documentation files that contain examples
  if [[ "$file" == "docs/STYLE-LINKS.md" ]]; then
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

  # Pattern C: nav ribbon presence in sadhana + curriculum scrolls
  if [[ "$file" == "001-sadhana.md" || "$file" == 030-edu/*.md ]]; then
    if ! grep -q "Return to the Dragon's Front Door" "$file"; then
      echo "${red}NAVIGATION RIBBON MISSING${reset} in $file"
      echo "  Expected a ribbon like:"
      echo "    🔙 Return to the Dragon's Front Door: [../README.md](../README.md)"
      echo
      violations=1
    fi
    if ! grep -q "Repository Map (lantern scroll)" "$file"; then
      echo "${red}NAVIGATION RIBBON MISSING${reset} in $file"
      echo "  Expected to include a Repository Map link."
      echo
      violations=1
    fi
    if [[ "$file" == "001-sadhana.md" ]]; then
      if ! grep -q "Curriculum Index" "$file"; then
        echo "${yellow}CURRICULUM INDEX LINK MISSING${reset} in $file"
        echo "  Expected to include a Curriculum Index back-link."
        echo
        violations=1
      fi
    fi
    if [[ "$file" == 030-edu/*.md ]]; then
      if ! grep -q "Curriculum Index" "$file"; then
        echo "${yellow}CURRICULUM INDEX LINK MISSING${reset} in $file"
        echo "  Expected to include a Curriculum Index back-link."
        echo
        violations=1
      fi
    fi
  fi

  # --------------------------------------------------------------------------
  # Pattern D: Quick Links presence in all stage scrolls (1–10)
  #   Require all three anchor phrases so learners never hit a dead end:
  #     - "Curriculum Index"
  #     - "Visual Tree Diagram"
  #     - "Return to README"
  #
  #   Files covered:
  #     - 001-sadhana.md
  #     - 030-edu/002-kernel-tree.md .. 030-edu/008-sustainability-cows-fields.md
  #     - 010-research/009-right-to-repair.md
  #     - 010-technical-vision.md
  # --------------------------------------------------------------------------
  if [[ "$file" == "001-sadhana.md" \
        || "$file" == 030-edu/002-* \
        || "$file" == 030-edu/003-* \
        || "$file" == 030-edu/004-* \
        || "$file" == 030-edu/005-* \
        || "$file" == 030-edu/006-* \
        || "$file" == 030-edu/007-* \
        || "$file" == 030-edu/008-* \
        || "$file" == 010-research/009-right-to-repair.md \
        || "$file" == 010-technical-vision.md ]]; then

    if ! grep -q "Curriculum Index" "$file"; then
      echo "${red}QUICK LINKS MISSING${reset} in $file"
      echo "  Expected a link labeled 'Curriculum Index'."
      echo
      violations=1
    fi
    if ! grep -q "Visual Tree Diagram" "$file"; then
      echo "${red}QUICK LINKS MISSING${reset} in $file"
      echo "  Expected a link labeled 'Visual Tree Diagram'."
      echo
      violations=1
    fi
    if ! grep -q "Return to README" "$file"; then
      echo "${red}QUICK LINKS MISSING${reset} in $file"
      echo "  Expected a link labeled 'Return to README'."
      echo
      violations=1
    fi
  fi

  # If violations detected for this file, show context
  if [[ $violations -eq 1 ]]; then
    echo "---- Context: tail of $file ----"
    tail -n "$TAIL_LINES" "$file"
    echo "--------------------------------"
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
