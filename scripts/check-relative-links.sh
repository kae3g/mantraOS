#!/usr/bin/env bash
# Verify Markdown uses relative links and required nav ribbons/quick links,
# scoped to the documents we enforce:
#   - README.md (root)
#   - 001-sadhana.md (root)
#   - 030-edu/*.md (stage scrolls only)
# We intentionally ignore docs/**, website/**, and other reference scrolls.
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

red=$(printf '\033[31m'); yellow=$(printf '\033[33m'); reset=$(printf '\033[0m')

fail=0

# Target file set
mapfile -t FILES < <(
  git ls-files \
    | grep -E '^(README\.md|001-sadhana\.md|030-edu/.*\.md)$' \
    | grep -Ev '^\.(git|github)/'
)

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

# 2) Require nav ribbon in sadhana + 030-edu pages
for f in 001-sadhana.md 030-edu/*.md; do
  [[ -f "$f" ]] || continue
  if ! grep -Fq "🔙 Return to the Dragon's Front Door: [../README.md](../README.md)" "$f" && \
     ! grep -Fq "🔙 Return to the Dragon's Front Door: [README.md](README.md)" "$f"; then
    echo "${red}Missing nav ribbon in:${reset} $f"
    fail=1
  fi
done

# 3) Require Quick Links footer in stage scrolls
for f in 001-sadhana.md 030-edu/*.md; do
  [[ -f "$f" ]] || continue
  if ! grep -Fq "Curriculum Index" "$f" || ! grep -Fq "Visual Tree Diagram" "$f" || ! grep -Fq "Return to README" "$f"; then
    echo "${red}Missing Quick Links in:${reset} $f"
    fail=1
  fi
done

# 4) Ignore everything under docs/** and website/** (informational scrolls)
#    — No action needed; we simply do not scan them above.

if [[ $fail -ne 0 ]]; then
  exit 1
fi
echo "✅ Relative links & required ribbons/footers OK (scoped set)."
