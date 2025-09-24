#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

mkdir -p .git/hooks
cat > .git/hooks/pre-commit <<'HOOK'
#!/usr/bin/env bash
set -euo pipefail

# Auto-fix common types to <=80 and then enforce checks.
echo "[pre-commit] Running wrap-auto..."
APPLY=1 python3 scripts/wrap-anytext.py || true

echo "[pre-commit] Rewriting remaining offenders (wrap-fix)..."
APPLY=1 python3 scripts/rewrite-violations.py || true

echo "[pre-commit] Checking relative links/ribbons..."
bash scripts/check-relative-links.sh

echo "[pre-commit] Enforcing 80-column rule..."
bash scripts/enforce-80.sh

echo "[pre-commit] OK"
HOOK

chmod +x .git/hooks/pre-commit
echo "Installed pre-commit hook."
#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p "$ROOT/.git/hooks"
cp "$ROOT/hooks/pre-commit" "$ROOT/.git/hooks/pre-commit"
chmod +x "$ROOT/.git/hooks/pre-commit"

echo "Installed pre-commit hook ✅"