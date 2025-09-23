#!/usr/bin/env bash
# Verify core docs use relative links & include nav ribbons/Quick Links.
# Scope:
#   - README.md (root)
#   - 001-sadhana.md (root)
#   - 030-edu/*.md (stage scrolls incl. curriculum & tree)
# Portable shell (no mapfile).
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

red=$(printf '\033[31m'); yellow=$(printf '\033[33m'); reset=$(printf '\033[0m')

fail=0

# Target file set
FILES=()
while IFS= read -r p; do
  FILES+=("$p")
done < <(git ls-files | \
grep -E '^(README\.md|001-sadhana\.md|030-edu/.*\.md)$' \
| grep -Ev '^\.(git|github)/')

# 1) Disallow absolute-root markdown links ](/foo.md) in target files only
abs_hits=0
for f in "${FILES[@]}"; do
  if grep -In "](/" "$f" >/dev/null; then
    echo "${red}Absolute path markdown link in:${reset} ${f}"
    grep -In "](/" "$f"
    abs_hits=1
  fi
done
if [[ $abs_hits -ne 0 ]]; then fail=1; fi

# 2) Require nav ribbon in sadhana + 030-edu pages (README is exempt)
for f in 001-sadhana.md 030-edu/*.md; do
  [[ -f "$f" ]] || continue
  # Allow minor spacing variations around colon and emoji variations
  if ! grep -Eq '🔙[[:space:]]+Return to the Dragon'\''s Front Door:[[:space:]]+\[(\.\./)?README\.md\]\((\.\./)?README\.md\)' "$f"; then
    echo "${red}Missing nav ribbon in:${reset} $f"
    fail=1
  fi
done

# 3) Quick Links sanity in README (Curriculum + Tree present)
if ! grep -Fq "## 🔗 Quick Links" README.md; then
  echo "${red}Missing Quick Links header in README.md${reset}"
  fail=1
fi
if ! grep -Eq '\[Curriculum Index\]\(030-edu/000-curriculum\.md\)' README.md; then
  echo "${red}Missing Curriculum Index link in README.md${reset}"
  fail=1
fi
if ! grep -Eq '\[Visual Tree Diagram\]\(030-edu/CURRICULUM-TREE\.md\)' README.md; then
  echo "${red}Missing Visual Tree Diagram link in README.md${reset}"
  fail=1
fi

if [[ $fail -ne 0 ]]; then
  exit 1
fi
echo "✅ Relative links & required ribbons/footers OK (scoped set)."
